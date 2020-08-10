
#########################################################
# Service: Decision Tree DB ECS
#
# ECS Fargate Service and Task Definitions.
#########################################################
module "globals" {
  source = "../../globals"
}

#######################################################################
# NLB target group & listener for traffic on port 7687 (DecisionTree DB)
#######################################################################
resource "aws_lb_target_group" "target_group_7687" {
  name        = "SCALE-EU2-${upper(var.environment)}-VPC-TG-DTreeDB"
  port        = 7687
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

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "port_7687" {
  load_balancer_arn = var.lb_private_db_arn
  port              = "7687"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_7687.arn
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ecs_service" "decision_tree_db" {
  name             = "SCALE-EU2-${upper(var.environment)}-DB-ECS_Service_DecisionTreeDB"
  cluster          = var.ecs_cluster_id
  task_definition  = aws_ecs_task_definition.decision_tree_db.arn
  launch_type      = "FARGATE"
  platform_version = "LATEST"
  desired_count    = length(var.private_db_subnet_ids)

  network_configuration {
    security_groups  = [var.ecs_security_group_id]
    subnets          = var.private_db_subnet_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group_7687.arn
    container_name   = "SCALE-EU2-${upper(var.environment)}-DB-ECS_TaskDef_DecisionTreeDB"
    container_port   = 7687
  }
}

resource "aws_ecs_task_definition" "decision_tree_db" {
  family                   = "decision-tree-db"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.decision_tree_db_cpu
  memory                   = var.decision_tree_db_memory
  execution_role_arn       = var.ecs_task_execution_arn

  container_definitions = <<DEFINITION
    [
      {
          "name": "SCALE-EU2-${upper(var.environment)}-DB-ECS_TaskDef_DecisionTreeDB",
          "image": "${module.globals.env_accounts["mgmt"]}.dkr.ecr.eu-west-2.amazonaws.com/scale/decision-tree-db:8c66c97-candidate",
          "requires_compatibilities": "FARGATE",
          "cpu": ${var.decision_tree_db_cpu},
          "memory": ${var.decision_tree_db_memory},
          "essential": true,
          "networkMode": "awsvpc",
          "portMappings": [
              {
              "containerPort": 7687,
              "hostPort": 7687
              }
          ],
          "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${aws_cloudwatch_log_group.fargate_scale.name}",
                "awslogs-region": "eu-west-2",
                "awslogs-stream-prefix": "fargate-neo4j"
            }
          },
          "secrets": [
              {
                  "name": "DB_ADMIN_USERNAME",
                  "valueFrom": "${var.decision_tree_db_admin_username_arn}"
              },
              {
                  "name": "DB_ADMIN_PASSWORD",
                  "valueFrom": "${var.decision_tree_db_admin_password_arn}"
              },
              {
                  "name": "DB_SERVICE_ACCOUNT_USERNAME",
                  "valueFrom": "${var.decision_tree_db_service_account_username_arn}"
              },
              {
                  "name": "DB_SERVICE_ACCOUNT_PASSWORD",
                  "valueFrom": "${var.decision_tree_db_service_account_password_arn}"
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
  name_prefix       = "/fargate/service/scale/decision-tree-db"
  retention_in_days = 7
}
