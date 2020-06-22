
output "api_invoke_url" {
  value = aws_api_gateway_stage.fat.invoke_url
}

output "fat_api_key" {
  value = aws_api_gateway_api_key.fat_buyer_ui.value
}
