variable "REGION" {
  default = "us-east-1"
}

variable "BUCKET_NAME" {
  default = "s3-bucket-rmt-default-0987"
}

variable "ACL" {
  default = "private"
}

variable "TAGS" {
  type    = map(string)
  default = {}
}
