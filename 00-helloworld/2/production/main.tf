#export AWS_ACCESS_KEY_ID="foo"
#export AWS_SECRET_ACCESS_KEY="bar"
#export AWS_DEFAULT_REGION="us-east-2"
provider "aws" {}

module "network" {
  source = "../modules/network"
  project = "${var.project}"
}

#module "instances" {
#  source = "../modules/instances"
#  project = "${var.project}"
#  vpc_id = "${module.network.vpc_id}"
#  subnet_id = "${module.network.subnet_id}"
#  create_eip = "true"
#}
