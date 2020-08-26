#VPC
output "vpc" {
  value = {
    vpc_id             = var.vpc_id
    cidr               = var.vpc_cidr
    private_subnet_ids = var.vpc_private_subnet_ids
    public_subnet_ids  = var.vpc_public_subnet_ids
    #nat_gateway_ids    = var.vpc.nat_gateway_ids
    #nat_gateway_public_ips = var.vpc.nat_gateway_public_ips
    main_route_table_id     = var.main_route_table_id
    public_route_table_id   = var.public_route_table
    private_route_table_ids = var.private_route_tables
  }
}

# Keys
output "keys" {
  value = module.keys.name
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
# Bastion
# output "bastion" {
#   value = {
#     user           = module.bastion.user
#     private_ip     = module.bastion.private_ip
#     public_ip      = module.bastion.public_ip
#     security_group = module.bastion.security_group
#     dns_name       = module.bastion.dns_name
#   }
# }

output "cidr" {
  value = module.vpc.cidr
}

# output "private_subnet_ids" {
#   value = join(",", aws_subnet.private.*.id)
# }
#
# output "public_subnet_ids" {
#   value = join(",", aws_subnet.public.*.id)
# }

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

# output "nat_gateway_ids" {
#   value = join(",", aws_nat_gateway.nat.*.id)
# }
#
# output "nat_gateway_public_ips" {
#   value = join(",", aws_nat_gateway.nat.*.public_ip)
# }

output "vpn_gateway_id" {
  value = module.vpc.vpn_gateway_id
}

# output "s3_endpoint_prefix_list_id" {
#   value = aws_vpc_endpoint.s3_ep.prefix_list_id
# }

output "main_route_table_id" {
  value = module.vpc.main_route_table_id
}

output "public_route_table" {
  value = module.vpc.public_route_table
}

output "private_route_tables" {
  value = module.vpc.private_route_tables
}




# #VPC
# output "vpc" {
#   value = {
#     vpc_id             = "${var.vpc_id}"
#     cidr               = "${var.vpc_cidr}"
#     private_subnet_ids = "${var.vpc_private_subnet_ids}"
#     public_subnet_ids  = "${var.vpc_public_subnet_ids}"
#     #nat_gateway_ids    = "${var.vpc.nat_gateway_ids}"
#     #nat_gateway_public_ips = "${var.vpc.nat_gateway_public_ips}"
#     main_route_table_id     = "${var.main_route_table_id}"
#     public_route_table_id   = "${var.public_route_table}"
#     private_route_table_ids = "${var.private_route_tables}"
#   }
# }
#
# # Keys
# output "keys" {
#   value = "${module.keys.name}"
# }
#
# # Bastion
# # output "bastion" {
# #   value = {
# #     user           = "${module.bastion.user}"
# #     private_ip     = "${module.bastion.private_ip}"
# #     public_ip      = "${module.bastion.public_ip}"
# #     security_group = "${module.bastion.security_group}"
# #     dns_name       = "${module.bastion.dns_name}"
# #   }
# # }
