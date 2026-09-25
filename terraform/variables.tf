variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefix used to name and tag all resources"
  type        = string
  default     = "serverless-crud-api"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "dynamodb_table_name" {
  description = "Base name for the DynamoDB table (project_name is prefixed)"
  type        = string
  default     = "items"
}

variable "lambda_runtime" {
  description = "Lambda runtime for the handler"
  type        = string
  default     = "python3.12"
}

variable "lambda_handler" {
  description = "Lambda entry point (file.function)"
  type        = string
  default     = "lambda_function.lambda_handler"
}

variable "stage_name" {
  description = "API Gateway deployment stage name"
  type        = string
  default     = "prod"
}