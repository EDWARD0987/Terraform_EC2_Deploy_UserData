variable "app_server_instance_type" {
  default     = "t2.micro"
  description = "App Server Instance Type"

}
variable "subnet_id" {
  default = "subnet-0f25e0b51c1f49cb9" #   TODO"subnet-031413dc70965a163"

}
variable "aws_region" {
  default = "us-east-1"

}
variable "security_groups" {
  default = "sg-0808765a5f1649fbb"

}

variable "instance_type" {
  default = "t2.micro" # FOR TEST
}

variable "region" {
  default = "us-east-1" # FOR TEST
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
  default ="vpc-0e332f3b9d2eb8bf3"  # TODO => old vpc  "vpc-02908506baf74a861"

}

######## DATA 

data "aws_ami" "amazon_linux" { # TODO
  most_recent = true

}

data "aws_vpc" "CloudGuru" { # Custom VPC
  id = var.vpc_id
}


data "aws_iam_instance_profile" "ssm_role" { # This is how you attach an already existing role to an ec2 instance
  name = "SSMRoleForEC2"

}

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