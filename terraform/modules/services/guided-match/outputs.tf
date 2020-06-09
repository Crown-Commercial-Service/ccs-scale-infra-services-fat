output "guided_match_api_gateway_integration" {
  value = aws_api_gateway_integration.guided_match_proxy.http_method
}
