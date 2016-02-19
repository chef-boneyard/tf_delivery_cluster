# TODO: Uncommented out when we can orchestrate with depends_on
#
# Sadly I haven't figured out how to do the orchestration between modules
# because if we dont add `depends_on` they run in parallel and we are not
# ready yet to run these resources since the chef-server is not up.
#
# Configure the Chef Server
# provider "chef" {
#    server_url = "${var.chef-server-url}/"
#    client_name = "delivery"
#    private_key_pem = "${file(".chef/delivery.pem")}"
#    allow_unverified_ssl = true
# }

# Create the data bag to store our builder keys
# resource "chef_data_bag" "keys" {
#   depends_on = ["null_resource.something?"]
#   name = "keys"
# }

# TODO: How to create encrypted_items?
# Workaround: Use knife - look below at the "${template_file.delivery_builder_keys}"
# resource "chef_data_bag_item" "delivery_builder_keys" {
#     data_bag_name = "keys"
#     content_json = <<EOT
# {
#   "builder_key":  "${file(".chef/encrypted_data_bag_secret")}",
#   "delivery_pem": "${file(".chef/delivery.pem")}"
# }
# EOT
# }

# Generate builder_key
resource "null_resource" "generate_builder_key" {
  # Currently there is no way to delay the action of reading a file,
  # therefore we have to do this little script to delete the key and re
  # generate it. I am trying to find a solution at this issue:
  #
  # https://github.com/hashicorp/terraform/issues/3354
  provisioner "local-exec" {
    command = <<EOF
      rm -rf .chef/builder_key*
      ssh-keygen -t rsa -N '' -b 2048 -f .chef/builder_key
EOF
  }
}

# Template to render encrypted_data_bag_secret
resource "template_file" "encrypted_data_bag_secret" {
  depends_on = ["null_resource.generate_builder_key"]
  template = "${builder_key}"
  vars {
    builder_key = "${file(".chef/builder_key")}"
  }
  provisioner "local-exec" {
    command = "echo '${base64encode("${template_file.encrypted_data_bag_secret.rendered}")}' > .chef/encrypted_data_bag_secret"
  }
}

# Setup chef-delivery
resource "aws_instance" "chef-delivery" {
  ami = "${var.ami}"
  count = "${var.count}"
  instance_type = "${var.instance_type}"
  subnet_id = "${var.subnet_id}"
  vpc_security_group_ids = ["${var.security_groups_ids}"]
  key_name = "${var.key_name}"
  tags {
    Name = "${format("chef-delivery-%02d", count.index + 1)}"
  }
  root_block_device = {
    delete_on_termination = true
  }
  connection {
    user = "${var.user}"
    private_key = "${var.private_key_path}"
  }
  depends_on = ["null_resource.generate_builder_key", "template_file.encrypted_data_bag_secret"]

  # For now there is no way to delete the node from the chef-server
  # and also there is no way to customize your `destroy` actions
  # https://github.com/hashicorp/terraform/issues/649
  #
  # Workaround: Force-delete the node before hand
  provisioner "local-exec" {
    command = <<EOF
    knife node delete ${format("chef-delivery-%02d", count.index + 1)} -y
    knife client delete ${format("chef-delivery-%02d", count.index + 1)} -y
    echo 'ugly'
EOF
  }

  # Copies all files needed by Delivery
  provisioner "file" {
    source = ".chef"
    destination = "/tmp"
  }

  # Create the data-bag keys
  provisioner "local-exec" {
    command = "knife data bag create keys"
  }

  # Configure license and files
  provisioner "remote-exec" {
    inline = [
      "sudo service iptables stop",
      "sudo chkconfig iptables off",
      "sudo mkdir -p /var/opt/delivery/license",
      "sudo mkdir -p /etc/delivery",
      "sudo mkdir -p /etc/chef",
      "sudo chown root:root -R /tmp/.chef",
      "sudo mv /tmp/.chef/delivery.license /var/opt/delivery/license",
      "sudo chmod 644 /var/opt/delivery/license/delivery.license",
      "sudo mv /tmp/.chef/* /etc/delivery/.",
      "sudo mv /etc/delivery/trusted_certs /etc/chef/."
    ]
  }

  provisioner "chef"  {
    attributes {
      "delivery-cluster" {
        "delivery" {
          "chef_server" = "${var.chef-server-url}"
          "fqdn" = "${self.public_ip}"
        }
      }
    }
    # environment = "_default"
    run_list = ["delivery-cluster::delivery"]
    node_name = "${format("chef-delivery-%02d", count.index + 1)}"
    secret_key = "${template_file.encrypted_data_bag_secret.rendered}"
    server_url = "${var.chef-server-url}"
    validation_client_name = "terraform-validator"
    validation_key = "${file(".chef/terraform-validator.pem")}"
  }

  # Create Enterprise
  provisioner "remote-exec" {
    inline = [
      "sudo delivery-ctl create-enterprise ${var.enterprise} --ssh-pub-key-file=/etc/delivery/builder_key.pub > /tmp/${var.enterprise}.creds",
    ]
  }

  # TODO: How terraform can download files? If it doesn't then we may have to triangle the files
  #       that is (perhaps) upload the files somewhere or create a data bag and store them there.
  #
  # Workaround: Use scp to download the creds file
  provisioner "local-exec" {
    command  = "scp -oStrictHostKeyChecking=no -i ${var.private_key_path} ${var.user}@${self.public_ip}:/tmp/${var.enterprise}.creds .chef/${var.enterprise}.creds"
  }
}

# Template to render delivery_builder_keys item
resource "template_file" "delivery_builder_keys" {
  depends_on = ["null_resource.generate_builder_key", "template_file.encrypted_data_bag_secret"]
  template = "${file("${path.module}/templates/delivery_builder_keys.tpl")}"
  vars {
    builder_key = "${replace(file(".chef/builder_key"), "/\n/", "\\\\n")}"
    delivery_pem = "${replace(file(".chef/delivery.pem"), "/\n/", "\\\\n")}"
  }
  provisioner "local-exec" {
    command = "echo '${template_file.delivery_builder_keys.rendered}' > .chef/delivery_builder_keys.json"
  }
  # Fetch Chef Delivery Certificate
  provisioner "local-exec" {
    command = "knife ssl fetch https://${aws_instance.chef-delivery.public_ip}"
  }
  # Upload cookbooks to the Chef Server
  provisioner "local-exec" {
    command = "knife data bag from file keys .chef/delivery_builder_keys.json --encrypt"
  }
}
