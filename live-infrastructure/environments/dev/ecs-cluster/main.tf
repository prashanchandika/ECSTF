provider "aws" {
region="us-east-1"
#profile="abc"
access_key = "AKIA2CZVXVVFGNDUNSWU"
secret_key = "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"

}

terraform {
  backend "s3" {
    bucket = "fisheye-crucible-tf-state"
    key    = "dev/dev.tfstate"
    region = "us-east-1"
    dynamodb_table = "fisheye-crucible-tf-lock"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "fisheye-crucible-tf-state"
    key    = "dev/network.tfstate"
    region = "us-east-1"
  }
}

module "ecs-cluster" {
  source    = "../../../../modules/ecs"
  name      = "fisheyetest"
  servers   = 1
  #subnet_id = ["subnet-0669c544f1619a46b","subnet-0cc5f40a175a6baab"]
  #vpc_id    = "vpc-0846af0d44ec5a333"
  subnet_id = ["${data.terraform_remote_state.vpc.outputs.pv_subnet_2}","${data.terraform_remote_state.vpc.outputs.pv_subnet_1}"]
  vpc_id    = "${data.terraform_remote_state.vpc.outputs.vpc_id}"
  key_name = "prash"

#parameters required for alb##################################
  subnets            = ["${data.terraform_remote_state.vpc.outputs.pb_subnet_2}","${data.terraform_remote_state.vpc.outputs.pb_subnet_1}"]
  access_logs_bucket = "s3-lb-log"
  #certificate_arn    = "${var.certificate_arn}"

  enable_https_listener                  = false
  enable_http_listener                   = true
  enable_redirect_http_to_https_listener = false

  internal                    = false
  idle_timeout                = 120
  enable_deletion_protection  = false
  enable_http2                = false
  ip_address_type             = "ipv4"
  access_logs_prefix          = "test"
  access_logs_enabled         = false
  ssl_policy                  = "ELBSecurityPolicy-2016-08"
  https_port                  = 443
  http_port                   = 80
  fixed_response_content_type = "text/plain"
  fixed_response_message_body = "ok"
  fixed_response_status_code  = "200"
  ingress_cidr_blocks         = ["0.0.0.0/0"]

  target_group_port                = 8060
  target_group_protocol            = "HTTP"
  target_type                      = "instance"
  deregistration_delay             = 600
  slow_start                       = 0
  health_check_path                = "/"
  health_check_healthy_threshold   = 3
  health_check_unhealthy_threshold = 3
  health_check_timeout             = 3
  health_check_interval            = 60
  health_check_matcher             = 302
  health_check_port                = "traffic-port"
  health_check_protocol            = "HTTP"
  listener_rule_priority           = 1
  listener_rule_condition_field    = "path-pattern"
  listener_rule_condition_values   = ["/*"]

  tags = {
    Name        = "complete"
    Environment = "dev"
  }
#######################################################
}


# module "alb" {
#   source             = "../../../../modules/alb"
#   name               = "fisheyetest"
#   vpc_id             = "${data.terraform_remote_state.vpc.outputs.vpc_id}"
#   subnets            = ["${data.terraform_remote_state.vpc.outputs.pb_subnet_2}","${data.terraform_remote_state.vpc.outputs.pb_subnet_1}"]
#   access_logs_bucket = "s3-lb-log"
  
# }

# resource "aws_autoscaling_attachment" "asg_attachment" {
#   autoscaling_group_name = "${module.ecs-cluster.autoscaling_group.id}"
#   alb_target_group_arn   = "${module.alb.alb_target_group_arn}"
# }
