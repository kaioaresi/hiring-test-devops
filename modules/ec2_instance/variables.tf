variable "REGION" {
  default = "us-east-1"
}

#variable "INSTANCE_TYPE_MASTER" {
#  default = "m5a.large"
#}

variable "INSTANCE_TYPE_MASTER" {
  default = "m5a.large"
}

variable "SUBNET_ID" {
  default = ""
}

variable "SECURITY_GROUPS" {
  type    = list
  default = []
}

variable "TAGS" {
  type    = map(string)
  default = {}
}

variable "user_data" {
  default = ""
}
