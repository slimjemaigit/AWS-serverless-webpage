import json

# Mock database (list of objects)
DATABASE = [
    {"id": 1, "name": "Slim"},
    {"id": 2, "name": "karim"},
    {"id": 3, "name": "Alice"},
    {"id": 4, "name": "Bob"}
]

def lambda_handler(event, context):
    try:
        # Generate response data
        response_data = {
            "statusCode": 200,
            "body": json.dumps(DATABASE)
        }
    except Exception as e:
        # If an exception occurs, return a 400 status code response
        response_data = {
            "statusCode": 400,
            "body": json.dumps({"error": str(e)})
        }

    return response_data
