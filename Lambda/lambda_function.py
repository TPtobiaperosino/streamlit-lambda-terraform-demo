# ───────────────────────────────────────────────────────────────
# AWS Lambda — handler function explained
# ───────────────────────────────────────────────────────────────
# The "handler" function must always exist in an AWS Lambda.
# It is the official entry point: AWS automatically executes it
# whenever the Lambda is invoked.
#
# Lambda always receives two inputs:
# 1. event → a Python dictionary automatically created by AWS
#             containing everything about the request
#             (URL, query parameters, headers, body, etc.)
# 2. context → metadata about the runtime environment
#               (memory, request ID, timeout, etc.)
#
# "event" is a dictionary (key–value pairs) that AWS builds every
# time the Lambda is called. You don’t create it — you just read it.
# ───────────────────────────────────────────────────────────────

def handler(event, context):

    # .get() safely retrieves values from a dictionary.
    # If the requested key doesn’t exist, instead of raising a KeyError,
    # it returns a default value.
    #
    # Example:
    # If a user sends this request:
    #   https://my-api.com/?name=Tobia&age=22
    # everything after "?" is called a *query string*.
    # Each piece (name=Tobia, age=22) is a key–value pair.
    #
    # In the next line there are two key levels:
    # - "queryStringParameters" → the key inside "event" that stores all
    #   parameters sent through the URL.
    # - "name" → the key inside that dictionary representing the value
    #   of the "name" parameter.
    #
    # The last argument, "World", is a default value returned if
    # "name" is missing.

    name = event.get("queryStringParameters", {}).get("name", "World")

    # ───────────────────────────────────────────────────────────────
    # 🔁 return — sending the response back to AWS
    # ───────────────────────────────────────────────────────────────
    # We use return to give AWS the response that the Lambda produced.
    #
    # Curly braces { } create a Python dictionary — the object AWS expects
    # to understand what the Lambda wants to return:
    #   1️⃣ Whether the execution succeeded or failed (statusCode)
    #   2️⃣ What content should be sent back to the user (body)
    #
    # "statusCode" → first key of the dictionary:
    #   - 200 → success
    #   - 400 → user input error
    #   - 404 → not found
    #   - 500 → internal server error
    #
    # "body" → second key, the actual content of the response.
    # AWS expects this key to contain the message or data to return.
    #
    # So the function is basically telling AWS:
    #   “Everything went fine (status 200), and here’s the message
    #    you should send back to the user.”
    # ───────────────────────────────────────────────────────────────

    return {
        "statusCode": 200,
        "body": f"Hello {name} from AWS Lambda!"
    }
