provider "aws" {
  region = var.aws_region
}
resource "aws_instance" "app_server_ec2" {
  ami                    = "ami-067d1e60475437da2" # data.aws_ami.amazon_linux.id
  instance_type          = var.app_server_instance_type
  subnet_id              = var.subnet_id
  monitoring             = false
  vpc_security_group_ids = [aws_security_group.app_server_sg.id]
  user_data              = filebase64("user_data.sh")
  



  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.ProjectName}-${var.env}-ec2",
    },
  )
}