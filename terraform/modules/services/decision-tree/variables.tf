variable "scale_rest_api_id" {
  type = string
}

variable "scale_rest_api_execution_arn" {
  type = string
}

variable "parent_resource_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_app_subnet_ids" {
  type = list(string)
}

variable "private_db_subnet_ids" {
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

variable "vpc_link_id" {
  type = string
}

variable "lb_private_arn" {
  type = string
}

variable "lb_private_dns" {
  type = string
}

variable "lb_private_db_dns" {
  type = string
}

variable "environment" {
  type = string
}

variable "decision_tree_service_cpu" {
  type = number
}

variable "decision_tree_service_memory" {
  type = number
}

variable "decision_tree_db_service_account_username_arn" {
  type = string
}

variable "decision_tree_db_service_account_password_arn" {
  type = string
}
