#
# Delivery Cluster with Terraform
#
provider "aws" {
  access_key = "${var.aws_access_key_id}"
  secret_key = "${var.aws_secret_access_key}"
  region = "${var.aws_default_region}"
}

# Networking Configuration
module "ec2-network" {
  source = "./ec2-network"
}

# Setup Chef Server
module "chef-server" {
  source = "./chef-server"
  ami = "${lookup(var.centos-6-amis, var.aws_default_region)}"
  count = "${lookup(var.instance_counts, "chef-server")}"
  instance_type = "${lookup(var.instances, "chef-server")}"
  subnet_id = "${module.ec2-network.subnet_id}"
  security_groups_ids = "${module.ec2-network.chef-server_security_group_id}"
  key_name = "${var.aws_key_pair_name}"
  user = "${var.aws_ami_user}"
  private_key_path = ".keys/${var.aws_key_pair_name}.pem"

  organization = "${var.chef-server-organization}"
}

# Configure the Chef Server
provider "chef" {
   server_url = "${module.chef-server.chef-server-url}/"
   client_name = "delivery"
   private_key_pem = "${file(".chef/delivery.pem")}"
   allow_unverified_ssl = true
}

# Setup Chef Delivery
module "chef-delivery" {
  source = "./chef-delivery"
  ami = "${lookup(var.centos-6-amis, var.aws_default_region)}"
  count = "${lookup(var.instance_counts, "chef-delivery")}"
  instance_type = "${lookup(var.instances, "chef-delivery")}"
  subnet_id = "${module.ec2-network.subnet_id}"
  security_groups_ids = "${module.ec2-network.chef-delivery_security_group_id}"
  key_name = "${var.aws_key_pair_name}"
  user = "${var.aws_ami_user}"
  private_key_path = ".keys/${var.aws_key_pair_name}.pem"
  chef-server-url = "${module.chef-server.chef-server-url}"

  enterprise = "${var.chef-delivery-enterprise}"
}

# Setup Chef Build-Node(s)
module "chef-build-node" {
  source = "./chef-build-node"
  ami = "${lookup(var.centos-6-amis, var.aws_default_region)}"
  count = "${lookup(var.instance_counts, "chef-build-node")}"
  instance_type = "${lookup(var.instances, "chef-build-node")}"
  subnet_id = "${module.ec2-network.subnet_id}"
  security_groups_ids = "${module.ec2-network.chef-build-node_security_group_id}"
  key_name = "${var.aws_key_pair_name}"
  user = "${var.aws_ami_user}"
  private_key_path = ".keys/${var.aws_key_pair_name}.pem"
  chef-server-url = "${module.chef-server.chef-server-url}"
}

# Setup Chef Supermarket
# Setup Chef Analytics
# Setup Chef Compliance
