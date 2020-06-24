variable "scale_rest_api_id" {
  type = string
}

resource "aws_api_gateway_deployment" "fat" {
  description = "Deployed at ${timestamp()}"
  rest_api_id = var.scale_rest_api_id
  stage_name = lower(var.environment)

  depends_on = [
    var.decision_tree_api_gateway_integration,
    var.guided_match_api_gateway_integration,
    var.guided_match_api_gateway_integration
  ]

  lifecycle {
    create_before_destroy = true
  }
}

//resource "aws_api_gateway_stage" "fat" {
//  description = "Deployed at ${timestamp()}"
  //depends_on = [
  //  aws_cloudwatch_log_group.api_gw_execution
  //]

//  stage_name    = lower(var.environment)
//  rest_api_id   = var.scale_rest_api_id
//  deployment_id = aws_api_gateway_deployment.fat.id
//}

resource "aws_api_gateway_method_settings" "scale" {
  rest_api_id = var.scale_rest_api_id
  //stage_name  = aws_api_gateway_stage.fat.stage_name
  stage_name  = lower(var.environment)
  method_path = "*/*"
  settings {
    logging_level      = "INFO"
    data_trace_enabled = true
    metrics_enabled    = true
  }
}

//resource "aws_cloudwatch_log_group" "api_gw_execution" {
//  name              = "API-Gateway-Execution-Logs_${var.scale_rest_api_id}/${lower(var.environment)}-fat-2"
//  retention_in_days = 7
//}
