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

variable "environment" {
  type = string
}

variable "guided_match_db_endpoint" {
  type = string
}

variable "guided_match_db_username" {
  type = string
}

variable "guided_match_db_password" {
  type = string
}

variable "guided_match_cpu" {
  type = number
}

variable "guided_match_memory" {
  type = number
}
