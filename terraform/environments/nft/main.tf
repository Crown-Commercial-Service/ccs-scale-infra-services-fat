#########################################################
# Environment: NFT (Non Functional Testing)
#
# Deploy SCALE resources
#########################################################
terraform {
  backend "s3" {
    bucket         = "scale-terraform-state"
    key            = "ccs-scale-infra-services-fat-nft"
    region         = "eu-west-2"
    dynamodb_table = "scale_terraform_state_lock"
    encrypt        = true
  }
}

provider "aws" {
  profile = "default"
  version = "~> 4.0.0"
  region  = "eu-west-2"
}

locals {
  environment = "NFT"
}

data "aws_ssm_parameter" "aws_account_id" {
  name = "account-id-${lower(local.environment)}"
}

module "deploy" {
  source                       = "../../modules/configs/deploy-all"
  aws_account_id               = data.aws_ssm_parameter.aws_account_id.value
  environment                  = local.environment
  decision_tree_service_cpu    = 1024
  decision_tree_service_memory = 2048
  decision_tree_db_cpu         = 1024
  decision_tree_db_memory      = 2048
  guided_match_cpu             = 1024
  guided_match_memory          = 2048
  buyer_ui_cpu                 = 1024
  buyer_ui_memory              = 2048
  webcms_root_url              = "https://webuat-cms.crowncommercial.gov.uk/" # Pre-prod
  api_gw_log_retention_in_days = 30
  ecs_log_retention_in_days    = 30
}
