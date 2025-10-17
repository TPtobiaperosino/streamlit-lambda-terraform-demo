output "api_url" {
  description = "Invoke URL for the API Gateway endpoint"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}

