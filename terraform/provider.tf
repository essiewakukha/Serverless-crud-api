terraform {
    required_version = ">=15"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
        source = "hashicorp/archive"
        version = "~> 2.4"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "var.aws_region"
}


