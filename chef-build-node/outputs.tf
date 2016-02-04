output "chef-build-node-public-ip" {
  value = "${join(",", aws_instance.chef-build-node.*.public_ip)}"
}
