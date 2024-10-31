data "template_file" "user_data" {
  template = file("${path.module}/user_data.tpl")
  vars = {
    db_port     = 3306
    db_host     = aws_db_instance.database.address
    db_name     = aws_db_instance.database.db_name
    db_username = aws_db_instance.database.username
    db_password = aws_db_instance.database.password
    aws_region  = var.aws_region
    aws_s3_bucket = aws_s3_bucket.bucket.bucket
  }
}

# Create the EC2 instance using the latest AMI
resource "aws_instance" "web_app" {
  ami                    = var.custom_ami_id
  instance_type          = var.instance_type # e.g., t2.micro

  # Attach the Application Security Group
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data              = data.template_file.user_data.rendered

  # Add key_name to associate the key pair for SSH access
  key_name = "My-default-key" # Replace with the actual name of your key pair
  iam_instance_profile = aws_iam_instance_profile.ec2_s3_profile.name

  # EC2 instance root volume configuration
  root_block_device {
    volume_size           = 25
    volume_type           = "gp2"
    delete_on_termination = true # Ensure volume is deleted when the instance is terminated
  }

  # Launch the EC2 instance in the public subnet
  subnet_id = aws_subnet.public_subnet[0].id

  # Disable termination protection
  disable_api_termination = false

  tags = {
    Name = "web-app-instance"
  }
}

resource "aws_iam_policy" "webapp_s3_policy" {
  name        = "WebAppS3"
  path        = "/"
  description = "Allow webapp s3 access"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        "Action" : [
          "s3:DeleteObject",
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:s3:::${aws_s3_bucket.bucket.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.bucket.bucket}/*"
        ]
      }
    ]
  })

  tags = {
    Name = "WebAppS3"
  }
}

resource "aws_iam_role" "webapp_ec2_access_role" {
  name = "EC2-CSYE6225"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "EC2-CSYE6225"
  }
}

data "aws_iam_policy" "webapp_cloudwatch_server_policy" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_policy_attachment" "ec2_s3_policy_role" {
  name       = "webapp_s3_attachment"
  roles      = [aws_iam_role.webapp_ec2_access_role.name]
  policy_arn = aws_iam_policy.webapp_s3_policy.arn
}

resource "aws_iam_policy_attachment" "ec2_cloudwatch_policy_role" {
  name       = "webapp_cloudwatch_policy"
  roles      = [aws_iam_role.webapp_ec2_access_role.name]
  policy_arn = data.aws_iam_policy.webapp_cloudwatch_server_policy.arn
}

resource "aws_iam_instance_profile" "ec2_s3_profile" {
  name = "webapp_s3_profile"
  role = aws_iam_role.webapp_ec2_access_role.name
}