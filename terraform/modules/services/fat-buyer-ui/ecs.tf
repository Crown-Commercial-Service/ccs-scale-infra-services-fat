#cc########################################################
# Service: BuyerUI ECS
#
# ECS Fargate Service and Task Definitions.
#########################################################
module "globals" {
  source = "../../globals"
}

# Data sources for the ALB custom domain name and SSL certificate
data "aws_ssm_parameter" "hosted_zone_name_alb" {
  name = "${lower(var.environment)}-hosted-zone-name-alb"
}

data "aws_acm_certificate" "alb" {
  domain   = data.aws_ssm_parameter.hosted_zone_name_alb.value
  statuses = ["ISSUED"]
}

#######################################################################
# NLB target group & listener for traffic on port 9030 (Agreements API)
#######################################################################
resource "aws_lb_target_group" "target_group_9030" {
  name        = "SCALE-EU2-${upper(var.environment)}-VPC-FaTBuyerUI"
  port        = 9030
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  stickiness {
    type    = "lb_cookie"
    enabled = false
  }

  # Required for ALB operating over HTTP
  health_check {
    path = "/guided-match/health-check"
  }

  tags = {
    Project     = module.globals.project_name
    Environment = upper(var.environment)
    Cost_Code   = module.globals.project_cost_code
    AppType     = "LOADBALANCER"
  }
}

resource "aws_lb_listener" "https_443" {
  load_balancer_arn = var.lb_public_alb_arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = data.aws_acm_certificate.alb.arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<html><body>Unauthorised</body></html>"
      status_code  = "403"
    }
  }
}

resource "aws_lb_listener_rule" "authenticate_cloudfront" {
  listener_arn = aws_lb_listener.https_443.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_9030.arn
  }

  condition {
    http_header {
      http_header_name = "CloudFrontID"
      values           = [var.cloudfront_id]
    }
  }
}

resource "aws_ecs_service" "fat_buyer_ui" {
  name             = "SCALE-EU2-${upper(var.environment)}-APP-ECS_Service_FaTBuyerUI"
  cluster          = var.ecs_cluster_id
  task_definition  = aws_ecs_task_definition.fat_buyer_ui.arn
  launch_type      = "FARGATE"
  platform_version = "LATEST"
  desired_count    = length(var.private_app_subnet_ids)

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
  cpu                      = var.buyer_ui_cpu
  memory                   = var.buyer_ui_memory
  execution_role_arn       = var.ecs_task_execution_arn

  container_definitions = <<DEFINITION
    [
      {
        "name": "SCALE-EU2-${upper(var.environment)}-APP-ECS_TaskDef_FaTBuyerUI",
        "image": "${module.globals.env_accounts["mgmt"]}.dkr.ecr.eu-west-2.amazonaws.com/scale/fat-buyer-ui:${var.ecr_image_id_fat_buyer_ui}",
        "requires_compatibilities": "FARGATE",
        "cpu": ${var.buyer_ui_cpu},
        "memory": ${var.buyer_ui_memory},
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
        "secrets": [
            {
                "name": "AGREEMENTS_SERVICE_API_KEY",
                "valueFrom": "${var.shared_api_key_arn}"
            },
            {
                "name": "GUIDED_MATCH_SERVICE_API_KEY",
                "valueFrom": "${var.fat_api_key_arn}"
            }
        ],
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
  retention_in_days = var.ecs_log_retention_in_days
}
