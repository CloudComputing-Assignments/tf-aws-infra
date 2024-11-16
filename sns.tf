resource "aws_sns_topic" "verify_email" {
  name = "verify_email"
}

resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = aws_sns_topic.verify_email.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.verify_email_lambda.arn

  # Ensure Lambda permission is in place
  depends_on = [aws_lambda_permission.allow_sns]
}
