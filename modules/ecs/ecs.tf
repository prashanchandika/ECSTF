data "aws_ami" "ecs_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-${var.ami_version}-amazon-ecs-optimized"]
  }
}

#data "template_file" "user_data" {
#  template = "${file("${path.module}/templates/user_data.tpl")}"

#  vars {
#    additional_user_data_script = "${var.additional_user_data_script}"
#    cluster_name                = "${aws_ecs_cluster.cluster.name}"
#    docker_storage_size         = "${var.docker_storage_size}"
#    dockerhub_token             = "${var.dockerhub_token}"
#    dockerhub_email             = "${var.dockerhub_email}"
#  }
#}

data "aws_vpc" "vpc" {
  id = "${var.vpc_id}"
}

resource "aws_launch_configuration" "ecs" {
  name_prefix                 = "${coalesce(var.name_prefix, "ecs-${var.name}-")}"
  image_id                    = "${var.ami == "" ? format("%s", data.aws_ami.ecs_ami.id) : var.ami}"   # Workaround until 0.9.6
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  iam_instance_profile        = "${aws_iam_instance_profile.ecs_profile.name}"
  security_groups             = ["${aws_security_group.ecs.id}"]
  associate_public_ip_address = "${var.associate_public_ip_address}"
  spot_price                  = "${var.spot_bid_price}"
  #user_data                   = "#!/bin/bash\necho ECS_CLUSTER=fisheyetest >> /etc/ecs/ecs.config; sudo mkdir -p /data; sudo mount -t efs -o tls fs-314954b1:/ /data"
  user_data                    = file("${path.module}/templates/userdata")

  ebs_block_device {
    device_name           = "${var.ebs_block_device}"
    volume_size           = "${var.docker_storage_size}"
    volume_type           = "gp2"
    delete_on_termination = true
  }

  #user_data = "${coalesce(var.user_data, data.template_file.user_data.rendered)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ecs" {
  name_prefix          = "asg-${aws_launch_configuration.ecs.name}-"
  vpc_zone_identifier  = "${var.subnet_id}"
  launch_configuration = "${aws_launch_configuration.ecs.name}"
  min_size             = "${var.min_servers}"
  max_size             = "${var.max_servers}"
  desired_capacity     = "${var.servers}"
  termination_policies = ["OldestLaunchConfiguration", "ClosestToNextInstanceHour", "Default"]
  #load_balancers       = ["$var.load_balancers"]
  #enabled_metrics      = ["$var.enabled_metrics"]

  tags = [{
    key                 = "Name"
    value               = "${var.name} ${var.tagName}"
    propagate_at_launch = true
  }]

  #tags = ["${var.extra_tags}"]

  lifecycle {
    create_before_destroy = true
  }

  timeouts {
    delete = "${var.heartbeat_timeout + var.asg_delete_extra_timeout}s"
  }
}

resource "aws_security_group" "ecs" {
  name        = "ecs-sg-${var.name}"
  description = "Container Instance Allowed Ports"
  vpc_id      = "${data.aws_vpc.vpc.id}"

  ingress {
    from_port   = 8060
    to_port     = 8060
    protocol    = "tcp"
    cidr_blocks = "${var.allowed_cidr_blocks}"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = "${var.allowed_cidr_blocks}"
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

#  tags {
#    Name = "ecs-sg-${var.name}"
#  }
}

# resource "aws_security_group_rule" "ssh" {
#   type              = "ingress"
#   from_port         = 22
#   to_port           = 22
#   protocol          = "tcp"
#   cidr_blocks       = "${var.allowed_cidr_blocks}"
#   security_group_id = "${aws_security_group.ecs.id}"
#   #security_group_id = "sg-0a4987a4661e63671"
# }

# Make this a var that an get passed in?
resource "aws_ecs_cluster" "cluster" {
  name    = "${var.name}"
}


######### ALB PART ################################################

# Terraform module which creates ALB resources on AWS.
#
# With ALB, cross-zone load balancing is always enabled.
# Therefore, not specified "enable_cross_zone_load_balancing".
# https://docs.aws.amazon.com/elasticloadbalancing/latest/userguide/how-elastic-load-balancing-works.html#cross-zone-load-balancing
#
# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html

# https://www.terraform.io/docs/providers/aws/r/lb.html
resource "aws_lb" "default" {
  #count = "${var.enabled}"

  load_balancer_type = "application"

  # The name of your ALB must be unique within your set of ALBs and NLBs for the region,
  # can have a maximum of 32 characters, can contain only alphanumeric characters and hyphens,
  # must not begin or end with a hyphen, and must not begin with "internal-".
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/application-load-balancer-getting-started.html#configure-load-balancer
  name = "${var.name}"

  # If true, the ALB will be internal.
  internal = "${var.internal}"

  # A list of security group IDs to assign to the ALB.
  # The rules for the security groups associated with your load balancer security group
  # must allow traffic in both directions on both the listener and the health check ports.
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/application-load-balancers.html#load-balancer-security-groups
  security_groups = ["${aws_security_group.default.id}"]

  # A list of subnet IDs to attach to the ALB.
  subnets = "${var.subnets}"

  # The time in seconds that the connection is allowed to be idle.
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/application-load-balancers.html#connection-idle-timeout
  idle_timeout = "${var.idle_timeout}"

  # To prevent your load balancer from being deleted accidentally, you can enable deletion protection.
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/application-load-balancers.html#deletion-protection
  enable_deletion_protection = "${var.enable_deletion_protection}"

  # You can send up to 128 requests in parallel using one HTTP/2 connection.
  # The load balancer converts these to individual HTTP/1.1 requests
  # and distributes them across the healthy targets in the target group.
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-listeners.html#listener-configuration
  enable_http2 = "${var.enable_http2}"

  # The type of IP addresses used by the subnets for your load balancer. The possible values are ipv4 and dualstack.
  # If dualstack, must specify subnets with an associated IPv6 CIDR block.
  # Note that internal load balancers must use ipv4.
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/application-load-balancers.html#ip-address-type
  ip_address_type = "${var.ip_address_type}"

  # ALB provides access logs that capture detailed information about requests sent to your load balancer.
  # Even if access_logs_enabled set false, you need to specify the valid bucket to access_logs_bucket.
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html
  access_logs {
    bucket  = "${var.access_logs_bucket}"
    prefix  = "${var.access_logs_prefix}"
    enabled = "${var.access_logs_enabled}"
  }

  # A mapping of tags to assign to the resource.
  tags = "${var.tags}"
}

# When you create a listener, you define actions for the default rule. Default rules can't have conditions.
# If no conditions for any of a listener's rules are met, then the action for the default rule is performed.
# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-listeners.html#listener-rules
#
# https://www.terraform.io/docs/providers/aws/r/lb_listener.html
#resource "aws_lb_listener" "https" {
  #count = "${local.enable_https_listener ? 1 : 0}"

  #load_balancer_arn = "${aws_lb.default.arn}"
  #port              = "${var.https_port}"
 # protocol          = "HTTPS"

  # You can choose the security policy that is used for front-end connections.
  # We recommend the ELBSecurityPolicy-2016-08 policy for general use.
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html#describe-ssl-policies
  #ssl_policy = "${var.ssl_policy}"

  # When you create an HTTPS listener, you must specify a default certificate.
  # You can create an optional certificate list for the listener by adding more certificates.
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html#https-listener-certificates
  #
  # If you wish adding more certificates, then use aws_lb_listener_certificate resource.
  # https://www.terraform.io/docs/providers/aws/r/lb_listener_certificate.html
  #certificate_arn = "${var.certificate_arn}"

  #default_action {
    # You can use this action to return a 2XX, 4XX, or 5XX response code and an optional message.
    # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-listeners.html#fixed-response-actions
    #type = "fixed-response"

    #fixed_response {
     # content_type = "${var.fixed_response_content_type}"
     # message_body = "${var.fixed_response_message_body}"
     # status_code  = "${var.fixed_response_status_code}"
   # }
  #}
#}

resource "aws_lb_listener" "http" {
  #count = "${local.enable_http_listener ? 1 : 0}"

  load_balancer_arn = "${aws_lb.default.arn}"
  port              = "${var.http_port}"
  protocol          = "HTTP"

  default_action {
    # You can use this action to return a 2XX, 4XX, or 5XX response code and an optional message.
    # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-listeners.html#fixed-response-actions
    #type = "fixed-response"

    #fixed_response {
    #  content_type = "${var.fixed_response_content_type}"
    #  message_body = "${var.fixed_response_message_body}"
    #  status_code  = "${var.fixed_response_status_code}"
    #}
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.default.arn}"
  }
}

#resource "aws_lb_listener" "redirect_http_to_https" {
#  #count = "${local.enable_redirect_http_to_https_listener ? 1 : 0}"

#  load_balancer_arn = "${aws_lb.default.arn}"
#  port              = "${var.http_port}"
#  protocol          = "HTTP"

#  default_action {
    # You can use redirect actions to redirect client requests from one URL to another.
    # You can configure redirects as either temporary (HTTP 302) or permanent (HTTP 301) based on your needs.
    # https://www.terraform.io/docs/providers/aws/r/lb_listener.html#redirect-action
#    type = "redirect"

#    redirect {
#      port        = "${var.https_port}"
#      protocol    = "HTTPS"
#      status_code = "HTTP_301"
#    }
#  }
#}

resource "aws_lb_target_group" "default" {
  #count = "${var.enabled}"

  name   = "${var.name}"
  vpc_id = "${var.vpc_id}"

  # The port on which the targets receive traffic.
  # This port is used unless you specify a port override when registering the target.
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/APIReference/API_CreateTargetGroup.html
  port = "${var.target_group_port}"

  # The protocol to use for routing traffic to the targets.
  # For Application Load Balancers, the supported protocols are HTTP and HTTPS.
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/APIReference/API_CreateTargetGroup.html
  protocol = "${var.target_group_protocol}"

  # The type of target that you must specify when registering targets with this target group.
  # The possible values are instance (targets are specified by instance ID) or ip (targets are specified by IP address).
  # You can't specify targets for a target group using both instance IDs and IP addresses.
  #
  # If the target type is ip, specify IP addresses from the subnets of the virtual private cloud (VPC) for the target group,
  # the RFC 1918 range (10.0.0.0/8, 172.16.0.0/12, and 192.168.0.0/16), and the RFC 6598 range (100.64.0.0/10).
  # You can't specify publicly routable IP addresses.
  #
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html#target-type
  target_type = "${var.target_type}"

  # The amount of time for Elastic Load Balancing to wait before deregistering a target.
  # The range is 0–3600 seconds.
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html#target-group-attributes
  deregistration_delay = "${var.deregistration_delay}"

  # The time period, in seconds, during which the load balancer sends
  # a newly registered target a linearly increasing share of the traffic to the target group.
  # The range is 30–900 seconds (15 minutes).
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html#target-group-attributes
  slow_start = "${var.slow_start}"

  # Your Application Load Balancer periodically sends requests to its registered targets to test their status.
  # These tests are called health checks.
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/target-group-health-checks.html
  health_check {
    # The ping path that is the destination on the targets for health checks.
    # Specify a valid URI (protocol://hostname/path?query).
    path = "${var.health_check_path}"

    # The number of consecutive successful health checks required before considering an unhealthy target healthy.
    # The range is 2–10.
    healthy_threshold = "${var.health_check_healthy_threshold}"

    # The number of consecutive failed health checks required before considering a target unhealthy.
    # The range is 2–10.
    unhealthy_threshold = "${var.health_check_unhealthy_threshold}"

    # The amount of time, in seconds, during which no response from a target means a failed health check.
    # The range is 2–60 seconds.
    timeout = "${var.health_check_timeout}"

    # The approximate amount of time, in seconds, between health checks of an individual target.
    # The range is 5–300 seconds.
    interval = "${var.health_check_interval}"

    # The HTTP codes to use when checking for a successful response from a target.
    # You can specify multiple values (for example, "200,202") or a range of values (for example, "200-299").
    matcher = "${var.health_check_matcher}"

    # The port the load balancer uses when performing health checks on targets.
    # The default is to use the port on which each target receives traffic from the load balancer.
    # Valid values are either ports 1-65536, or traffic-port.
    port = "${var.health_check_port}"

    # The protocol the load balancer uses when performing health checks on targets.
    # The possible protocols are HTTP and HTTPS.
    protocol = "${var.health_check_protocol}"
  }

  # A mapping of tags to assign to the resource.
  tags = "${var.tags}"

  # LB Target Group resource not requires Load Balancer.
  # On the other hand, ECS Service resource requires LB Target Group that has an associated Load Balancer.
  #
  # Therefore, if creating ECS Service and LB Target Group at the same time which may occurs error.
  # That's because LB Target Group has not yet been associated Load Balancer.
  # To avoid this problem, force the creation of LB Target Group to be after the creation of Load Balancer.
  depends_on = ["aws_lb.default"]
}

# Each rule has a priority. Rules are evaluated in priority order, from the lowest value to the highest value.
# The default rule is evaluated last. You can change the priority of a nondefault rule at any time.
# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-listeners.html#listener-rule-priority
#
# The priority for the rule between 1 and 50000.
# Leaving it unset will automatically set the rule with next available priority after currently existing highest rule.
# A listener can't have multiple rules with the same priority.
# https://www.terraform.io/docs/providers/aws/r/lb_listener_rule.html
#resource "aws_lb_listener_rule" "https" {
  #count = "${local.enable_https_listener ? 1 : 0}"

#  listener_arn = "${aws_lb_listener.https.arn}"
#  priority     = "${var.listener_rule_priority}"

#  action {
 #   type             = "forward"
   # target_group_arn = "${aws_lb_target_group.default.arn}"
  #}

#  condition {
 #   field  = "${var.listener_rule_condition_field}"
#    values = "${var.listener_rule_condition_values}"
#  }

  # Changing the priority causes forces new resource, then network outage may occur.
  # So, specify resources are created before destroyed.
#  lifecycle {
#    create_before_destroy = true
#  }
#}

#resource "aws_lb_listener_rule" "http" {
  #count = "${local.enable_http_listener ? 1 : 0}"

#  listener_arn = "${aws_lb_listener.http.arn}"
#  priority     = "${var.listener_rule_priority}"

#  action {
#    type             = "forward"
#    target_group_arn = "${aws_lb_target_group.default.arn}"
#  }

#  condition {
#    field  = "${var.listener_rule_condition_field}"
#    values = "${var.listener_rule_condition_values}"
#  }

#  lifecycle {
#    create_before_destroy = true
#  }
#}

# NOTE on Security Groups and Security Group Rules:
# At this time you cannot use a Security Group with in-line rules in conjunction with any Security Group Rule resources.
# Doing so will cause a conflict of rule settings and will overwrite rules.
# https://www.terraform.io/docs/providers/aws/r/security_group.html
resource "aws_security_group" "default" {
  #count = "${var.enabled}"

  name   = "${local.security_group_name}"
  vpc_id = "${var.vpc_id}"

  tags = "${merge(map("Name", local.security_group_name), var.tags)}"
}

locals {
  security_group_name = "${var.name}-alb"
}

# https://www.terraform.io/docs/providers/aws/r/security_group_rule.html
resource "aws_security_group_rule" "ingress_https" {
  #count = "${local.enable_https_listener ? 1 : 0}"

  type              = "ingress"
  from_port         = "${var.https_port}"
  to_port           = "${var.https_port}"
  protocol          = "tcp"
  cidr_blocks       = "${var.ingress_cidr_blocks}"
  security_group_id = "${aws_security_group.default.id}"
}

resource "aws_security_group_rule" "ingress_http" {
  #count = "${var.enabled && var.enable_http_listener ? 1 : 0}"

  type              = "ingress"
  from_port         = "${var.http_port}"
  to_port           = "${var.http_port}"
  protocol          = "tcp"
  cidr_blocks       = "${var.ingress_cidr_blocks}"
  security_group_id = "${aws_security_group.default.id}"
}

resource "aws_security_group_rule" "egress" {
  #count = "${var.enabled}"

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.default.id}"
}

locals {
  enable_https_listener                  = "${var.enabled && var.enable_https_listener}"
  enable_http_listener                   = "${var.enabled && var.enable_http_listener && !(var.enable_https_listener && var.enable_redirect_http_to_https_listener)}"
  enable_redirect_http_to_https_listener = "${var.enabled && var.enable_http_listener && (var.enable_https_listener && var.enable_redirect_http_to_https_listener)}"
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = "${aws_autoscaling_group.ecs.id}"
  #alb_target_group_arn   = "${module.alb.alb_target_group_arn}"
  alb_target_group_arn   = "${aws_lb_target_group.default.arn}"
}
###### END OF ALB PART ##################################################################

########## IAM PART ###################################################

resource "aws_iam_instance_profile" "ecs_profile" {
  name_prefix = "${replace(format("%.102s", replace("tf-ECSProfile-${var.name}-", "_", "-")), "/\\s/", "-")}"
  role        = "${aws_iam_role.ecs_role.name}"
  path        = "${var.iam_path}"
}

resource "aws_iam_role" "ecs_role" {
  name_prefix = "${replace(format("%.32s", replace("tf-ECSInRole-${var.name}-", "_", "-")), "/\\s/", "-")}"
  path        = "${var.iam_path}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
      "Service": ["ecs.amazonaws.com", "ec2.amazonaws.com"]

    },
    "Effect": "Allow",
    "Sid": ""
    }
  ]
}
EOF
}

# It may be useful to add the following for troubleshooting the InstanceStatus
# Health check if using the fitnesskeeper/consul docker image
# "ec2:Describe*",
# "autoscaling:Describe*",

resource "aws_iam_policy" "ecs_policy" {
  name_prefix = "${replace(format("%.102s", replace("tf-ECSInPol-${var.name}-", "_", "-")), "/\\s/", "-")}"
  description = "A terraform created policy for ECS"
  path        = "${var.iam_path}"
  count       = "${length(var.custom_iam_policy) > 0 ? 0 : 1}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:CreateCluster",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:Submit*",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "custom_ecs_policy" {
  name_prefix = "${replace(format("%.102s", replace("tf-ECSInPol-${var.name}-", "_", "-")), "/\\s/", "-")}"
  description = "A terraform created policy for ECS"
  path        = "${var.iam_path}"
  count       = "${length(var.custom_iam_policy) > 0 ? 1 : 0}"

  policy = "${var.custom_iam_policy}"
}

resource "aws_iam_policy_attachment" "attach_ecs" {
  name       = "ecs-attachment"
  roles      = ["${aws_iam_role.ecs_role.name}"]
  policy_arn = "${element(concat(aws_iam_policy.ecs_policy.*.arn, aws_iam_policy.custom_ecs_policy.*.arn), 0)}"
}

# IAM Resources for Fisheye and Registrator Agents

data "aws_iam_policy_document" "fisheyetest" {
  statement {
    actions = [
      "ec2:Describe*",
      "autoscaling:Describe*",
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "assume_role_fisheyetest_task" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

########## END OF IAM PART ###############################################################
