#########################################################
# Infrastructure: API
#
# Deploy API Gateway account level resources.
# API Deployments are done later, after services.
#########################################################
module "globals" {
  source = "../globals"
}

data "aws_vpc_endpoint" "api_gateway" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.eu-west-2.execute-api"
}

# API Gateway account level settings
resource "aws_api_gateway_account" "this" {
  cloudwatch_role_arn = aws_iam_role.api_gw_cloudwatch_logs_role.arn
}

resource "aws_iam_role" "api_gw_cloudwatch_logs_role" {
  name = "SCALE_FaT_ApiGateway_PushToCWLog"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = {
    Project     = module.globals.project_name
    Environment = upper(var.environment)
    Cost_Code   = module.globals.project_cost_code
    AppType     = "APIGATEWAY"
  }
}

resource "aws_iam_role_policy" "cloudwatch" {
  name   = "default"
  role   = aws_iam_role.api_gw_cloudwatch_logs_role.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

# API gateway, top-level..
data "aws_iam_policy_document" "rest_api_allow_vpc" {
  source_json = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "execute-api:Invoke",
            "Resource": "*",
            "Condition": {
                "ForAllValues:StringEquals": {
                    "aws:SourceVpce": "${data.aws_vpc_endpoint.api_gateway.id}",
                    "aws:SourceVpc": "${var.vpc_id}"
                }
            }
        },
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "execute-api:Invoke",
            "Resource": "*",
            "Condition": {
                "IpAddress": {
                    "aws:VpcSourceIp": ["192.168.0.0/16", "90.252.146.145/32"]
                }
            }
        }
    ]
}
EOF
}

resource "aws_api_gateway_rest_api" "scale" {
  name        = "SCALE:EU2:${upper(var.environment)}:API:FAT"
  description = "SCALE API Gateway"

  endpoint_configuration {
    types            = ["PRIVATE"]
    vpc_endpoint_ids = [data.aws_vpc_endpoint.api_gateway.id]
  }

  policy = data.aws_iam_policy_document.rest_api_allow_vpc.json

  tags = {
    Project     = module.globals.project_name
    Environment = upper(var.environment)
    Cost_Code   = module.globals.project_cost_code
    AppType     = "APIGATEWAY"
  }
}

# Base path resources (/scale/)
resource "aws_api_gateway_resource" "scale" {
  rest_api_id = aws_api_gateway_rest_api.scale.id
  parent_id   = aws_api_gateway_rest_api.scale.root_resource_id
  path_part   = "scale"
}
