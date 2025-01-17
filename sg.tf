resource "aws_security_group" "app_server_sg" {
  name        = "${var.ProjectName}-${var.env}-app-server-sg"
  description = "SG of App Server"
  vpc_id      = data.aws_vpc.CloudGuru.id


  # ingress {
  #   description = "HTTP from Anywhere"
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1" # was "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]


  # }

  ingress {
    description     = "HTTP from Load Balancer "
    from_port       = 0
    to_port         = 0
    protocol        = "-1" # was "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.alb_sg.id]


  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.ProjectName}-${var.env}-app_server_sg",
    },
  )
}




resource "aws_lb" "alb" {
  name               = "${var.ProjectName}-${var.env}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = ["subnet-0ff6ef8ee6908b8e3", "subnet-0f25e0b51c1f49cb9"] #[data.aws_subnets.public_subnet-01.id, data.aws_subnets.public_subnet-02.id] 

  enable_deletion_protection = false
  drop_invalid_header_fields = true

  #   access_logs {                                           # TODO will create later
  #     bucket  = aws_s3_bucket.alb-logs.bucket
  #     prefix  = "${var.ProjectName}-alb"
  #     enabled = true
  #   }

  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.ProjectName}-${var.env}-alb",
    },
  )
}

resource "aws_security_group" "alb_sg" {
  name        = "${var.ProjectName}-${var.env}-alb-sg"
  description = "SG of ALB"
  vpc_id      = data.aws_vpc.CloudGuru.id

  ingress {
    description      = "HTTP Access from Anywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] # [aws_vpc.main.cidr_block]
    ipv6_cidr_blocks = ["::/0"]      # [aws_vpc.main.ipv6_cidr_block]
  }

  ingress {
    description      = "HTTP Access from Anywhere"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"] # [aws_vpc.main.cidr_block]
    ipv6_cidr_blocks = ["::/0"]      # [aws_vpc.main.ipv6_cidr_block]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.ProjectName}-${var.env}-alb_sg",
    },
  )
}
