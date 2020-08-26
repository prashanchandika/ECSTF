# Include all needed vars for each module for reference

variable "region" {
  default = "us-east-1"
}

variable "key_name" {
  default = "qma-smk"
}

variable "forward_only_sshkey" {
  default = ""
}

variable "tags" {
  type = map
}

variable "inputs" {
  default = {}
}

# variable "tags" {
#   type = "map"
# }
# variable "inputs" {
#   default = ""
# }

variable "aws_account_id" {
  default = ""
}

# variable "cidr" {
#   default = "172.16.0.0/20"
# }
#
# variable "public_cidrs" {
#   default = "172.16.0.0/23,172.16.2.0/23,172.16.4.0/23"
# }
#
# variable "private_cidrs" {
#   default = "172.16.8.0/23,172.16.10.0/23,172.16.12.0/23"
# }

variable "bastion_instance_type" {
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
  default = "pearsondev.com."
}

variable "bastion_ami_id" {
  default = ""
}

variable "cidr" {
  default = "10.168.0.0/19"
}

variable "public_cidrs" {
  default = "10.168.0.0/22,10.168.4.0/22,10.168.8.0/22"
}

variable "private_cidrs" {
  default = "10.168.12.0/22,10.168.16.0/22,10.168.20.0/22"
}

variable "vpc_id" {
  default = "vpc-261cfb49"
}

variable "vpc_cidr" {
  default = "10.168.0.0/19"
}

variable "vpc_public_subnet_ids" {
  default = "subnet-22f9194d,subnet-3a1cfb55,subnet-50fa1a3f"
}

variable "vpc_private_subnet_ids" {
  default = "subnet-3e1cfb51,subnet-72fa1a1d,subnet-13fa1a7c"
}

variable "vpn_gateway_id" {
  default = "vgw-03bb5b6a"
}

variable "main_route_table_id" {
  default = "rtb-241cfb4b"
}

variable "public_route_table" {
  default = "rtb-3f1cfb50"
}

variable "private_route_tables" {
  default = "rtb-4be6072f,rtb-5be6073f,rtb-a0e706c4"
}
