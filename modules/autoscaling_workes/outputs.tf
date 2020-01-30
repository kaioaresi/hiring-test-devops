output "aws_launch_template_id" {
  value = "${aws_launch_template.workes.id}"
}

output "aws_autoscaling_group_id" {
  value = "${aws_autoscaling_group.autoscaling.id}"
}
