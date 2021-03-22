#########################################################
# Service: API Deployments
#
# Creates Usage Plan/API Keys and deployment.
#########################################################

#########################################################
# Deployment
#########################################################
resource "aws_api_gateway_deployment" "fat" {
  description = "Deployed at ${timestamp()}"
  rest_api_id = var.scale_rest_api_id

  depends_on = [
    var.decision_tree_api_gateway_integration,
    var.guided_match_api_gateway_integration,
    var.guided_match_api_gateway_integration
  ]

  triggers = {
    redeployment = sha1(var.scale_rest_api_policy_json)
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "fat" {
  description = "Deployed at ${timestamp()}"
  depends_on = [
    aws_cloudwatch_log_group.api_gw_execution
  ]

  stage_name    = lower(var.environment)
  rest_api_id   = var.scale_rest_api_id
  deployment_id = aws_api_gateway_deployment.fat.id
}

resource "aws_api_gateway_method_settings" "scale" {
  rest_api_id = var.scale_rest_api_id
  stage_name  = aws_api_gateway_stage.fat.stage_name
  method_path = "*/*"
  settings {
    logging_level      = "INFO"
    data_trace_enabled = true
    metrics_enabled    = true
  }
}

resource "aws_cloudwatch_log_group" "api_gw_execution" {
  name              = "API-Gateway-Execution-Logs_${var.scale_rest_api_id}/${lower(var.environment)}-fat"
  retention_in_days = var.api_gw_log_retention_in_days
}

#########################################################
# Usage Plans
#########################################################
resource "aws_api_gateway_usage_plan" "default" {
  name        = "default-usage-plan-fat"
  description = "Default Usage Plan"

  api_stages {
    api_id = var.scale_rest_api_id
    stage  = aws_api_gateway_stage.fat.stage_name
  }

  throttle_settings {
    rate_limit  = var.api_rate_limit
    burst_limit = var.api_burst_limit
  }
}

#########################################################
# API Keys
#########################################################
resource "aws_api_gateway_api_key" "fat_buyer_ui" {
  name = "FaT Buyer UI API Key (FaT)"
}

resource "aws_api_gateway_api_key" "ccs_website" {
  name = "CCS Website API Key (FaT)"
}

resource "aws_api_gateway_api_key" "fat_testers" {
  name = "FaT Testers API Key (FaT)"
}

resource "aws_api_gateway_api_key" "fat_developers" {
  name = "FaT Developers API Key (FaT)"
}

data "aws_ssm_parameter" "kms_id_ssm" {
  name = "${lower(var.environment)}-ssm-encryption-key"
}

resource "aws_ssm_parameter" "fat_buyer_ui_api_key" {
  name        = "${lower(var.environment)}-fat-buyer-ui-fat-api-key"
  description = "API Key for FaT Buyer UI component to use to access the Guided Match API (Guied Match Service)"
  type        = "SecureString"
  value       = aws_api_gateway_api_key.fat_buyer_ui.value
  key_id      = data.aws_ssm_parameter.kms_id_ssm.value
}

resource "aws_ssm_parameter" "ccs_website_api_key" {
  name        = "${lower(var.environment)}-ccs-website-fat-api-key"
  description = "API Key for CCS website to use to access the Guided Match API (Guided Match Service)"
  type        = "SecureString"
  value       = aws_api_gateway_api_key.ccs_website.value
  key_id      = data.aws_ssm_parameter.kms_id_ssm.value
}

resource "aws_api_gateway_usage_plan_key" "fat_buyer_ui" {
  key_id        = aws_api_gateway_api_key.fat_buyer_ui.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.default.id
}

resource "aws_api_gateway_usage_plan_key" "ccs_website" {
  key_id        = aws_api_gateway_api_key.ccs_website.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.default.id
}

resource "aws_api_gateway_usage_plan_key" "fat_testers" {
  key_id        = aws_api_gateway_api_key.fat_testers.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.default.id
}

resource "aws_api_gateway_usage_plan_key" "fat_developers" {
  key_id        = aws_api_gateway_api_key.fat_developers.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.default.id
}
