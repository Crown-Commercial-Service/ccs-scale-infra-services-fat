variable "aws_account_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "ecr_image_id_fat_buyer_ui" {
  type    = string
  default = "0c90781-candidate"
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

variable "api_rate_limit" {
  type    = number
  default = 10000
}

variable "api_burst_limit" {
  type    = number
  default = 5000
}
