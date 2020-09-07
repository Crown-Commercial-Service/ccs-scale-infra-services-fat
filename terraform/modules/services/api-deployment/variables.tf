variable "environment" {
  type = string
}

variable "scale_rest_api_id" {
  type = string
}

variable "decision_tree_api_gateway_integration" {
  type = string
}

variable "guided_match_api_gateway_integration" {
  type = string
}

variable "api_rate_limit" {
  type = number
}

variable "api_burst_limit" {
  type = number
}

variable "api_gw_log_retention_in_days" {
  type = number
}
