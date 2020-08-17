#########################################################
# Cloudwatch: Alarms
#
# Create performance alarms.
#########################################################

resource "aws_sns_topic" "alarms" {
  name = "CCS-EU2-${upper(var.environment)}-CW-ALARMS-${upper(var.service_name)}"
}

resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name                = "${lower(var.service_name)}-service-cpu-alarm"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/ECS"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors cpu utilization"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alarms.arn]

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }
}

resource "aws_cloudwatch_metric_alarm" "memory" {
  alarm_name                = "${lower(var.service_name)}-service-memory-alarm"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "MemoryUtilization"
  namespace                 = "AWS/ECS"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors cpu utilization"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alarms.arn]

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }
}

resource "aws_cloudwatch_metric_alarm" "task" {
  alarm_name                = "${lower(var.service_name)}-service-task-alarm"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "MemoryUtilization"
  namespace                 = "AWS/ECS"
  period                    = "60"
  statistic                 = "SampleCount"
  threshold                 = var.ecs_expected_task_count
  alarm_description         = "This metric monitors task removals"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alarms.arn]

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }
}
