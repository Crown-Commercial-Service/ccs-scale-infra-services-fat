variable "ecr_image_id_fat_buyer_ui" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_app_subnet_ids" {
  type = list(string)
}

variable "ecs_cluster_id" {
  type = string
}

variable "ecs_security_group_id" {
  type = string
}

variable "ecs_task_execution_arn" {
  type = string
}

variable "lb_public_arn" {
  type = string
}

variable "environment" {
  type = string
}

variable "api_invoke_url" {
  type = string
}

variable "agreements_invoke_url" {
  type = string
}

variable "fat_api_key_arn" {
  type = string
}

variable "shared_api_key_arn" {
  type = string
}

variable "webcms_root_url" {
  type = string
}

variable "buyer_ui_cpu" {
  type = number
}

variable "buyer_ui_memory" {
  type = number
}
