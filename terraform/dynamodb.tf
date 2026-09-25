resource "aws_dynamodb_table" "this" {
  name             = "${var.project_name}-${var.dynamodb_table_name}"
  hash_key         = "id" 
  billing_mode     = "PAY_PER_REQUEST" #on demand capacity


  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Project = var.project_name
    Environment = var.environment
  }

}
