terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.15.1"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-1655044617"
    key            = "tf/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform_state_lock"
  }
}

provider "aws" {
  region = var.aws-region

  default_tags {
    tags = {
      Environment = "${var.environment}"
      Stack       = "${var.name}"
    }
  }
}
