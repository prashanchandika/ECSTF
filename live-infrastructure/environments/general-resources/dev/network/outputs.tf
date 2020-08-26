output "vpc_id" {
  value = "${module.my_vpc.vpc_id}"
}

output "pv_subnet_1" {
  value = "${module.my_vpc.pv_subnet_1}"
}
output "pv_subnet_2" {
  value = "${module.my_vpc.pv_subnet_2}"
}
output "pb_subnet_1" {
  value = "${module.my_vpc.pb_subnet_1}"
}
output "pb_subnet_2" {
  value = "${module.my_vpc.pb_subnet_2}"
}

output "env" {
  value = "${module.my_vpc.env}"
}