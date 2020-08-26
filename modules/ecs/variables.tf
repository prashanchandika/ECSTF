variable "additional_user_data_script" {
  default = ""
}

variable "allowed_cidr_blocks" {
  default     = ["0.0.0.0/0"]
  type        = "list"
  description = "List of subnets to allow into the ECS Security Group. Defaults to ['0.0.0.0/0']"
}

variable "ami" {
  default = ""
}

variable "ami_version" {
  default = "*"
}

variable "associate_public_ip_address" {
  default = false
}




variable "docker_storage_size" {
  default     = "22"
  description = "EBS Volume size in Gib that the ECS Instance uses for Docker images and metadata "
}

variable "dockerhub_email" {
  default     = ""
  description = "Email Address used to authenticate to dockerhub. http://docs.aws.amazon.com/AmazonECS/latest/developerguide/private-auth.html"
}

variable "dockerhub_token" {
  default     = ""
  description = "Auth Token used for dockerhub. http://docs.aws.amazon.com/AmazonECS/latest/developerguide/private-auth.html"
}

variable "enable_agents" {
  default     = false
  description = "Enable Consul Agent and Registrator tasks on each ECS Instance"
}

variable "ebs_block_device" {
  default     = "/dev/xvdcz"
  description = "EBS block devices to attach to the instance. (default: /dev/xvdcz)"
}

variable "extra_tags" {
  type    = "list"
  default = []
}

variable "heartbeat_timeout" {
  description = "Heartbeat Timeout setting for how long it takes for the graceful shutodwn hook takes to timeout. This is useful when deploying clustered applications like consul that benifit from having a deploy between autoscaling create/destroy actions. Defaults to 180"
  default     = "180"
}

variable "asg_delete_extra_timeout" {
  description = "Extra time that `terraform apply` will wait for ASG deletion (default 600). This is added on top of `heartbeat_timeout`. This variable is customizable for when the instances take longer than 600sec to shut down once shutdown is initiated."
  default     = "600"
}

variable "iam_path" {
  default     = "/"
  description = "IAM path, this is useful when creating resources with the same name across multiple regions. Defaults to /"
}

variable "custom_iam_policy" {
  default     = ""
  description = "Custom IAM policy (JSON). If set will overwrite the default one"
}

variable "instance_type" {
  default     = "t2.medium"
  description = "AWS Instance type, if you change, make sure it is compatible with AMI, not all AMIs allow all instance types "
}

variable "key_name" {
  description = "SSH key name in your AWS account for AWS instances."
}

variable "load_balancers" {
  type        = "list"
  default     = []
  description = "A list of elastic load balancer names to add to the autoscaling group names. Only valid for classic load balancers."
}

variable "min_servers" {
  description = "Minimum number of ECS servers to run."
  default     = 1
}

variable "max_servers" {
  description = "Maximum number of ECS servers to run."
  default     = 10
}

variable "name" {
  description = "AWS ECS Cluster Name"
}

variable "name_prefix" {
  default = ""
}

variable "region" {
  default     = "us-east-1"
  description = "The region of AWS, for AMI lookups."
}

variable "registrator_image" {
  default     = ""
  description = "Image to use when deploying registrator agent, defaults to the gliderlabs registrator:latest image"
}

variable "registrator_memory_reservation" {
  description = "The soft limit (in MiB) of memory to reserve for the container, defaults 20"
  default     = "32"
}

variable "security_group_ids" {
  type        = "string"
  description = "A list of Security group IDs to apply to the launch configuration"
  default = ""
#  default     = "sg-0199bb771ec5c0b2d"
}

variable "servers" {
  default     = "1"
  description = "The number of servers to launch."
}

variable "spot_bid_price" {
  default     = ""
  description = "If specified, spot instances will be requested at this bid price.  If not specified, on-demand instances will be used."
}

variable "subnet_id" {
  type        = "list"
  description = "The AWS Subnet ID in which you want to delpoy your instances"
}

variable "tagName" {
  default     = "ECS Node"
  description = "Name tag for the servers"
}

variable "user_data" {
  default = ""
}

variable "vpc_id" {
  description = "The AWS VPC ID which you want to deploy your instances"
}

variable "enabled_metrics" {
  description = "A list of metrics to collect"
  type        = "list"
  default     = []
}


# vars from IAM module



# vars from ALB module

variable "subnets" {
  type        = "list"
  description = "A list of subnet IDs to attach to the LB. At least two subnets in two different Availability Zones must be specified."
}

variable "access_logs_bucket" {
  type        = "string"
  description = "The S3 bucket name to store the logs in. Even if access_logs_enabled set false, you need to specify the valid bucket to access_logs_bucket."
}


variable "internal" {
  default     = false
  type        = "string"
  description = "If true, the LB will be internal."
}

variable "idle_timeout" {
  default     = 60
  type        = "string"
  description = "The time in seconds that the connection is allowed to be idle."
}

variable "enable_deletion_protection" {
  default     = true
  type        = "string"
  description = "If true, deletion of the load balancer will be disabled via the AWS API."
}

variable "enable_http2" {
  default     = true
  type        = "string"
  description = "Indicates whether HTTP/2 is enabled in application load balancers."
}

variable "ip_address_type" {
  default     = "ipv4"
  type        = "string"
  description = "The type of IP addresses used by the subnets for your load balancer. The possible values are ipv4 and dualstack."
}

variable "access_logs_prefix" {
  default     = "fisheyealb"
  type        = "string"
  description = "The S3 bucket prefix. Logs are stored in the root if not configured."
}

variable "access_logs_enabled" {
  default     = false
  type        = "string"
  description = "Boolean to enable / disable access_logs."
}

variable "enable_https_listener" {
  default     = true
  type        = "string"
  description = "If true, the HTTPS listener will be created."
}

variable "enable_http_listener" {
  default     = true
  type        = "string"
  description = "If true, the HTTP listener will be created."
}

variable "enable_redirect_http_to_https_listener" {
  default     = true
  type        = "string"
  description = "If true, the HTTP listener of HTTPS redirect will be created."
}

variable "ssl_policy" {
  default     = "ELBSecurityPolicy-2016-08"
  type        = "string"
  description = "The name of the SSL Policy for the listener. Required if protocol is HTTPS."
}

variable "certificate_arn" {
  default     = ""
  type        = "string"
  description = "The ARN of the default SSL server certificate. Exactly one certificate is required if the protocol is HTTPS."
}

variable "https_port" {
  default     = 443
  type        = "string"
  description = "The HTTPS port."
}

variable "http_port" {
  default     = 80
  type        = "string"
  description = "The HTTP port."
}

variable "fixed_response_content_type" {
  default     = "text/plain"
  type        = "string"
  description = "The content type. Valid values are text/plain, text/css, text/html, application/javascript and application/json."
}

variable "fixed_response_message_body" {
  default     = "404 Not Found"
  type        = "string"
  description = "The message body."
}

variable "fixed_response_status_code" {
  default     = "404"
  type        = "string"
  description = "The HTTP response code. Valid values are 2XX, 4XX, or 5XX."
}

variable "target_group_port" {
  default     = "80"
  type        = "string"
  description = "The port on which targets receive traffic, unless overridden when registering a specific target."
}

variable "target_group_protocol" {
  default     = "HTTP"
  type        = "string"
  description = "The protocol to use for routing traffic to the targets. Should be one of HTTP or HTTPS."
}

variable "target_type" {
  default     = "instance"
  type        = "string"
  description = "The type of target that you must specify when registering targets with this target group. The possible values are instance or ip."
}

variable "deregistration_delay" {
  default     = "300"
  type        = "string"
  description = "The amount time for the load balancer to wait before changing the state of a deregistering target from draining to unused."
}

variable "slow_start" {
  default     = "0"
  type        = "string"
  description = "The amount time for targets to warm up before the load balancer sends them a full share of requests."
}

variable "health_check_path" {
  default     = "/"
  type        = "string"
  description = "The destination for the health check request."
}

variable "health_check_healthy_threshold" {
  default     = "5"
  type        = "string"
  description = "The number of consecutive health checks successes required before considering an unhealthy target healthy."
}

variable "health_check_unhealthy_threshold" {
  default     = "2"
  type        = "string"
  description = "The number of consecutive health check failures required before considering the target unhealthy."
}

variable "health_check_timeout" {
  default     = "5"
  type        = "string"
  description = "The amount of time, in seconds, during which no response means a failed health check."
}

variable "health_check_interval" {
  default     = "30"
  type        = "string"
  description = "The approximate amount of time, in seconds, between health checks of an individual target."
}

variable "health_check_matcher" {
  default     = "200"
  type        = "string"
  description = "The HTTP codes to use when checking for a successful response from a target."
}

variable "health_check_port" {
  default     = "traffic-port"
  type        = "string"
  description = "The port to use to connect with the target."
}

variable "health_check_protocol" {
  default     = "HTTP"
  type        = "string"
  description = "The protocol to use to connect with the target."
}

variable "listener_rule_priority" {
  default     = 50000
  type        = "string"
  description = "The priority for the rule between 1 and 50000."
}

variable "listener_rule_condition_field" {
  default     = "path-pattern"
  type        = "string"
  description = "The name of the field. Must be one of path-pattern for path based routing or host-header for host based routing."
}

variable "listener_rule_condition_values" {
  default     = ["/*"]
  type        = "list"
  description = "The path patterns to match. A maximum of 1 can be defined."
}

variable "ingress_cidr_blocks" {
  default     = ["0.0.0.0/0"]
  type        = "list"
  description = "List of Ingress CIDR blocks."
}

variable "tags" {
  default     = {}
  type        = "map"
  description = "A mapping of tags to assign to all resources."
}

variable "enabled" {
  default     = false
  type        = "string"
  description = "Set to false to prevent the module from creating anything."
}