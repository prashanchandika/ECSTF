# Include all needed vars for each module for reference

variable "region" {}
variable "key_name" {}

variable "tags" {
  type = "map"
}

variable "cidr" {
  default = "172.16.0.0/20"
}

variable "public_cidrs" {
  default = "172.16.0.0/23,172.16.2.0/23,172.16.4.0/23"
}

variable "private_cidrs" {
  default = "172.16.8.0/23,172.16.10.0/23,172.16.12.0/23"
}

variable "bastion_instance_type" {
  default = "t2.small"
}

variable "ssh_ingress_cidr" {
  type        = "list"
  default     = ["159.182.1.4/32"]
  description = "A cidr notation for where incoming SSH traffic can originate"
}

#variable "ssh_ingress_pidc_cidr" {
#  type        = "list"
#  default     = ["121.241.16.178/32"]
#  description = "A PIDC cidr notation for where incoming SSH traffic can originate"
#}

variable "route53_zone" {
  default = "pearsondev.com."
}
