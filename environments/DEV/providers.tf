# fillout
provider "aws" {
  region = "us-east-1"  # Replace with your desired region
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}