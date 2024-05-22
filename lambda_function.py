import json

# Mock database (list of objects)
DATABASE = [
    {"id": 1, "AWS services": "Lambda | API Gateway | S3 | Cloudwatch"},
    {"id": 2, "Infrastructure": "Terraform"},
    {"id": 3, "CICD pipeline": "Github actions"}
    
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
