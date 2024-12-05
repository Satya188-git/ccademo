terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "SempraUtilities"

    workspaces {
      name = "#{ workspace-name }#"
    }
  }
  required_version = "#{ terraformVersion }#"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.21.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}