variable "region" {}
variable "vpc_id" {}
variable "vpc_cidr" {}
variable "vpc_public_subnet_ids" {}
variable "key_name" {}

variable "forward_only_sshkey" {
  default = ""
}

variable "ami_id" {
  default = ""
}

# variable "tags" {
#   type = "map"
# }
variable "inputs" {
  default = {}
}


variable "tags" {
  type = map
}
variable "instance_type" {
  default = "t2.small"
}

variable "ssh_ingress_cidr" {
  type        = list
  default     = ["159.182.1.4/32"]
  description = "A cidr notation for where incoming SSH traffic can originate"
}

# variable "ssh_ingress_cidr" {
#   type        = "list"
#   default     = ["159.182.1.4/32"]
#   description = "A cidr notation for where incoming SSH traffic can originate"
# }
#variable "ssh_ingress_pidc_cidr" {
#  type        = "list"
#  default     = ["121.241.16.178/32"]
#  description = "A PIDC cidr notation for where incoming SSH traffic can originate"
#}

variable "route53_zone" {
  default = "prsntmsdev.com."
}

variable "admin_password" {
  default = "qu33ndeals!"
}
