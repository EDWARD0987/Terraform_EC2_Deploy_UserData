
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}



provider "aws" {
  region = var.aws_region
  shared_config_files = ["~/.aws/config"]
  shared_credentials_files = ["~/.aws/credentials"]
  #profile = "account-sandbox"
}

data "aws_caller_identity" "current" {}

# EC2 Instance resource
resource "aws_instance" "app_server_ec2" {
  ami                    = data.aws_ami.amazon_linux.id    #"ami-067d1e60475437da2" 
  instance_type          = var.app_server_instance_type
  subnet_id              = var.subnet_id
  monitoring             = false
  vpc_security_group_ids = [aws_security_group.app_server_sg.id]
  user_data              = filebase64("user_data.sh")
  iam_instance_profile   = data.aws_iam_instance_profile.ssm_role.role_name # Attach role created in var.tf here for role to populate on ec2
  security_groups = [aws_security_group.app_server_sg.id, aws_security_group.alb_sg.id]
 




  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.ProjectName}-${var.env}-ec2"
    },
  )
}



# s3 resource creation
resource "aws_s3_bucket" "example" {
  bucket = "${data.aws_caller_identity.current.account_id}-${var.ProjectName}"
  
  tags = {
    Name        = "ExampleBucket"
    CreatedBy   = data.aws_caller_identity.current.arn
  }
}

# SNS Topic resource
resource "aws_sns_topic" "example" {
  name = "${data.aws_caller_identity.current.account_id}-example-topic"
  
  tags = {
    Name        = "ExampleTopic"
    CreatedBy   = data.aws_caller_identity.current.arn
  }
}


# SNS Topic policy
resource "aws_sns_topic_policy" "example" {
  arn    = aws_sns_topic.example.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "SNS:Publish"
        Resource  = aws_sns_topic.example.arn
        Condition = {
          StringEquals = {
            "AWS:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}