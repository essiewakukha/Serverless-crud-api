import json
import os

import boto3
from botocore.exceptions import ClientError

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["TABLE_NAME"])


def lambda_handler(event, context):
    http_method = event.get("httpMethod")
    path_params = event.get("pathParameters") or {}
    item_id = path_params.get("id")

    try:
        if http_method == "GET" and item_id:
            return get_item(item_id)
        if http_method == "GET":
            return list_items()
        if http_method == "POST":
            return create_item(event)
        if http_method == "PUT" and item_id:
            return update_item(item_id, event)
        if http_method == "DELETE" and item_id:
            return delete_item(item_id)

        return _response(400, {"message": f"Unsupported route: {http_method}"})

    except ClientError as e:
        return _response(500, {"message": e.response["Error"]["Message"]})
    except json.JSONDecodeError:
        return _response(400, {"message": "Request body must be valid JSON"})
    except Exception as e:  # noqa: BLE001 - surface unexpected errors to the caller
        return _response(500, {"message": str(e)})


def list_items():
    result = table.scan()
    return _response(200, result.get("Items", []))


def get_item(item_id):
    result = table.get_item(Key={"id": item_id})
    item = result.get("Item")
    if not item:
        return _response(404, {"message": f"Item '{item_id}' not found"})
    return _response(200, item)


def create_item(event):
    body = json.loads(event.get("body") or "{}")
    if "id" not in body:
        return _response(400, {"message": "'id' is required in the request body"})
    table.put_item(Item=body)
    return _response(201, body)


def update_item(item_id, event):
    body = json.loads(event.get("body") or "{}")
    if not body:
        return _response(400, {"message": "Request body must contain at least one field to update"})

    update_expr_parts = []
    expr_attr_names = {}
    expr_attr_values = {}

    for i, (key, value) in enumerate(body.items()):
        name_placeholder = f"#f{i}"
        value_placeholder = f":v{i}"
        update_expr_parts.append(f"{name_placeholder} = {value_placeholder}")
        expr_attr_names[name_placeholder] = key
        expr_attr_values[value_placeholder] = value

    table.update_item(
        Key={"id": item_id},
        UpdateExpression="SET " + ", ".join(update_expr_parts),
        ExpressionAttributeNames=expr_attr_names,
        ExpressionAttributeValues=expr_attr_values,
    )
    return _response(200, {"id": item_id, **body})


def delete_item(item_id):
    table.delete_item(Key={"id": item_id})
    return _response(204, {})


def _response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body, default=str),
    }