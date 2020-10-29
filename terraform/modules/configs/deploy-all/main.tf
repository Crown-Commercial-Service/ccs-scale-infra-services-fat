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

data "aws_ssm_parameter" "lb_public_alb_arn" {
  name = "${lower(var.environment)}-lb-public-alb-arn"
}

data "aws_ssm_parameter" "lb_private_arn" {
  name = "${lower(var.environment)}-lb-private-arn"
}

data "aws_ssm_parameter" "lb_private_db_arn" {
  name = "${lower(var.environment)}-lb-private-db-arn"
}

data "aws_ssm_parameter" "lb_private_dns" {
  name = "${lower(var.environment)}-lb-private-dns"
}

data "aws_ssm_parameter" "lb_private_db_dns" {
  name = "${lower(var.environment)}-lb-private-db-dns"
}

data "aws_ssm_parameter" "agreements_invoke_url" {
  name = "${lower(var.environment)}-agreements-service-root-url"
}

data "aws_ssm_parameter" "guided_match_db_endpoint" {
  name = "${lower(var.environment)}-guided-match-db-endpoint"
}

data "aws_ssm_parameter" "guided_match_db_username" {
  name = "${lower(var.environment)}-guided-match-db-master-username"
}

data "aws_ssm_parameter" "guided_match_db_password" {
  name = "${lower(var.environment)}-guided-match-db-master-password"
}

data "aws_ssm_parameter" "decision_tree_db_admin_username" {
  name = "${lower(var.environment)}-decision-tree-db-admin-username"
}

data "aws_ssm_parameter" "decision_tree_db_admin_password" {
  name = "${lower(var.environment)}-decision-tree-db-admin-password"
}

data "aws_ssm_parameter" "decision_tree_db_service_account_username" {
  name = "${lower(var.environment)}-decision-tree-db-service-account-username"
}

data "aws_ssm_parameter" "decision_tree_db_service_account_password" {
  name = "${lower(var.environment)}-decision-tree-db-service-account-password"
}


data "aws_ssm_parameter" "cidr_block_vpc" {
  name = "${lower(var.environment)}-cidr-block-vpc"
}

data "aws_ssm_parameter" "shared_api_key" {
  name = "${lower(var.environment)}-fat-buyer-ui-shared-api-key"
}

data "aws_ssm_parameter" "cloudfront_id" {
  name = "${lower(var.environment)}-cloudfront-id"
}

module "ecs" {
  source         = "../../ecs"
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
  environment    = var.environment
  cidr_block_vpc = data.aws_ssm_parameter.cidr_block_vpc.value
}

module "api" {
  source      = "../../api"
  environment = var.environment
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
}

module "decision-tree" {
  source                                        = "../../services/decision-tree"
  environment                                   = var.environment
  vpc_id                                        = data.aws_ssm_parameter.vpc_id.value
  private_app_subnet_ids                        = split(",", data.aws_ssm_parameter.private_app_subnet_ids.value)
  private_db_subnet_ids                         = split(",", data.aws_ssm_parameter.private_db_subnet_ids.value)
  vpc_link_id                                   = data.aws_ssm_parameter.vpc_link_id.value
  lb_private_arn                                = data.aws_ssm_parameter.lb_private_arn.value
  lb_private_dns                                = data.aws_ssm_parameter.lb_private_dns.value
  lb_private_db_dns                             = data.aws_ssm_parameter.lb_private_db_dns.value
  scale_rest_api_id                             = module.api.scale_rest_api_id
  scale_rest_api_execution_arn                  = module.api.scale_rest_api_execution_arn
  parent_resource_id                            = module.api.parent_resource_id
  ecs_security_group_id                         = module.ecs.ecs_security_group_id
  ecs_task_execution_arn                        = module.ecs.ecs_task_execution_arn
  ecs_cluster_id                                = module.ecs.ecs_cluster_id
  decision_tree_service_cpu                     = var.decision_tree_service_cpu
  decision_tree_service_memory                  = var.decision_tree_service_memory
  decision_tree_db_service_account_username_arn = data.aws_ssm_parameter.decision_tree_db_service_account_username.arn
  decision_tree_db_service_account_password_arn = data.aws_ssm_parameter.decision_tree_db_service_account_password.arn
  ecr_image_id_decision_tree                    = var.ecr_image_id_decision_tree
  ecs_log_retention_in_days                     = var.ecs_log_retention_in_days
}

module "decision-tree-db" {
  source                                        = "../../services/decision-tree-db"
  environment                                   = var.environment
  vpc_id                                        = data.aws_ssm_parameter.vpc_id.value
  private_db_subnet_ids                         = split(",", data.aws_ssm_parameter.private_db_subnet_ids.value)
  lb_private_db_arn                             = data.aws_ssm_parameter.lb_private_db_arn.value
  ecs_security_group_id                         = module.ecs.ecs_security_group_id
  ecs_task_execution_arn                        = module.ecs.ecs_task_execution_arn
  ecs_cluster_id                                = module.ecs.ecs_cluster_id
  decision_tree_db_cpu                          = var.decision_tree_db_cpu
  decision_tree_db_memory                       = var.decision_tree_db_memory
  decision_tree_db_admin_username_arn           = data.aws_ssm_parameter.decision_tree_db_admin_username.arn
  decision_tree_db_admin_password_arn           = data.aws_ssm_parameter.decision_tree_db_admin_password.arn
  decision_tree_db_service_account_username_arn = data.aws_ssm_parameter.decision_tree_db_service_account_username.arn
  decision_tree_db_service_account_password_arn = data.aws_ssm_parameter.decision_tree_db_service_account_password.arn
  ecr_image_id_decision_tree_db                 = var.ecr_image_id_decision_tree_db
  ecs_log_retention_in_days                     = var.ecs_log_retention_in_days
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
  guided_match_db_endpoint     = data.aws_ssm_parameter.guided_match_db_endpoint.value
  guided_match_db_username_arn = data.aws_ssm_parameter.guided_match_db_username.arn
  guided_match_db_password_arn = data.aws_ssm_parameter.guided_match_db_password.arn
  guided_match_cpu             = var.guided_match_cpu
  guided_match_memory          = var.guided_match_memory
  ecr_image_id_guided_match    = var.ecr_image_id_guided_match
  ecs_log_retention_in_days    = var.ecs_log_retention_in_days
}

module "api-deployment" {
  source                       = "../../services/api-deployment"
  environment                  = var.environment
  scale_rest_api_id            = module.api.scale_rest_api_id
  api_rate_limit               = var.api_rate_limit
  api_burst_limit              = var.api_burst_limit
  api_gw_log_retention_in_days = var.api_gw_log_retention_in_days
  scale_rest_api_policy_json   = module.api.scale_rest_api_policy_json

  // Simulate depends_on:
  decision_tree_api_gateway_integration = module.decision-tree.decision_tree_api_gateway_integration
  guided_match_api_gateway_integration  = module.guided-match.guided_match_api_gateway_integration
}

module "fat-buyer-ui" {
  source                    = "../../services/fat-buyer-ui"
  environment               = var.environment
  vpc_id                    = data.aws_ssm_parameter.vpc_id.value
  private_app_subnet_ids    = split(",", data.aws_ssm_parameter.private_app_subnet_ids.value)
  lb_public_alb_arn         = data.aws_ssm_parameter.lb_public_alb_arn.value
  ecs_security_group_id     = module.ecs.ecs_security_group_id
  ecs_task_execution_arn    = module.ecs.ecs_task_execution_arn
  ecs_cluster_id            = module.ecs.ecs_cluster_id
  ecr_image_id_fat_buyer_ui = var.ecr_image_id_fat_buyer_ui
  agreements_invoke_url     = data.aws_ssm_parameter.agreements_invoke_url.value
  api_invoke_url            = module.api-deployment.api_invoke_url
  shared_api_key_arn        = data.aws_ssm_parameter.shared_api_key.arn
  fat_api_key_arn           = module.api-deployment.fat_api_key_ssm_param_arn
  webcms_root_url           = var.webcms_root_url
  buyer_ui_cpu              = var.buyer_ui_cpu
  buyer_ui_memory           = var.buyer_ui_memory
  cloudfront_id             = data.aws_ssm_parameter.cloudfront_id.value
  ecs_log_retention_in_days = var.ecs_log_retention_in_days
}


module "cloudwatch-alarms-guided-match" {
  source                  = "../../cw-alarms"
  environment             = var.environment
  ecs_cluster_name        = module.ecs.ecs_cluster_name
  ecs_service_name        = module.guided-match.ecs_service_name
  service_name            = "guided-match"
  ecs_expected_task_count = length(split(",", data.aws_ssm_parameter.private_app_subnet_ids.value))
}

module "cloudwatch-alarms-decision-tree" {
  source                  = "../../cw-alarms"
  environment             = var.environment
  ecs_cluster_name        = module.ecs.ecs_cluster_name
  ecs_service_name        = module.decision-tree.ecs_service_name
  service_name            = "decision-tree"
  ecs_expected_task_count = length(split(",", data.aws_ssm_parameter.private_app_subnet_ids.value))
}

module "cloudwatch-alarms-fat-buyer-ui" {
  source                  = "../../cw-alarms"
  environment             = var.environment
  ecs_cluster_name        = module.ecs.ecs_cluster_name
  ecs_service_name        = module.fat-buyer-ui.ecs_service_name
  service_name            = "fat-buyer-ui"
  ecs_expected_task_count = length(split(",", data.aws_ssm_parameter.private_app_subnet_ids.value))
}
