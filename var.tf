
variable "app_server_instance_type" {
  default     = "t2.micro"
  description = "App Server Instance Type"

}
variable "subnet_id" {
  default = "subnet-031413dc70965a163"

}
variable "aws_region" {
  default = "us-east-1"

}
variable "security_groups" {
  default = "sg-0808765a5f1649fbb"

}


locals {
  common_tags = {
    Environment = var.env
    Project     = var.ProjectName
    ManagedBy   = var.ManagedBy
  }
}


variable "ProjectName" {
  description = "Name of the project"
}

variable "env" {
  description = "Environment"
}

variable "ManagedBy" {
  description = "Who is managing this project"
}

variable "vpc_id" {
  default = "vpc-02908506baf74a861"

}

######## DATA 

data "aws_ami" "amazon_linux" { # TODO
  most_recent = true

}

data "aws_vpc" "CloudGuru" { # Custom VPC
  id = var.vpc_id
}

data "aws_iam_role" "ssm_role" {
  name = "SSMRoleForEC2"
}