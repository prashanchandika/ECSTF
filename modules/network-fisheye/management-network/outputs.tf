# VPC
# output "vpc" {
#   value = {
#     vpc_id             = "${module.vpc.vpc_id}"
#     cidr               = "${module.vpc.cidr}"
#     private_subnet_ids = "${module.vpc.private_subnet_ids}"
#     public_subnet_ids  = "${module.vpc.public_subnet_ids}"
#     nat_gateway_ids    = "${module.vpc.nat_gateway_ids}"
#     nat_gateway_public_ips     = "${module.vpc.nat_gateway_public_ips}"
#     s3_endpoint_prefix_list_id = "${module.vpc.s3_endpoint_prefix_list_id}"
#     vpn_gateway_id      = "${module.vpc.vpn_gateway_id}"
#     main_route_table_id = "${module.vpc.main_route_table_id}"
#     public_route_table_id   = "${module.vpc.public_route_table}"
#     private_route_table_ids = "${module.vpc.private_route_tables}"
#   }
# }

# Keys
output "keys" {
  value = "${module.keys.name}"
}

# Bastion
# output "bastion" {
#   value = {
#     user           = "${module.bastion.user}"
#     private_ip     = "${module.bastion.private_ip}"
#     public_ip      = "${module.bastion.public_ip}"
#     security_group = "${module.bastion.security_group}"
#     dns_name       = "${module.bastion.dns_name}"
#   }
# }
