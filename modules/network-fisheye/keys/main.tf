# terraform {
#   backend "s3" {}
#
#   #required_version = ">= 0.12.19"
#   required_version = ">= 0.9.2"
# }
#
# provider "aws" {
#   region = "${var.region}"
#
#   #  version = "1.38.0"
# }
#
# # SSH Key for accessing the cluster (though bastion)
# resource "aws_key_pair" "ssh-key" {
#   key_name   = "${var.key_name}"
#   public_key = "${file("${var.key_name}.pub")}"
# }


terraform {
  backend "s3" {}

  required_version = ">= 0.12.19"
  #required_version = ">= 0.9.2"
}

provider "aws" {
  region = var.region

  #  version = "1.38.0"
}

# SSH Key for accessing the cluster (though bastion)
resource "aws_key_pair" "ssh-key" {
  key_name   = var.key_name
  public_key = file("${var.key_name}.pub")
}
