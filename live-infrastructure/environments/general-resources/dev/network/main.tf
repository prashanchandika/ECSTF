
provider "aws" {
region="us-east-1"
profile="abc"
}


terraform {
  backend "s3" {
    bucket = "fisheye-crucible-tf-state"
    key    = "dev/network.tfstate"
    region = "us-east-1"
    dynamodb_table = "fisheye-crucible-tf-lock"
  }
}

module "my_vpc" {
  source = "../../../../../modules/network-fisheye/vpc"
  env = "DEV"
}
