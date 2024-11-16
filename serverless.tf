resource "aws_lambda_function" "verify_email_lambda" {
  filename      = "./serverless.zip"
  function_name = "verify_email_lambda"
  handler       = "serverless/index.helloSNS"
  runtime       = "nodejs20.x" 
  role          = aws_iam_role.lambda_execution_role.arn
  timeout       = 10

  environment {
    variables = {
      db_port      = 3306
      db_host      = aws_db_instance.database.address
      db_name      = aws_db_instance.database.db_name
      db_username  = aws_db_instance.database.username
      db_password  = aws_db_instance.database.password
      SENDGRID_API_KEY = var.sendgrid_api
    }
  }

  vpc_config {
    security_group_ids = [aws_security_group.app_sg.id]
    subnet_ids = [for subnet in aws_subnet.public_subnet : subnet.id]
  }
}

# resource "aws_iam_role" "lambda_execution_role" {
#   name = "lambda_execution_role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }

resource "aws_iam_policy" "lambda_vpc_access_policy" {
  name        = "lambda_vpc_access_policy"
  path        = "/"
  description = "IAM policy for Lambda VPC access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_sns_policy" {
  name        = "lambda_sns_policy"
  description = "IAM policy for Lambda to access SNS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish",
          "sns:Subscribe",
          "sns:ListSubscriptionsByTopic"
        ]
        Resource = aws_sns_topic.verify_email.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_sns_access" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_sns_policy.arn
}


resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_vpc_access_policy.arn
}

resource "aws_iam_policy_attachment" "basic_execution_role" {
  name       = "basic_execution_role_attachment"
  roles      = [aws_iam_role.lambda_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy_attachment" "cloudwatch_logs_policy" {
  name       = "cloudwatch_logs_policy_attachment"
  roles      = [aws_iam_role.lambda_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}


# Lambda permission to allow SNS to invoke it
resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  principal     = "sns.amazonaws.com"
  function_name = aws_lambda_function.verify_email_lambda.function_name
  source_arn    = aws_sns_topic.verify_email.arn
}
