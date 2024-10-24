data "template_file" "user_data" {
  template = file("${path.module}/user_data.tpl")

  vars = {
    db_port     = 3306
    db_host     = aws_db_instance.database.address
    db_name     = aws_db_instance.database.db_name
    db_username = aws_db_instance.database.username
    db_password = aws_db_instance.database.password
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
