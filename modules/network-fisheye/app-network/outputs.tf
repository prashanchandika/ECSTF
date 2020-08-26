# VPC
output "vpc" {
  value = {
    vpc_id             = "${module.vpc.vpc_id}"
    cidr               = "${module.vpc.cidr}"
    private_subnet_ids = "${module.vpc.private_subnet_ids}"
    public_subnet_ids  = "${module.vpc.public_subnet_ids}"
    nat_gateway_ids    = "${module.vpc.nat_gateway_ids}"
    nat_gateway_public_ips     = "${module.vpc.nat_gateway_public_ips}"
    s3_endpoint_prefix_list_id = "${module.vpc.s3_endpoint_prefix_list_id}"
    vpn_gateway_id      = "${module.vpc.vpn_gateway_id}"
    main_route_table_id = "${module.vpc.main_route_table_id}"
    public_route_table_id   = "${module.vpc.public_route_table}"
    private_route_table_ids = "${module.vpc.private_route_tables}"
  }
}

output "peered_management_network_environment" {
  value = "${var.peered_management_network_environment}"
}

output "vpc_peering_connection_id" {
  value = "${aws_vpc_peering_connection.to_management_network.id}"
}

output "management_network_ingress_secgrp_id" {
  value = "${aws_security_group.allow_all_management_vpc_traffic.id}"
}

output "management_network_ingress_secgrp_name" {
  value = "${aws_security_group.allow_all_management_vpc_traffic.name}"
}
