output "ec2_public_ip" {
  value = "${aws_instance.app_server_ec2.public_ip}"     # try(aws_instance.app_server_ec2.public_ip)
}