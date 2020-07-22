
output "api_invoke_url" {
  value = aws_api_gateway_stage.fat.invoke_url
}

output "fat_api_key_ssm_param_arn" {
  value = aws_ssm_parameter.fat_buyer_ui_api_key.arn
}
