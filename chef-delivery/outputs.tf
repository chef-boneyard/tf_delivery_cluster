output "chef-delivery-public-ip" {
  value = "${aws_instance.chef-delivery.public_ip}"
}
output "chef-delivery-enterprise" {
  value = "${var.enterprise}"
}
output "chef-delivery-creds" {
  value = "${file(".chef/${var.enterprise}.creds")}"
}
