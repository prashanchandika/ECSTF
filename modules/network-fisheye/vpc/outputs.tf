
output "vpc_id" {
  value = var.vpc_id
}

output "pv_subnet_1" {
  value = var.pv_subnet_1_cidr_block
}
output "pv_subnet_2" {
  value = var.pv_subnet_2_cidr_block
}
output "pb_subnet_1" {
  value = var.pb_subnet_1_cidr_block
}
output "pb_subnet_2" {
  value = var.pb_subnet_2_cidr_block
}

output "env" {
  value = var.env
}