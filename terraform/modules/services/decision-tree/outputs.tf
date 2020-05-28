output "decision_tree_api_gateway_integration" {
  value = aws_api_gateway_integration.decision_tree_proxy.http_method
}
