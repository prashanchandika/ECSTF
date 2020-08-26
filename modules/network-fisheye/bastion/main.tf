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


terraform {
  backend "s3" {}
  required_version = ">= 0.12.19"
  #required_version = ">= 0.9.2"

}

provider "aws" {
  region = var.region
  #  version = "1.38.0"
}
################################## For Windows Bastion ################################################

#data "aws_ami" "bastion" {
#  most_recent      = true
#  owners = ["amazon"]
#  name_regex = "^Windows_Server-2016-English-Full-Containers.*"
#  filter {
#    name = "root-device-type"
#    values = ["ebs"]
#  }
#}

#data "aws_ami" "bastion" {
#  most_recent = true
#  owners      = ["099720109477"]
#  name_regex  = "^ubuntu/images/hvm-ssd/ubuntu.*"

#  filter {
#    name = "architecture"
#    values = ["x86_64"]
#  }

#  filter {
#    name = "virtualization-type"
#    values = ["hvm"]
#  }

#  filter {
#    name   = "root-device-type"
#    values = ["ebs"]
#  }
#}
#resource "aws_security_group" "bastion" {

#  name        = "${var.tags["environment"]}-bastion"
#  vpc_id      = "${var.vpc_id}"
#  description = "Bastion security group"

#  tags = "${merge(map("Name", var.tags["environment"]), var.tags)}"

#  lifecycle {
#    create_before_destroy = true
#  }

#  ingress {
#    protocol    = -1
#    from_port   = 0
#    to_port     = 0
#    cidr_blocks = ["${var.vpc_cidr}"]
#  }

#  ingress {
#    protocol    = "tcp"
#    from_port   = 22
#    to_port     = 22
#    cidr_blocks = "${var.ssh_ingress_cidr}"
#  }

#  #RDP access
#  ingress {
#    protocol    = "tcp"
#    from_port   = 3389
#    to_port     = 3389
#    cidr_blocks = "${var.ssh_ingress_cidr}"
#  }
#  ingress {
#    protocol    = "tcp"
#    from_port   = 22
#    to_port     = 22
#    cidr_blocks = "${var.ssh_ingress_pidc_cidr}"
#  }

#  #RDP access
#  ingress {
#    protocol    = "tcp"
#    from_port   = 3389
#    to_port     = 3389
#    cidr_blocks = "${var.ssh_ingress_pidc_cidr}"
#  }
#  # WinRM access
#  ingress {
#    protocol    = "tcp"
#    from_port   = 5985
#    to_port     = 5986
#    cidr_blocks = "${var.ssh_ingress_cidr}"
#  }

#egress {
#  protocol    = -1
#  from_port   = 0
#  to_port     = 0
#  cidr_blocks = ["0.0.0.0/0"]
#}
#}

#resource "aws_instance" "bastion" {
#ami                         = "${var.ami_id == "" ? data.aws_ami.bastion.id : var.ami_id}"
#  ami                         = "${data.aws_ami.bastion.id}"
#  instance_type               = "${var.instance_type}"
#  subnet_id                   = "${element(split(",", var.public_subnet_ids), count.index)}"
#  key_name                    = "${var.key_name}"
#  vpc_security_group_ids      = ["${aws_security_group.bastion.id}"]
#  associate_public_ip_address = true

# The connection block tells our provisioner how to
# communicate with the resource (instance)
#  connection {
#    type     = "winrm"
#    user     = "administrator"
#    password = "${var.admin_password}"
# set from default of 5m to 10m to avoid winrm timeout
#    timeout  = "10m"
#  }

# Note that terraform uses Go WinRM which doesn't support https at this time. If server is not on a private network,
# recommend bootstraping Chef via user_data.  See asg_user_data.tpl for an example on how to do that.
#  user_data = <<EOF
#<script>
#  winrm quickconfig -q & winrm set winrm/config @{MaxTimeoutms="1800000"} & winrm set winrm/config/service @{AllowUnencrypted="true"} & winrm set winrm/config/service/auth @{Basic="true"}
#</script>
#<powershell>
#  netsh advfirewall firewall add rule name="WinRM in" protocol=TCP dir=in profile=any localport=5985 remoteip=any localip=any action=allow
#  # Set Administrator password
#  $admin = [adsi]("WinNT://./administrator, user")
#  $admin.psbase.invoke("SetPassword", "${var.admin_password}")
#</powershell>
#EOF

#  tags = "${merge(map("Name", format("%v-bastion", var.tags["environment"])), var.tags)}"
#
#  lifecycle {
#    create_before_destroy = true
#  }
#}

##########################################################################################################

################################# For linux bastion ######################################################

#data "aws_ami" "bastion" {
#  most_recent = true
#  owners      = ["099720109477"]
#  name_regex  = "^ubuntu/images/hvm-ssd/ubuntu.*"

#  filter {
#    name   = "root-device-type"
#    values = ["ebs"]
#  }
#}

# data "aws_ami" "bastion" {
#   most_recent = true
#   owners      = ["099720109477"]
#   name_regex  = "^ubuntu/images/hvm-ssd/ubuntu.*"
#
#   filter {
#     name = "architecture"
#     values = ["x86_64"]
#   }
#
#   filter {
#     name = "virtualization-type"
#     values = ["hvm"]
#   }
#
#   filter {
#     name   = "root-device-type"
#     values = ["ebs"]
#   }
# }
#
# resource "aws_security_group" "bastion" {
#   name        = "${var.tags["environment"]}-bastion"
#   vpc_id      = "${var.vpc_id}"
#   description = "Bastion security group"
#
#   tags = "${merge(map("Name", var.tags["environment"]), var.tags)}"
#
#   lifecycle {
#     create_before_destroy = true
#   }
#
#   ingress {
#     protocol    = -1
#     from_port   = 0
#     to_port     = 0
#     cidr_blocks = ["${var.vpc_cidr}"]
#   }
#
#   ingress {
#     protocol    = "tcp"
#     from_port   = 22
#     to_port     = 22
#     cidr_blocks = "${var.ssh_ingress_cidr}"
#   }
#
#
#    #RDP access
#     ingress {
#       protocol    = "tcp"
#       from_port   = 3389
#       to_port     = 3389
#       cidr_blocks = "${var.ssh_ingress_cidr}"
#   }
#
# #    ingress {
# #      protocol    = "tcp"
# #      from_port   = 22
# #      to_port     = 22
# #      cidr_blocks = "${var.ssh_ingress_pidc_cidr}"
# #  }
#
#      #RDP access
#   #    ingress {
#   #      protocol    = "tcp"
#   #      from_port   = 3389
#   #      to_port     = 3389
#   #      cidr_blocks = "${var.ssh_ingress_pidc_cidr}"
#   #}
#
#     # WinRM access
#     ingress {
#       protocol    = "tcp"
#       from_port   = 5985
#       to_port     = 5986
#       cidr_blocks = "${var.ssh_ingress_cidr}"
#     }
#
#     # WinRM access
# #    ingress {
# #      protocol    = "tcp"
# #      from_port   = 5985
# #      to_port     = 5986
# #      cidr_blocks = "${var.ssh_ingress_pidc_cidr}"
# #    }
#
#
#   egress {
#     protocol    = -1
#     from_port   = 0
#     to_port     = 0
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }
#
# data "template_file" "user_data" {
#   template = "${file("${path.module}/user-data/cloud_init.tmpl")}"
#   count    = "${length(var.forward_only_sshkey) > 0 ? 1 : 0}"
#
#   vars {
#     encoded_forward_only_sshkey = "${base64encode("${file("${var.forward_only_sshkey}.pub")}")}"
#   }
# }
#
# resource "aws_instance" "bastion" {
#   ami                         = "${var.ami_id == "" ? data.aws_ami.bastion.id : var.ami_id}"
#   instance_type               = "${var.instance_type}"
#   subnet_id                   = "${element(split(",", var.vpc_public_subnet_ids), count.index)}"
#   key_name                    = "${var.key_name}"
#   vpc_security_group_ids      = ["${aws_security_group.bastion.id}"]
#   associate_public_ip_address = true
#
#   user_data = "${join("", data.template_file.user_data.*.rendered)}"
#
#   tags = "${merge(map("Name", format("%v-bastion", var.tags["environment"])), map("public-ip-exception", "bastion"), var.tags)}"
#
#   lifecycle {
#     create_before_destroy = true
#   }
# }
#
# ##########################################################################################################
#
#
#
# data "aws_route53_zone" "selected" {
#   name         = "${var.route53_zone}"
#   private_zone = false
# }
#
# # DNS
# resource "aws_route53_record" "bastion" {
#   zone_id = "${data.aws_route53_zone.selected.zone_id}"
#   name    = "${var.tags["environment"]}-bastion.${data.aws_route53_zone.selected.name}"
#   type    = "A"
#   ttl     = "300"
#   records = ["${aws_instance.bastion.public_ip}"]
# }
