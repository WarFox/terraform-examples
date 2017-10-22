variable "region" {
  default = "ap-south-1"
}

provider "aws" {
  region = "${var.region}"
}

module "consul" {
  source = "github.com/hashicorp/consul/terraform/aws"

  ami = {
    ap-south-1-ubuntu = "ami-cbe89fa4"
  }

  key_name = "sample_terraform_consul_module"
  key_path = "./sample_terraform_consul_module.pem"
  region = "${var.region}"
  servers = 3
}

output "consul_address" {
  value = "${module.consul.server_address}"
}

# aws ec2 describe-images --owners 099720109477 --region ap-south-1 --filters "Name=root-device-type,Values=ebs" "Name=virtualization-type,Values=hvm"
# ami-cbe89fa4
# Recommend ebs based AMI,
# t2.micro needs hvm and Vitalisation
