resource "aws_ecs_task_definition" "fisheyetest" {
#  count                 = "${var.enable_agents ? 1 : 0}"
  family                = "fisheyetest-${aws_ecs_cluster.cluster.name}"
  memory                = 1024
  cpu                   = 1024
  container_definitions = file("${path.module}/templates/td.json")
  network_mode          = "bridge"
#  task_role_arn         = "${aws_iam_role.consul_task.arn}"


  volume {
    name      = "data"
    host_path = "/data/" # path should be parameterized
  }
}

#resource "aws_cloudwatch_log_group" "fisheyetest" {
#  count = "${var.enable_agents ? 1 : 0}"
#  name  = "${aws_ecs_task_definition.consul.family}"

#  tags {
#    VPC         = "${data.aws_vpc.vpc.tags["Name"]}"
#    Application = "${aws_ecs_task_definition.consul.family}"
#  }
#}

resource "aws_ecs_service" "fisheyetest" {
  #count                              = "${var.enable_agents ? 1 : 0}"
  name                               = "fisheyetest-${aws_ecs_cluster.cluster.name}"
  cluster                            = "${aws_ecs_cluster.cluster.id}"
  task_definition                    = "${aws_ecs_task_definition.fisheyetest.arn}"
  desired_count                      = "${var.servers}"
  deployment_minimum_healthy_percent = "60"

  placement_constraints {
    type = "distinctInstance"
  }
}
