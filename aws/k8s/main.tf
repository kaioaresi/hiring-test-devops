provider "aws" {
  region = "${var.REGION}"
}

terraform {
  backend "s3" {
    bucket = ""
    key    = ""
    region = ""
  }
}

locals {
  TAGS = {
    ENV = "test"
  }
}

# security group
module "security_group" {
  source = "../../modules/security_group/"
  VPC_ID = "${var.VPC_ID}"
  NAME_SEC_GROUP = "sg_${var.NAME}"
  TAGS = "${merge(
    local.TAGS, map(
      "Name", "sg-${var.NAME}"
  ))}"
}

# Ec2 master
module "ec2_master" {
  source          = "../../modules/ec2_instance/"
  SUBNET_ID       = "${var.SUBNET_ID_A}"
  SECURITY_GROUPS = ["${module.security_group.sg_id}"]
  TAGS = "${merge(
    local.TAGS, map(
      "Name", "master-1-${var.NAME}"
  ))}"
}

# Ec2 Workes autoscaling
module "autoscaling_workes" {
  source          = "../../modules/autoscaling_workes/"
  VPC_ZONE_IDENTIFIER = ["${var.SUBNET_ID_A}","${var.SUBNET_ID_B}","${var.SUBNET_ID_C}"]
  SECURITY_GROUPS = ["${module.security_group.sg_id}"]
  TAGS = "${merge(
    local.TAGS, map(
      "Name", "workes-${var.NAME}"
  ))}"
}
