resource "aws_s3_bucket" "bucket" {
  bucket = "${var.BUCKET_NAME}"
  acl    = "${var.ACL}"

  versioning {
    enabled = true
  }

  tags = var.TAGS
}
