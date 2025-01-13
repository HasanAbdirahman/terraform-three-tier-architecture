terraform {
  cloud {
    organization = "hasan-organization"
    workspaces {
      name = "cli-workforce"
    }
  }
}
provider "aws" {
  region = "us-east-2"
}
