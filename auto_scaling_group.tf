resource "aws_autoscaling_group" "asg" {
  name                = "csye6225_asg"
  max_size            = var.asg_max_size
  min_size            = var.asg_min_size
  desired_capacity    = var.asg_desired_capacity
  force_delete        = true
  default_cooldown    = var.asg_default_cooldown
  vpc_zone_identifier = [for subnet in aws_subnet.public_subnet : subnet.id]
  tag {
    key                 = "Name"
    value               = "WebApp ASG Instance"
    propagate_at_launch = true
  }
  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.alb_tg.arn]
}

resource "aws_autoscaling_policy" "scale-out" {
  name                   = "csye6225-asg-scale-out"
  scaling_adjustment     = var.scaling_out_adjustment
  adjustment_type        = "ChangeInCapacity"
  cooldown               = var.asg_default_cooldown
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_cloudwatch_metric_alarm" "scale-out" {
  alarm_name          = "csye6225-asg-scale-out"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.scaling_evaluation_period
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.scaling_period
  statistic           = "Average"
  threshold           = var.scale_out_threshold
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.scale-out.arn]
}

resource "aws_autoscaling_policy" "scale-in" {
  name                   = "csye6225-asg-scale-in"
  scaling_adjustment     = var.scaling_in_adjustment
  adjustment_type        = "ChangeInCapacity"
  cooldown               = var.asg_default_cooldown
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_cloudwatch_metric_alarm" "scale-in" {
  alarm_name          = "csye6225-asg-scale-in"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.scaling_evaluation_period
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.scaling_period
  statistic           = "Average"
  threshold           = var.scale_in_threshold
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.scale-in.arn]
}