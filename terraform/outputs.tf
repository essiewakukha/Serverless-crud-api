output "api_base_url" {
  description = "Base URL for the deployed API (append /items or /items/{id})"
  value       = aws_api_gateway_stage.this.invoke_url
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.this.name
}

output "lambda_function_name" {
  description = "Name of the deployed Lambda function"
  value       = aws_lambda_function.this.function_name
}