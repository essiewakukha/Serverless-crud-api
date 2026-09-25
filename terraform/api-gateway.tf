resource "aws_api_gateway_rest_api" "this" {
  name        = "${var.project_name}-api"
  description = "Serverless CRUD API backed by Lambda + DynamoDB"
}

# /items  -> GET (list), POST (create)
resource "aws_api_gateway_resource" "items" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "items"
}

resource "aws_api_gateway_method" "items_any" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.items.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "items_any" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.items.id
  http_method             = aws_api_gateway_method.items_any.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.this.invoke_arn
}

# /items/{id} -> GET (one), PUT (update), DELETE
resource "aws_api_gateway_resource" "item_id" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.items.id
  path_part   = "{id}"
}

resource "aws_api_gateway_method" "item_id_any" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.item_id.id
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.id" = true
  }
}

resource "aws_api_gateway_integration" "item_id_any" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.item_id.id
  http_method             = aws_api_gateway_method.item_id_any.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.this.invoke_arn
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.items.id,
      aws_api_gateway_resource.item_id.id,
      aws_api_gateway_method.items_any.id,
      aws_api_gateway_method.item_id_any.id,
      aws_api_gateway_integration.items_any.id,
      aws_api_gateway_integration.item_id_any.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = var.stage_name
}