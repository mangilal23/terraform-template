provider "aws" {
  region                  = var.region
  shared_credentials_file = "C:\\Users\\jgz6kh8\\.aws\\credentials"
  profile                 = "default"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_security_group" "HTTP8080" {
  id = var.security_group_http_80
}

data "aws_security_group" "HTTPS" {
  id = var.security_group_https
}

data "template_file" "task_definition_json" {
  template = file("task-definitions/taskdefinition.json")
    vars = {
      awslogs_group = aws_cloudwatch_log_group.log_group.name
      environment   = var.environment
      name          = var.task_definition_name
      region        = var.region
	  awslogs_stream_prefix  = var.awslogs_stream_prefix
      ecr_repository_uri = var.ecr_repository_uri
      ecr_image_version = var.ecr_image_version

  }
}


resource "aws_cloudwatch_log_group" "log_group" {
  name = var.log_group
  tags = {
    Name = "fargate-template"
  }
}

resource "aws_ecs_cluster" "cluster" {
  name = "ecs-fargate-${var.environment}"
}

resource "aws_ecs_service" "service" {
  cluster = aws_ecs_cluster.cluster.id
  desired_count = 1
  launch_type = "FARGATE"
  name = "service-${var.environment}"
  task_definition = aws_ecs_task_definition.task_definition.arn

  load_balancer {
    container_name = var.task_definition_name 
    container_port = "80"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
  network_configuration {
    security_groups = [data.aws_security_group.HTTP8080.id]
    subnets = [var.public_subnet1, var.public_subnet2]
    assign_public_ip = "true"
  }
  depends_on = [
    aws_lb_listener.lb_listener_HTTPS
  ]
}

resource "aws_ecs_task_definition" "task_definition" {
  container_definitions = data.template_file.task_definition_json.rendered
  execution_role_arn = var.task_execution_role_arn
  family = "task-${var.environment}"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn = var.task_execution_role_arn
  cpu    = 1024
  memory = 4096
}

resource "aws_lb" "loadbalancer" {
  internal = "false"
  name = "elb-${var.environment}"
  subnets = [var.public_subnet1, var.public_subnet2]
  security_groups = [data.aws_security_group.HTTP8080.id, data.aws_security_group.HTTPS.id]
  tags = {
    environment = var.environment
    Name = "${var.environment}-lb"
  }
}

resource "aws_lb_target_group" "lb_target_group" {
  // Target Group gets Request from LB and passes it to your Application
  name = "elb"
  port = "80"         // Container port
  protocol = "HTTP"
  vpc_id = var.vpc_id
  target_type = "ip"

  tags = {
    environment = var.environment
    Name = "${var.environment}-target-group"
  }
}

resource "aws_lb_listener" "lb_listener_HTTPS" {
  default_action {
    target_group_arn = aws_lb_target_group.lb_target_group.arn
    type = "forward"
  }
  load_balancer_arn = aws_lb.loadbalancer.arn
  port = "80"
  protocol = "HTTP"
}


output "ecs" {
  value = aws_ecs_cluster.cluster.id
}

output "task_arn" {
  value = aws_ecs_task_definition.task_definition.arn
}
