terraform {
  required_version = ">= 1.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  # Uncomment the line below after creating the S3 bucket
  #backend "s3" {}
}

provider "aws" {
  region  = var.region
  profile = var.profile
}
