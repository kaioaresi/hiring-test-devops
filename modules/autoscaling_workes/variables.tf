variable "INSTANCE_TYPE" {
  default = "m5a.large"
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
