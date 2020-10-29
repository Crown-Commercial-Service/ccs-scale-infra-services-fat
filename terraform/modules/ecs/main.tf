#########################################################
# Infrastructure: ECS
#
# Deploy SCALE Shared Services ECS Cluster.
#########################################################
module "globals" {
  source = "../globals"
}

data "aws_vpc_endpoint" "ecr" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.eu-west-2.ecr.dkr"
}

data "aws_vpc_endpoint" "s3" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.eu-west-2.s3"
}

data "aws_vpc_endpoint" "api_gateway" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.eu-west-2.execute-api"
}

resource "aws_ecs_cluster" "scale" {
  name = "SCALE-EU2-${upper(var.environment)}-APP-ECS_FAT"

  tags = {
    Project     = module.globals.project_name
    Environment = upper(var.environment)
    Cost_Code   = module.globals.project_cost_code
    AppType     = "ECS"
  }
}

#########################################################
# ECS Security Group and Policy
#########################################################
#TODO: Security Group is very open - needs tightening
resource "aws_security_group" "allow_http" {
  name                   = "allow_http_ecs_fat"
  description            = "Allow HTTP access to ECS Services"
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block_vpc]
  }

  ingress {
    from_port   = 9020
    to_port     = 9020
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block_vpc]
  }

  ingress {
    from_port   = 9030
    to_port     = 9030
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block_vpc]
  }

  ingress {
    from_port   = 7687
    to_port     = 7687
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block_vpc]
  }

  egress {
    from_port   = 7687
    to_port     = 7687
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block_vpc]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block_vpc]
  }

  egress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block_vpc]
  }

  # Allow traffic to/from ECR and S3 endpoints via VPC link
  # https://7thzero.com/blog/limiting-outbound-egress-traffic-while-using-aws-fargate-and-ecr
  egress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = data.aws_vpc_endpoint.ecr.security_group_ids # SG ID of VPC ECR endpoint
    prefix_list_ids = [data.aws_vpc_endpoint.s3.prefix_list_id]    # Prefix list ID of S3 endpoint
    cidr_blocks     = [var.cidr_block_vpc]
  }

  tags = {
    Project     = module.globals.project_name
    Environment = upper(var.environment)
    Cost_Code   = module.globals.project_cost_code
    AppType     = "ECS"
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "SCALE_ECS_FAT_Services_Task_Execution"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Project     = module.globals.project_name
    Environment = upper(var.environment)
    Cost_Code   = module.globals.project_cost_code
    AppType     = "ECS"
  }
}

resource "aws_iam_policy" "ecs_task_execution" {
  description = "ECS task execution policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ssm:GetParameters"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.ecs_task_execution.arn
}
