#########################################################
# API Deployment: FaT
#
# Deploy updated API Gateway.
#########################################################
resource "aws_api_gateway_deployment" "fat" {
  description = "Deployed at ${timestamp()}"
  rest_api_id = var.scale_rest_api_id
  stage_name = lower(var.environment)

  depends_on = [
    var.decision_tree_api_gateway_integration,
    var.guided_match_api_gateway_integration
  ]

  # This will force a deployment of the updated API
  variables = {
    deployed_at = "${timestamp()}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_method_settings" "scale" {
  rest_api_id = var.scale_rest_api_id
  stage_name  = lower(var.environment)
  method_path = "*/*"
  settings {
    logging_level      = "INFO"
    data_trace_enabled = true
    metrics_enabled    = true
  }
}
