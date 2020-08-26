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

data "aws_caller_identity" "current" {
  provider = "aws.default"
}

data "terraform_remote_state" "management_network" {
  backend = "s3"
  config {
    bucket = "${var.tf_state_s3_bucket}"
    region = "${var.tf_state_region}"
    key    = "${var.peered_management_network_environment}/terraform.tfstate"
  }
}

resource "aws_vpc_peering_connection" "to_management_network" {
  provider = "aws.default"

  vpc_id = "${var.vpc_id}"
  peer_owner_id = "${data.aws_caller_identity.current.account_id}"
  peer_vpc_id = "${data.terraform_remote_state.management_network.vpc["vpc_id"]}"
  # Flags that the peering connection should be automatically confirmed. This
  # only works if both VPCs are owned by the same account.
  auto_accept = true
  tags =  "${merge(map("Name", var.tags["environment"]), var.tags)}"
}

resource "aws_route" "app_to_management_network" {
  provider = "aws.default"

  count = "${length(split(",", var.private_cidrs))}"
  route_table_id = "${element(split(",", module.vpc.private_route_tables), count.index)}"
  destination_cidr_block = "${data.terraform_remote_state.management_network.vpc["cidr"]}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.to_management_network.id}"
}

resource "aws_route" "management_to_app_private_network" {
  provider = "aws.default"

  count = "${length(split(",", data.terraform_remote_state.management_network.vpc["private_route_table_ids"]))}"
  route_table_id = "${element(split(",", data.terraform_remote_state.management_network.vpc["private_route_table_ids"]), count.index)}"
  destination_cidr_block = "${module.vpc.cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.to_management_network.id}"
}

resource "aws_route" "management_to_app_public_network" {
  provider = "aws.default"

  count = "${length(split(",", data.terraform_remote_state.management_network.vpc["public_route_table_id"]))}"
  route_table_id = "${element(split(",", data.terraform_remote_state.management_network.vpc["public_route_table_id"]), count.index)}"
  destination_cidr_block = "${module.vpc.cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.to_management_network.id}"
}

resource "aws_security_group" "allow_all_management_vpc_traffic" {
  provider = "aws.default"

  name        = "allow_all_management_vpc_traffic"
  description = "Allow all inbound traffic"
  vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_security_group_rule" "allow_tcp_management_vpc_traffic" {
  provider = "aws.default"

  type              = "ingress"
  to_port           = 0
  protocol          = "tcp"
  from_port         = 0
  cidr_blocks     = ["${data.terraform_remote_state.management_network.vpc["cidr"]}"]
  security_group_id = "${aws_security_group.allow_all_management_vpc_traffic.id}"
  description = "Allows TCP traffic within the network"
}

resource "aws_security_group_rule" "allow_udp_management_vpc_traffic" {
  provider = "aws.default"

  type              = "ingress"
  to_port           = 0
  protocol          = "udp"
  from_port         = 0
  cidr_blocks     = ["${data.terraform_remote_state.management_network.vpc["cidr"]}"]
  security_group_id = "${aws_security_group.allow_all_management_vpc_traffic.id}"
  description = "Allows UDP traffic within the network"
}

resource "aws_security_group_rule" "allow_icmp_management_vpc_traffic" {
  provider = "aws.default"

  type              = "ingress"
  to_port           = 0
  protocol          = "icmp"
  from_port         = 0
  cidr_blocks     = ["${data.terraform_remote_state.management_network.vpc["cidr"]}"]
  security_group_id = "${aws_security_group.allow_all_management_vpc_traffic.id}"
  description = "Allows ICMP traffic within the network"
}
