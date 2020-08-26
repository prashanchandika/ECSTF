# Call other modules to ease in standing up new things
terraform {
  backend "s3" {}
  required_version = ">= 0.11.1"
}

provider "aws" {
    alias = "default"
    region = "${var.region}"
    #  version = "1.38.0"
}

# module "vpc" {
#   source        = "../vpc"
#
#   providers = {
#     "aws" = "aws.default"
#   }
#
#   region        = "${var.region}"
#   tags          = "${var.tags}"
#   cidr          = "${var.cidr}"
#   public_cidrs  = "${var.public_cidrs}"
#   private_cidrs = "${var.private_cidrs}"
# }

module "keys" {
  source   = "../keys"

  providers = {
    "aws" = "aws.default"
  }

  region   = "${var.region}"
  key_name = "${var.key_name}"
}

module "bastion" {
  source            = "../bastion"

  providers = {
    "aws" = "aws.default"
  }

  region            = "${var.region}"
  # tags              = "${var.tags}"
  # route53_zone      = "${var.route53_zone}"
  # vpc_id            = "${var.vpc_id}"
  # vpc_cidr          = "${var.vpc_cidr}"
  # public_subnet_ids = "${var.vpc_public_subnet_ids}"
  # key_name          = "${module.keys.name}"
  # ssh_ingress_cidr  = "${var.ssh_ingress_cidr}"
  #ssh_ingress_pidc_cidr  = "${var.ssh_ingress_pidc_cidr}"

}
