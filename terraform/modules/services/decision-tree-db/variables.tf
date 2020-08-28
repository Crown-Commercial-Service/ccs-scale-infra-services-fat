variable "vpc_id" {
  type = string
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

variable "lb_private_db_arn" {
  type = string
}

variable "environment" {
  type = string
}

variable "decision_tree_db_cpu" {
  type = number
}

variable "decision_tree_db_memory" {
  type = number
}

variable "decision_tree_db_admin_username_arn" {
  type = string
}

variable "decision_tree_db_admin_password_arn" {
  type = string
}

variable "decision_tree_db_service_account_username_arn" {
  type = string
}

variable "decision_tree_db_service_account_password_arn" {
  type = string
}

variable "ecr_image_id_decision_tree_db" {
  type = string
}
