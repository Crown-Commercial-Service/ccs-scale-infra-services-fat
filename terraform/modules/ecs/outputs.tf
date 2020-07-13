output "ecs_security_group_id" {
  value = aws_security_group.allow_http.id
}

output "ecs_task_execution_arn" {
  value = aws_iam_role.ecs_task_execution.arn
}

output "ecs_cluster_id" {
  value = aws_ecs_cluster.scale.id
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.scale.name
}
