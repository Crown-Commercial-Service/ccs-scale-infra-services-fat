#cc########################################################
# Service: BuyerUI ECS
#
# ECS Fargate Service and Task Definitions.
#########################################################
module "globals" {
  source = "../../globals"
}

#######################################################################
# NLB target group & listener for traffic on port 9030 (Agreements API)
#######################################################################
resource "aws_lb_target_group" "target_group_9030" {
  name        = "SCALE-EU2-${upper(var.environment)}-VPC-FaTBuyerUI"
  port        = 9030
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

resource "aws_lb_listener" "port_80" {
  load_balancer_arn = var.lb_public_arn
  port              = "80"
  protocol          = "TCP"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_9030.arn
  }
}

resource "aws_ecs_service" "fat_buyer_ui" {
  name             = "SCALE-EU2-${upper(var.environment)}-APP-ECS_Service_FaTBuyerUI"
  cluster          = var.ecs_cluster_id
  task_definition  = aws_ecs_task_definition.fat_buyer_ui.arn
  launch_type      = "FARGATE"
  platform_version = "LATEST"
  desired_count    = 1
  # deployment_controller {
  #  type = "CODE_DEPLOY"
  # }

  network_configuration {
    security_groups  = [var.ecs_security_group_id]
    subnets          = var.private_app_subnet_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group_9030.arn
    container_name   = "SCALE-EU2-${upper(var.environment)}-APP-ECS_TaskDef_FaTBuyerUI"
    container_port   = 9030
  }
}

resource "aws_ecs_task_definition" "fat_buyer_ui" {
  family                   = "fat-buyer-ui"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = var.ecs_task_execution_arn

  container_definitions = <<DEFINITION
    [
      {
        "name": "SCALE-EU2-${upper(var.environment)}-APP-ECS_TaskDef_FaTBuyerUI",
        "image": "${module.globals.env_accounts["mgmt"]}.dkr.ecr.eu-west-2.amazonaws.com/scale/fat-buyer-ui:${var.ecr_image_id_fat_buyer_ui}",
        "requires_compatibilities": "FARGATE",
        "cpu": 256,
        "memory": 512,
        "essential": true,
        "networkMode": "awsvpc",
        "portMappings": [
            {
            "containerPort": 9030,
            "hostPort": 9030
            }
        ],
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
              "awslogs-group": "${aws_cloudwatch_log_group.fargate_scale.name}",
              "awslogs-region": "eu-west-2",
              "awslogs-stream-prefix": "fargate-fat-buyer-ui"
          }
        },
        "environment" : [
          {
          "name": "ENVIRONMENT",
          "value": "${var.environment}"
          },
          {
          "name": "AGREEMENTS_SERVICE_ROOT_URL",
          "value": "${var.agreements_invoke_url}"
          },
          {
          "name": "GUIDED_MATCH_SERVICE_ROOT_URL",
          "value": "${var.api_invoke_url}"
          },
          {
          "name": "AGREEMENTS_SERVICE_API_KEY",
          "value": "${var.shared_api_key}"
          },
          {
          "name": "GUIDED_MATCH_SERVICE_API_KEY",
          "value": "${var.fat_api_key}"
          },
          {
          "name": "WEBCMS_ROOT_URL",
          "value": "${var.webcms_root_url}"
          }
        ]
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
  name_prefix       = "/fargate/service/scale/fat-buyer-ui"
  retention_in_days = 7
}
