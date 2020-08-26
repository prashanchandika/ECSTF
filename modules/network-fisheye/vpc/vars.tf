
variable "env" {
  default = ""
}

variable "instance_tenancy" {
  default = "default"
}

variable "vpc_id" {
  default = "vpc-0846af0d44ec5a333"
}

variable "pv_subnet_1_cidr_block" {
    default = "subnet-0cc5f40a175a6baab"
}

variable "pv_subnet_2_cidr_block" {
    default = "subnet-0669c544f1619a46b"
}

variable "pb_subnet_1_cidr_block" {
    default = "subnet-025e50b348c0dc371"
}

variable "pb_subnet_2_cidr_block" {
    default = "subnet-06342dc320c693630"
}


