variable "aws_account_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "ecr_image_id_fat_buyer_ui" {
  type    = string
  default = "15f5f1f-candidate"
}

variable "ecr_image_id_guided_match" {
  type    = string
  default = "43f53ae-candidate"
}

variable "ecr_image_id_decision_tree" {
  type    = string
  default = "cb0ab58-candidate"
}

variable "ecr_image_id_decision_tree_db" {
  type    = string
  default = "f9c22b3-candidate"
}

variable "decision_tree_service_cpu" {
  type    = number
  default = 512
}

variable "decision_tree_service_memory" {
  type    = number
  default = 1024
}

variable "decision_tree_db_cpu" {
  type    = number
  default = 512
}

variable "decision_tree_db_memory" {
  type    = number
  default = 1024
}

variable "guided_match_cpu" {
  type    = number
  default = 256
}

variable "guided_match_memory" {
  type    = number
  default = 512
}

variable "buyer_ui_cpu" {
  type    = number
  default = 256
}

variable "buyer_ui_memory" {
  type    = number
  default = 512
}

variable "api_rate_limit" {
  type    = number
  default = 100
}

variable "api_burst_limit" {
  type    = number
  default = 50
}

variable "webcms_root_url" {
  type = string

  # Default to the DEV CMS
  default = "https://webdev-cms.crowncommercial.gov.uk"
}

variable "api_gw_log_retention_in_days" {
  type    = number
  default = 7
}

variable "ecs_log_retention_in_days" {
  type    = number
  default = 7
}
