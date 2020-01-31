resource "aws_instance" "master" {

  ami             = "${var.AMI}"
  instance_type   = "${var.INSTANCE_TYPE_MASTER}"
  key_name        = "lab"
  subnet_id       = "${var.SUBNET_ID}"
  security_groups = "${var.SECURITY_GROUPS}"
  tags            = "${var.TAGS}"
  user_data       = file("${path.module}/setup.sh")

  root_block_device {
    volume_size = "30"
  }

  #provisioner "local-exec" {
  #  command = "echo ${aws_instance.master.private_ip} >> private_ips.txt"
  #}

  lifecycle {
    ignore_changes        = all
    create_before_destroy = true
  }
}
