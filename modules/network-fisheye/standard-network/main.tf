# Call other modules to ease in standing up new things
terraform {
  backend          "s3"             {}
  required_version = ">= 0.12.19"
}

provider "aws" {
  region = var.region

  #  version = "1.38.0"
}

module "vpc" {
  source        = "../vpc"
  region        = var.region
  tags          = var.tags
  cidr          = var.cidr
  public_cidrs  = var.public_cidrs
  private_cidrs = var.private_cidrs
}

module "keys" {
  source   = "../keys"
  region   = var.region
  key_name = var.key_name
}

module "bastion" {
  source                = "../bastion"
  region                = var.region
  tags                  = var.tags
  route53_zone          = var.route53_zone
  vpc_id                = var.vpc_id
  vpc_cidr              = var.vpc_cidr
  vpc_public_subnet_ids = var.vpc_public_subnet_ids
  key_name              = "${module.keys.name}"
  ssh_ingress_cidr      = var.ssh_ingress_cidr

  #ssh_ingress_pidc_cidr  = var.ssh_ingress_pidc_cidr
  forward_only_sshkey = var.forward_only_sshkey
  instance_type       = var.bastion_instance_type
  ami_id              = var.bastion_ami_id
}




# terraform {
#   backend          "s3"             {}
#   required_version = ">= 0.9.2"
# }
#
# provider "aws" {
#   region = "${var.region}"
#
#   #  version = "1.38.0"
# }
#
# module "vpc" {
#   source        = "../vpc"
#   region        = "${var.region}"
#   tags          = "${var.tags}"
#   cidr          = "${var.cidr}"
#   public_cidrs  = "${var.public_cidrs}"
#   private_cidrs = "${var.private_cidrs}"
# }
#
# module "keys" {
#   source   = "../keys"
#   region   = "${var.region}"
#   key_name = "${var.key_name}"
# }
#
# module "bastion" {
#   source                = "../bastion"
#   region                = "${var.region}"
#   tags                  = "${var.tags}"
#   route53_zone          = "${var.route53_zone}"
#   vpc_id                = "${var.vpc_id}"
#   vpc_cidr              = "${var.vpc_cidr}"
#   vpc_public_subnet_ids = "${var.vpc_public_subnet_ids}"
#   key_name              = "${module.keys.name}"
#   ssh_ingress_cidr      = "${var.ssh_ingress_cidr}"
#
#   #ssh_ingress_pidc_cidr  = "${var.ssh_ingress_pidc_cidr}"
#   forward_only_sshkey = "${var.forward_only_sshkey}"
#   instance_type       = "${var.bastion_instance_type}"
#   ami_id              = "${var.bastion_ami_id}"
# }
