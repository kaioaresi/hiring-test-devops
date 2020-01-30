provider "aws" {
  region = "${var.REGION}"
}

module "bucket" {
  source      = "../../modules/s3_bucket/"
  BUCKET_NAME = "${var.BUCKET_NAME}"
}
