
#########################################################
# Service: Guided Match ECS
#
# ECS Fargate Service and Task Definitions.
#########################################################
module "globals" {
  source = "../../globals"
}

#######################################################################
# NLB target group & listener for traffic on port 9020 (Guided Match API)
#######################################################################
resource "aws_lb_target_group" "target_group_9020" {
  name        = "SCALE-EU2-${upper(var.environment)}-VPC-TG-GM"
  port        = 9020
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  stickiness {
    type    = "lb_cookie"
    enabled = false
  }

  tags = {
    Project     = module.globals.project_name
    Environment = upper(var.environment)
    Cost_Code   = module.globals.project_cost_code
    AppType     = "LOADBALANCER"
  }
}

resource "aws_lb_listener" "port_9020" {
  load_balancer_arn = var.lb_private_arn
  port              = "9020"
  protocol          = "TCP"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_9020.arn
  }
}

resource "aws_ecs_service" "guided_match" {
  name             = "SCALE-EU2-${upper(var.environment)}-APP-ECS_Service_GuidedMatch"
  cluster          = var.ecs_cluster_id
  task_definition  = aws_ecs_task_definition.guided_match.arn
  launch_type      = "FARGATE"
  platform_version = "LATEST"
  desired_count    = 1

  network_configuration {
    security_groups  = [var.ecs_security_group_id]
    subnets          = var.private_app_subnet_ids
    assign_public_ip = false # Replace NAT GW and disable this by replacement AWS PrivateLink
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group_9020.arn
    container_name   = "SCALE-EU2-${upper(var.environment)}-APP-ECS_TaskDef_GuidedMatch"
    container_port   = 9020
  }
}

resource "aws_ecs_task_definition" "guided_match" {
  family                   = "guided-match"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = var.ecs_task_execution_arn

  container_definitions = <<DEFINITION
    [
      {
        "name": "SCALE-EU2-${upper(var.environment)}-APP-ECS_TaskDef_GuidedMatch",
        "image": "${module.globals.env_accounts["mgmt"]}.dkr.ecr.eu-west-2.amazonaws.com/scale/guided-match-service:76b17f3-candidate",
        "requires_compatibilities": "FARGATE",
        "cpu": 256,
        "memory": 512,
        "essential": true,
        "networkMode": "awsvpc",
        "portMappings": [
            {
            "containerPort": 9020,
            "hostPort": 9020
            }
        ],
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
              "awslogs-group": "${aws_cloudwatch_log_group.fargate_scale.name}",
              "awslogs-region": "eu-west-2",
              "awslogs-stream-prefix": "fargate-guided-match"
          }
        }
      }
    ]
DEFINITION

  tags = {
    Project     = module.globals.project_name
    Environment = upper(var.environment)
    Cost_Code   = module.globals.project_cost_code
    AppType     = "ECS"
  }
}

resource "aws_cloudwatch_log_group" "fargate_scale" {
  name_prefix       = "/fargate/service/scale/guided-match"
  retention_in_days = 7
}
