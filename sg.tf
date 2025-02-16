
# APPLICATION Server security group
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



# ALB Resource
resource "aws_lb" "alb" {
  name               = "${var.ProjectName}-${var.env}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id, aws_security_group.app_server_sg.id]
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


# ALB Listener
resource "aws_lb_listener" "public-proxy" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public-proxy.arn
    
  
  }
}

# resource "aws_lb_listener" "public-proxy" {
#   load_balancer_arn = aws_lb.alb.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type = "fixed-response"

#     fixed_response {
#       content_type = "text/plain"
#       message_body = "This is the default response"
#       status_code  = "200"
#     }
#   }
# }


# ALB Target group
resource "aws_lb_target_group" "public-proxy" {
  name     = "${var.env}-public-proxy"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    port                = 80
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    matcher             = "200-499"
    path                = "/"
  }

  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.ProjectName}-${var.env}-public-proxy",
    },
  )
}

# Register Targets
resource "aws_lb_target_group_attachment" "example" {
  target_group_arn = aws_lb_target_group.public-proxy.arn
  target_id        = aws_instance.app_server_ec2.id        # or the IP address
  port             = 80
}



# ALB Security group
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
