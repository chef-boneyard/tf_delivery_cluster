#
# EC2 Networks
#
resource "aws_vpc" "terraform-delivery-cluster" {
  cidr_block = "${lookup(var.aws_cidrs, "vpc")}"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.cluster_name} VPC"
  }
}
resource "aws_internet_gateway" "terraform-delivery-cluster-gw" {
  vpc_id = "${aws_vpc.terraform-delivery-cluster.id}"
  tags = {
    Name = "${var.cluster_name} Gateway"
  }
}
resource "aws_route_table" "internet" {
  vpc_id = "${aws_vpc.terraform-delivery-cluster.id}"
  tags = {
    Name = "${var.cluster_name} Routes"
  }
}
resource "aws_route" "internet" {
  route_table_id = "${aws_route_table.internet.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.terraform-delivery-cluster-gw.id}"
}
resource "aws_subnet" "terraform-delivery-cluster" {
  vpc_id = "${aws_vpc.terraform-delivery-cluster.id}"
  cidr_block = "${lookup(var.aws_cidrs, "subnet")}"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.cluster_name} Subnet"
  }
}
resource "aws_route_table_association" "internet-access" {
  subnet_id = "${aws_subnet.terraform-delivery-cluster.id}"
  route_table_id = "${aws_route_table.internet.id}"
}

#
# AWS security groups
#
# Chef Server
# https://docs.chef.io/server_firewalls_and_ports.html
resource "aws_security_group" "chef-server" {
  name = "chef-server"
  description = "Chef Server"
  vpc_id = "${aws_vpc.terraform-delivery-cluster.id}"
  tags = {
    Name = "chef-server security group"
  }
}
# SSH - all
resource "aws_security_group_rule" "chef-server_allow_22_tcp_all" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-server.id}"
}
# HTTP (nginx)
resource "aws_security_group_rule" "chef-server_allow_80_tcp" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-server.id}"
}
# HTTPS (nbinx)
resource "aws_security_group_rule" "chef-server_allow_443_tcp" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-server.id}"
}
# oc_bifrost
resource "aws_security_group_rule" "chef-server_allow_9463_tcp" {
  type = "ingress"
  from_port = 9463
  to_port = 9463
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-server.id}"
}
# oc_bifrost (nginx LB)
resource "aws_security_group_rule" "chef-server_allow_9683_tcp" {
  type = "ingress"
  from_port = 9683
  to_port = 9683
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-server.id}"
}
# opscode push-jobs
resource "aws_security_group_rule" "chef-server_allow_10000-10003_tcp" {
  type = "ingress"
  from_port = 10000
  to_port = 10003
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-server.id}"
}
# Allow all Chef Analytics
resource "aws_security_group_rule" "chef-server_allow_all_chef-analytics" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.chef-analytics.id}"
  security_group_id = "${aws_security_group.chef-server.id}"
}
# Allow all Chef Delivery
resource "aws_security_group_rule" "chef-server_allow_all_chef-delivery" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.chef-delivery.id}"
  security_group_id = "${aws_security_group.chef-server.id}"
}
# Allow all Chef Delivery Build
resource "aws_security_group_rule" "chef-server_allow_all_chef-build-node" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.chef-build-node.id}"
  security_group_id = "${aws_security_group.chef-server.id}"
}
# Allow all Chef Compliance
resource "aws_security_group_rule" "chef-server_allow_all_chef-compliance" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.chef-compliance.id}"
  security_group_id = "${aws_security_group.chef-server.id}"
}
# Egress: ALL
resource "aws_security_group_rule" "chef-server_allow_all" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-server.id}"
}

# Chef Analytics
# https://docs.chef.io/server_firewalls_and_ports.html
resource "aws_security_group" "chef-analytics" {
  name = "chef-analytics"
  description = "Chef Analytics Server"
  vpc_id = "${aws_vpc.terraform-delivery-cluster.id}"
  tags = {
    Name = "chef-analytics security group"
  }
}
# SSH - all
resource "aws_security_group_rule" "chef-analytics_allow_22_tcp_all" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-analytics.id}"
}
# HTTP
resource "aws_security_group_rule" "chef-analytics_allow_80_tcp" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-analytics.id}"
}
# HTTPS
resource "aws_security_group_rule" "chef-analytics_allow_443_tcp" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-analytics.id}"
}
# Allow all Chef Server
resource "aws_security_group_rule" "chef-analytics_allow_all_chef-server" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.chef-server.id}"
  security_group_id = "${aws_security_group.chef-analytics.id}"
}
# Allow all Chef Delivery
resource "aws_security_group_rule" "chef-analytics_allow_all_chef-delivery" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.chef-delivery.id}"
  security_group_id = "${aws_security_group.chef-analytics.id}"
}
# Allow all Chef Compliance
resource "aws_security_group_rule" "chef-analytics_allow_all_chef-compliance" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.chef-compliance.id}"
  security_group_id = "${aws_security_group.chef-analytics.id}"
}
# Egress: ALL
resource "aws_security_group_rule" "chef-analytics_allow_all" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-analytics.id}"
}

# Chef Compliance
# https://docs.chef.io/install_compliance.html
resource "aws_security_group" "chef-compliance" {
  name = "chef-compliance"
  description = "Chef compliance"
  vpc_id = "${aws_vpc.terraform-delivery-cluster.id}"
  tags = {
    Name = "chef-compliance security group"
  }
}
# SSH - all
resource "aws_security_group_rule" "chef-compliance_allow_22_tcp_all" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-compliance.id}"
}
# HTTPS
resource "aws_security_group_rule" "chef-compliance_allow_443_tcp" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-compliance.id}"
}
# Allow all Chef Server
resource "aws_security_group_rule" "chef-compliance_allow_all_chef-server" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.chef-server.id}"
  security_group_id = "${aws_security_group.chef-compliance.id}"
}
# Egress: ALL
resource "aws_security_group_rule" "chef-compliance_allow_all" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-compliance.id}"
}

# Chef Supermarket
# https://docs.chef.io/config_rb_supermarket.html
resource "aws_security_group" "chef-supermarket" {
  name = "chef-supermarket"
  description = "Chef supermarket"
  vpc_id = "${aws_vpc.terraform-delivery-cluster.id}"
  tags = {
    Name = "chef-supermarket security group"
  }
}
# SSH - all
resource "aws_security_group_rule" "chef-supermarket_allow_22_tcp_all" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-supermarket.id}"
}
# HTTP
resource "aws_security_group_rule" "chef-supermarket_allow_80_tcp" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-supermarket.id}"
}
# HTTPS
resource "aws_security_group_rule" "chef-supermarket_allow_443_tcp" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-supermarket.id}"
}
# Allow all Chef Server
resource "aws_security_group_rule" "chef-supermarket_allow_all_chef-server" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.chef-server.id}"
  security_group_id = "${aws_security_group.chef-supermarket.id}"
}
# Allow all Chef Delivery
resource "aws_security_group_rule" "chef-supermarket_allow_all_chef-delivery" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.chef-delivery.id}"
  security_group_id = "${aws_security_group.chef-supermarket.id}"
}
# Egress: ALL
resource "aws_security_group_rule" "chef-supermarket_allow_all" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-supermarket.id}"
}

# Chef Delivery
# https://docs.chef.io/install_delivery_aws.html
# https://github.com/chef-cookbooks/delivery-cluster#aws-driver
resource "aws_security_group" "chef-delivery" {
  name = "chef-delivery"
  description = "Chef Delivery Server"
  vpc_id = "${aws_vpc.terraform-delivery-cluster.id}"
  tags = {
    Name = "chef-delivery security group"
  }
}
# SSH - all
resource "aws_security_group_rule" "chef-delivery_allow_22_tcp_all" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-delivery.id}"
}
# HTTP
resource "aws_security_group_rule" "chef-delivery_allow_80_tcp" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-delivery.id}"
}
# HTTPS
resource "aws_security_group_rule" "chef-delivery_allow_443_tcp" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-delivery.id}"
}
# Delivery GIT
resource "aws_security_group_rule" "chef-delivery_allow_8989_tcp" {
  type = "ingress"
  from_port = 8989
  to_port = 8989
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-delivery.id}"
}
# Allow all Chef Server
resource "aws_security_group_rule" "chef-delivery_allow_all_chef-server" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.chef-server.id}"
  security_group_id = "${aws_security_group.chef-delivery.id}"
}
# Allow all Chef Analytics
resource "aws_security_group_rule" "chef-delivery_allow_all_chef-analytics" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.chef-analytics.id}"
  security_group_id = "${aws_security_group.chef-delivery.id}"
}
# Allow all Chef Delivery Build
resource "aws_security_group_rule" "chef-delivery_allow_all_chef-build-node" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.chef-build-node.id}"
  security_group_id = "${aws_security_group.chef-delivery.id}"
}
# Egress: ALL
resource "aws_security_group_rule" "chef-delivery_allow_all" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-delivery.id}"
}

# Chef Build Servers
# https://docs.chef.io/install_delivery_aws.html
resource "aws_security_group" "chef-build-node" {
  name = "chef-build-node"
  description = "Chef Delivery Build Servers"
  vpc_id = "${aws_vpc.terraform-delivery-cluster.id}"
  tags = {
    Name = "chef-build-node security group"
  }
}
# SSH - all
resource "aws_security_group_rule" "chef-build-node_allow_22_tcp_all" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-build-node.id}"
}
# Allow all Chef Server
resource "aws_security_group_rule" "chef-build-node_allow_all_chef-server" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.chef-server.id}"
  security_group_id = "${aws_security_group.chef-build-node.id}"
}
# Allow all Chef Delivery
resource "aws_security_group_rule" "chef-build-node_allow_all_chef-delivery" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.chef-delivery.id}"
  security_group_id = "${aws_security_group.chef-build-node.id}"
}
# Egress: ALL
resource "aws_security_group_rule" "chef-build-node_allow_all" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-build-node.id}"
}
