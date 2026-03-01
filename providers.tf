terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "aws-vpn-lab"
      ManagedBy = "terraform"
    }
  }
}

provider "vault" {
  address = var.vault_address
  token   = var.vault_token
}