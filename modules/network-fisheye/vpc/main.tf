# terraform {
#   backend "s3" {}
#   #required_version = ">= 0.12.19"
#   required_version = ">= 0.9.2"
#
# }
#
# provider "aws" {
#   region = "${var.region}"
#   #  version = "1.38.0"
# }

# data "aws_availability_zones" "available" { state = "available" }
#
# # VPC
# resource "aws_vpc" "vpc" {
#   cidr_block           = "${var.cidr}"
#   enable_dns_support   = true
#   enable_dns_hostnames = true
#
#   tags = "${merge(map("Name",var.tags["environment"]),var.tags)}"
#
#   lifecycle {
#     create_before_destroy = true
#   }
# }
#
# resource "aws_vpn_gateway" "vgw" {
#   vpc_id = "${aws_vpc.vpc.id}"
#
#   tags = "${merge(map("Name", format("%s-vgw", var.tags["environment"])), var.tags)}"
# }
#
# # Public subnet requirements
# resource "aws_internet_gateway" "public" {
#   vpc_id = "${aws_vpc.vpc.id}"
#   tags   = "${merge(map("Name",var.tags["environment"]),var.tags)}"
# }
#
# resource "aws_subnet" "public" {
#   vpc_id            = "${aws_vpc.vpc.id}"
#   cidr_block        = "${element(split(",", var.public_cidrs), count.index)}"
#   availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"
#   count             = "${length(split(",", var.public_cidrs))}"
#
#   tags = "${merge(map("Name", format("%s-%s-public-subnet", var.tags["environment"], element(data.aws_availability_zones.available.names, count.index))), var.tags, map("network","public"))}"
#
#   lifecycle {
#     create_before_destroy = true
#   }
#
#   map_public_ip_on_launch = true
# }
#
# resource "aws_route_table" "public" {
#   vpc_id = "${aws_vpc.vpc.id}"
#   propagating_vgws = ["${aws_vpn_gateway.vgw.id}"]
#
#   tags = "${merge(map("Name", format("%s-%s-public-rt", var.tags["environment"], element(data.aws_availability_zones.available.names, count.index))), var.tags)}"
# }
#
# resource "aws_route" "public_default_route" {
#   route_table_id = "${aws_route_table.public.id}"
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id = "${aws_internet_gateway.public.id}"
# }
#
# resource "aws_route_table_association" "public" {
#   count          = "${length(split(",", var.public_cidrs))}"
#   subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
#   route_table_id = "${aws_route_table.public.id}"
# }
#
# resource "aws_eip" "nat" {
#   count = "${length(split(",", var.public_cidrs))}"
#   vpc = true
#
#   lifecycle {
#     create_before_destroy = true
#   }
# }
#
# resource "aws_nat_gateway" "nat" {
#   count         = "${length(split(",", var.public_cidrs))}"
#   allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
#   subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"
#
#   depends_on = ["aws_internet_gateway.public"]
#
#   lifecycle {
#     create_before_destroy = true
#   }
#
#   tags = "${merge(map("Name", format("%s-vgw", var.tags["environment"])), var.tags)}"
# }
#
# resource "aws_subnet" "private" {
#   count             = "${length(split(",", var.private_cidrs))}"
#   vpc_id            = "${aws_vpc.vpc.id}"
#   cidr_block        = "${element(split(",", var.private_cidrs), count.index)}"
#   availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"
#
#   tags = "${merge(map("Name", format("%s-%s-private-subnet", var.tags["environment"], element(data.aws_availability_zones.available.names, count.index))), var.tags, map("network","private"))}"
# }
#
# resource "aws_route_table" "private" {
#   count  = "${length(split(",", var.private_cidrs))}"
#   vpc_id = "${aws_vpc.vpc.id}"
#   propagating_vgws = ["${aws_vpn_gateway.vgw.id}"]
#
#   tags = "${merge(map("Name", format("%s-%s-private-rt", var.tags["environment"], element(data.aws_availability_zones.available.names, count.index))), var.tags)}"
# }
#
# resource "aws_route" "private_default_route" {
#   count          = "${length(split(",", var.private_cidrs))}"
#   route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id = "${element(aws_nat_gateway.nat.*.id, count.index)}"
# }
#
# resource "aws_route_table_association" "private" {
#   count          = "${length(split(",", var.private_cidrs))}"
#   subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
#   route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
# }
#
# ### S3 VPC endpoint definition ###
# data "aws_vpc_endpoint_service" "s3" {
#   service = "s3"
# }
#
# resource "aws_vpc_endpoint" "s3_ep" {
#   vpc_id = "${aws_vpc.vpc.id}"
#   service_name = "${data.aws_vpc_endpoint_service.s3.service_name}"
# }
#
# resource "aws_vpc_endpoint_route_table_association" "s3_ep" {
#   count = "${length(split(",", var.private_cidrs))}"
#   vpc_endpoint_id = "${aws_vpc_endpoint.s3_ep.id}"
#   route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
# }
#
# #VPC flow logs
#
# data "aws_caller_identity" "current" {}
#
# data "aws_region" "current" {
#   current = true
# }
#
# resource "aws_cloudwatch_log_group" "vpc" {
#   name = "${var.tags["environment"]}/vpc-flow"
# }
#
# resource "aws_flow_log" "vpc_flow_log" {
#   log_group_name = "${aws_cloudwatch_log_group.vpc.name}"
#   iam_role_arn   = "${aws_iam_role.vpc_flow_role.arn}"
#   vpc_id         = "${aws_vpc.vpc.id}"
#   traffic_type   = "ALL"
# }
#
# resource "aws_iam_role" "vpc_flow_role" {
#   name = "${var.tags["environment"]}-vpc-flow"
#
#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid": "",
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "vpc-flow-logs.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# EOF
# }
#
# resource "aws_iam_role_policy" "vpc_flow" {
#   name = "${var.tags["environment"]}-vpc-flow"
#   role = "${aws_iam_role.vpc_flow_role.id}"
#
#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": [
#         "logs:CreateLogGroup",
#         "logs:CreateLogStream",
#         "logs:PutLogEvents",
#         "logs:DescribeLogGroups",
#         "logs:DescribeLogStreams"
#       ],
#       "Effect": "Allow",
#       "Resource": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${var.tags["environment"]}/vpc-flow:*"
#     }
#   ]
# }
# EOF
# }
