output "subnet_id" {
  value = "${aws_subnet.terraform-delivery-cluster.id}"
}
output "chef-server_security_group_id" {
  value = "${aws_security_group.chef-server.id}"
}
output "chef-delivery_security_group_id" {
  value = "${aws_security_group.chef-delivery.id}"
}
output "chef-build-node_security_group_id" {
  value = "${aws_security_group.chef-build-node.id}"
}
