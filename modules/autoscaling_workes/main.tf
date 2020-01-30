data "aws_ami" "ami_ubuntu" {
  owners      = ["amazon"]
  most_recent = true
  name_regex  = "ubuntu"
}

resource "aws_launch_template" "workes" {
  name_prefix   = "workes-"
  image_id      = "${data.aws_ami.ami_ubuntu.id}"
  instance_type = "${var.INSTANCE_TYPE}"
  key_name      = "lab"
  user_data     = "${base64encode(file("${path.module}/setup.sh"))}"
  tags          = "${var.TAGS}"

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 50
    }
  }

  network_interfaces {
    security_groups = "${var.SECURITY_GROUPS}"
  }
}

resource "aws_autoscaling_group" "autoscaling" {
  #  availability_zones = ["us-east-1a"]
  desired_capacity    = 2
  max_size            = 2
  min_size            = 2
  vpc_zone_identifier = "${var.VPC_ZONE_IDENTIFIER}"
  default_cooldown    = "5"
  health_check_type = "EC2"
  termination_policies = ["OldestInstance","OldestLaunchTemplate"]
  launch_template {
    id      = "${aws_launch_template.workes.id}"
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }
}
