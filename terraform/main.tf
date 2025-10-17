# ───────────────────────────────────────────────
# IAM ROLE — the Lambda cannot work alone
# ───────────────────────────────────────────────
# The first thing to do is define an IAM Role that the Lambda can assume.
# Terraform keyword `resource` defines a new AWS resource.
# `aws_iam_role` is the AWS resource type, and the second name ("lambda_exec")
# is a *local name* that Terraform uses internally. It is NOT the name you see in the AWS Console.
#
# `assume_role_policy` defines who is allowed to use this role.
# The function jsonencode() converts this HCL block into valid JSON, which AWS expects.
# Version "2012-10-17" is the standard IAM policy version.
# "Action" defines that the service is allowed to assume this role.
# "Effect" = "Allow" means we are granting the permission.
# "Principal" identifies *who* can assume the role → here, the Lambda service.

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# ───────────────────────────────────────────────
# LAMBDA FUNCTION — uses your Python code
# ───────────────────────────────────────────────
# We now create another resource with Terraform.
# `aws_lambda_function` declares the type of AWS resource,
# while "hello_lambda" is again the local Terraform name.
#
# `function_name` sets the official name that will appear in the AWS Console.
# `handler` tells AWS where to start execution in your Python code:
#   "lambda_function" → the file name (without .py)
#   "handler" → the function inside that file.
# `runtime` specifies the language environment (Python 3.11 here).
# `role` links this Lambda to the IAM role created earlier using
#   resource.localname.arn  → the ARN is the global AWS identifier.
# `filename` is the ZIP package Terraform will upload and execute.

resource "aws_lambda_function" "hello_lambda" {
  function_name = "hello_lambda"
  handler       = "lambda_function.handler"
  runtime       = "python3.11"
  role          = aws_iam_role.lambda_exec.arn
  filename      = "lambda_function.zip"
}

# ───────────────────────────────────────────────
# API GATEWAY — the “gate” exposing Lambda to the internet
# ───────────────────────────────────────────────
# Here we create a new resource: the API Gateway (v2 → newer version).
# `http_api` is the local name Terraform uses to refer to this API.
# `name` is the name you’ll see in the AWS Console.
# `protocol_type` shows what kind of protocol the API Gateway will use:
#   "HTTP" for normal web APIs, or "WEBSOCKET" for real-time connections.

resource "aws_apigatewayv2_api" "http_api" {
  name          = "lambda-http-api"
  protocol_type = "HTTP"
}

# ───────────────────────────────────────────────
# INTEGRATION — connect API Gateway → Lambda
# ───────────────────────────────────────────────
# This block links the API Gateway with the Lambda.
# It says: when a request reaches this API, forward it to the Lambda.
#
# `api_id` references the API created above.
# `integration_type` defines how the API and Lambda communicate:
#   • "AWS_PROXY" → passes the full HTTP request directly to Lambda (recommended)
#   • "AWS"       → older style, partial data mapping required
#   • "HTTP_PROXY"→ forwards to an external HTTP endpoint
# `integration_uri` specifies which Lambda to call when requests arrive.
# `.invoke_arn` is the specific ARN used for invocation (different from plain .arn).

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.hello_lambda.invoke_arn
}

# ───────────────────────────────────────────────
# ROUTE — defines which URL + method triggers the Lambda
# ───────────────────────────────────────────────
# This block “turns on” the API by saying:
# when someone calls a certain URL with a certain HTTP method (GET),
# forward that request to the Lambda.
#
# `api_id` connects the route to the specific API.
# `route_key` defines when this route is used:
#   • "GET" = HTTP method for reading data
#   • "/"   = the base URL path
# So this means: for GET requests to "/", use this rule.
#
# `target` defines where to send the request:
# prefix "integrations/" + the integration ID of our Lambda.
# The ${...} syntax lets us inject that ID dynamically.

resource "aws_apigatewayv2_route" "route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# ───────────────────────────────────────────────
# PERMISSIONS — allow API Gateway to invoke Lambda
# ───────────────────────────────────────────────
# This final block authorizes the API Gateway service to call the Lambda.
#
# `statement_id` is just a name for this permission statement.
# `action` specifies what is allowed → here, "lambda:InvokeFunction".
# `function_name` points to our Lambda by name (not ARN).
# `principal` indicates *who* can perform the action:
#   here it’s standard → "apigateway.amazonaws.com"
# `source_arn` limits the permission’s scope so that *only this API Gateway*
#   (identified by its execution ARN) can invoke the function.
# The wildcard /*/* means all routes and all HTTP methods of that API.

resource "aws_lambda_permission" "api_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

# ───────────────────────────────────────────────
# API Deployment
# ───────────────────────────────────────────────
resource "aws_apigatewayv2_deployment" "api_deployment" {
  api_id = aws_apigatewayv2_api.http_api.id

  depends_on = [
    aws_apigatewayv2_route.route
  ]
}

# ───────────────────────────────────────────────
# API Stage
# ───────────────────────────────────────────────
resource "aws_apigatewayv2_stage" "api_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
  deployment_id = aws_apigatewayv2_deployment.api_deployment.id
}

