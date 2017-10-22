terraform {
  backend "consul" {
    address = "demo.consul.io"
    path = "getting-started-warfox"
    lock = false
  }
}

provider "aws" {
  region = "ap-south-1"
}

# New resource for the S3 bucket our application will use.
resource "aws_s3_bucket" "example" {
  bucket = "warfox-terraform-getting-started-guide"
  acl    = "private"
}
