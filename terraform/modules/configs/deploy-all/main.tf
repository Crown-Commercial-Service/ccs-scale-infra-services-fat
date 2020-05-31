#########################################################
# Config: deploy-all
#
# This configuration will deploy all components.
#########################################################
provider "aws" {
  profile = "default"
  region  = "eu-west-2"

  assume_role {
    role_arn = "arn:aws:iam::${var.aws_account_id}:role/CCS_SCALE_Build"
  }
}

data "aws_ssm_parameter" "vpc_id" {
  name = "${lower(var.environment)}-vpc-id"
}

data "aws_ssm_parameter" "public_web_subnet_ids" {
  name = "${lower(var.environment)}-public-web-subnet-ids"
}

data "aws_ssm_parameter" "private_app_subnet_ids" {
  name = "${lower(var.environment)}-private-app-subnet-ids"
}

data "aws_ssm_parameter" "private_db_subnet_ids" {
  name = "${lower(var.environment)}-private-db-subnet-ids"
}

data "aws_ssm_parameter" "vpc_link_id" {
  name = "${lower(var.environment)}-vpc-link-id"
}

data "aws_ssm_parameter" "lb_public_arn" {
  name = "${lower(var.environment)}-lb-public-arn"
}

data "aws_ssm_parameter" "lb_private_arn" {
  name = "${lower(var.environment)}-lb-private-arn"
}

data "aws_ssm_parameter" "lb_private_dns" {
  name = "${lower(var.environment)}-lb-private-dns"
}

module "ecs" {
  source      = "../../ecs"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
  environment = var.environment
}

module "api" {
  source      = "../../api"
  environment = var.environment
}

module "decision-tree" {
  source                       = "../../services/decision-tree"
  environment                  = var.environment
  vpc_id                       = data.aws_ssm_parameter.vpc_id.value
  private_app_subnet_ids       = split(",", data.aws_ssm_parameter.private_app_subnet_ids.value)
  private_db_subnet_ids        = split(",", data.aws_ssm_parameter.private_db_subnet_ids.value)
  vpc_link_id                  = data.aws_ssm_parameter.vpc_link_id.value
  lb_private_arn               = data.aws_ssm_parameter.lb_private_arn.value
  lb_private_dns               = data.aws_ssm_parameter.lb_private_dns.value
  scale_rest_api_id            = module.api.scale_rest_api_id
  scale_rest_api_execution_arn = module.api.scale_rest_api_execution_arn
  parent_resource_id           = module.api.parent_resource_id
  ecs_security_group_id        = module.ecs.ecs_security_group_id
  ecs_task_execution_arn       = module.ecs.ecs_task_execution_arn
  ecs_cluster_id               = module.ecs.ecs_cluster_id
}

module "guided-match" {
  source                       = "../../services/guided-match"
  environment                  = var.environment
  vpc_id                       = data.aws_ssm_parameter.vpc_id.value
  private_app_subnet_ids       = split(",", data.aws_ssm_parameter.private_app_subnet_ids.value)
  private_db_subnet_ids        = split(",", data.aws_ssm_parameter.private_db_subnet_ids.value)
  vpc_link_id                  = data.aws_ssm_parameter.vpc_link_id.value
  lb_private_arn               = data.aws_ssm_parameter.lb_private_arn.value
  lb_private_dns               = data.aws_ssm_parameter.lb_private_dns.value
  scale_rest_api_id            = module.api.scale_rest_api_id
  scale_rest_api_execution_arn = module.api.scale_rest_api_execution_arn
  parent_resource_id           = module.api.parent_resource_id
  ecs_security_group_id        = module.ecs.ecs_security_group_id
  ecs_task_execution_arn       = module.ecs.ecs_task_execution_arn
  ecs_cluster_id               = module.ecs.ecs_cluster_id
}

module "fat-buyer-ui" {
  source                       = "../../services/fat-buyer-ui"
  environment                  = var.environment
  vpc_id                       = data.aws_ssm_parameter.vpc_id.value
  private_app_subnet_ids       = split(",", data.aws_ssm_parameter.private_app_subnet_ids.value)
  private_db_subnet_ids        = split(",", data.aws_ssm_parameter.private_db_subnet_ids.value)
  vpc_link_id                  = data.aws_ssm_parameter.vpc_link_id.value
  lb_private_arn               = data.aws_ssm_parameter.lb_private_arn.value
  lb_private_dns               = data.aws_ssm_parameter.lb_private_dns.value
  lb_public_arn                = data.aws_ssm_parameter.lb_public_arn.value
  scale_rest_api_id            = module.api.scale_rest_api_id
  scale_rest_api_execution_arn = module.api.scale_rest_api_execution_arn
  parent_resource_id           = module.api.parent_resource_id
  ecs_security_group_id        = module.ecs.ecs_security_group_id
  ecs_task_execution_arn       = module.ecs.ecs_task_execution_arn
  ecs_cluster_id               = module.ecs.ecs_cluster_id
}

module "api-deployment" {
  source            = "../../services/api-deployment"
  environment       = var.environment
  scale_rest_api_id = module.api.scale_rest_api_id

  // Simulate depends_on:
  decision_tree_api_gateway_integration = module.decision-tree.decision_tree_api_gateway_integration
  guided_match_api_gateway_integration  = module.guided-match.guided_match_api_gateway_integration
}
