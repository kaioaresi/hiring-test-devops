output "sg_id" {
  value = "${module.security_group.sg_id}"
}

output "ec2_master_id" {
  value = "${module.ec2_master.ec2_id}"
}

output "launch_workes" {
  value = "${module.autoscaling_workes.aws_launch_template_id}"
}

output "autoscaling_workes" {
  value = "${module.autoscaling_workes.aws_autoscaling_group_id}"
}
