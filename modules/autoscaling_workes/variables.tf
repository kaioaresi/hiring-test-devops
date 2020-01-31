variable "INSTANCE_TYPE" {
  default = "t2.medium"
}

variable "IMAGE_ID" {
  default = "ami-0ff994e0f64f369ed"
}

variable "TAGS" {
  type    = map(string)
  default = {}
}

variable "VPC_ZONE_IDENTIFIER" {
  type    = list
  default = []
}

variable "SECURITY_GROUPS" {
  type    = list
  default = []
}
