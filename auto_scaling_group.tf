resource "aws_autoscaling_group" "asg" {
  name                = "csye6225-asg-fall2024"
  max_size            = 5
  min_size            = 3
  desired_capacity    = 3
  force_delete        = true
  default_cooldown    = 60
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
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_cloudwatch_metric_alarm" "scale-out" {
  alarm_name          = "csye6225-asg-scale-out"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 9
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.scale-out.arn]
}

resource "aws_autoscaling_policy" "scale-in" {
  name                   = "csye6225-asg-scale-in"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_cloudwatch_metric_alarm" "scale-in" {
  alarm_name          = "csye6225-asg-scale-in"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 7.5
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.scale-in.arn]
}