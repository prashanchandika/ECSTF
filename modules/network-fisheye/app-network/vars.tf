# Include all needed vars for each module for reference

variable "region" {}
variable "tf_state_s3_bucket" { #This refers to the S3 bucket containing the state of the peered managment network typically using a convention like 'prsn-terraform-state-us-east-1-825004305780'
}

variable "tf_state_region" {
  default = "us-east-1"
}

variable "peered_management_network_environment" {}


variable "tags" {
  type = "map"
}

variable "cidr" {
  default = "172.16.0.0/20"
}

variable "public_cidrs" {
  default = "172.16.0.0/23,172.16.2.0/23,172.16.4.0/23"
}

variable "private_cidrs" {
  default = "172.16.8.0/23,172.16.10.0/23,172.16.12.0/23"
}


