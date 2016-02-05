# `tf_delivery_cluster`
A Terraform plan to install and configure Chef Delivery and its components:

* Chef Server 12
* Chef Delivery
* Chef Build Nodes (3) for Chef Delivery
* Chef Supermarket
* Chef Compliance
* Chef Analytics


Usage
------------

##### 1) Download your Delivery license key
Delivery requires a valid license to activate successfully. **If you do
not have a license key, you can request one from your CHEF account
representative.**

You will need to have the `delivery.license` file present inside `.chef/`
directory.

##### 2) Install and Configure ChefDK

Follow the instructions at https://docs.chef.io/install_dk.html to install and configure chefdk as your default version of ruby.

##### 3) Install Terraform

Downloads are here: https://www.terraform.io/downloads.html . Place in your path for direct execution.

##### 4) Create and populate `terraform.tfvars` at the root of the repository

```
# Terraform Variables File
# Delivery Cluster Settings
aws_access_key_id = "<KEY>"
aws_secret_access_key = "<SECRET>"
aws_default_region = "us-west-2"
aws_key_pair_name = "<KEY-PAIR-NAME>"
chef-delivery-enterprise = "terraform"
chef-server-organization = "terraform"
```

##### 5) Store your key-pair pem file inside `.keys/`

##### 6) Load the Terraform Modules and apply the Plan

```
$ terraform get
$ terraform apply
```

#### Access to Delivery Cluster

At this time you should have your Delivery Cluster up & running.

Now it is time to get access. You can use the `admin` credentials shown by:

```
$ terraform output -module=chef-delivery
chef-delivery-creds = Created enterprise: terraform
Admin username: admin
Admin password: RnjR44L87qgG6Pt3t+QDZghyZlUY2gEQxMk=
Builder Password: PE3XDjesPbMAyzkVnKEsrOBaIX5yZtNHhtQ=
Web login: https://54.148.123.123/e/terraform/

chef-delivery-enterprise = terraform
chef-delivery-public-ip = 54.148.123.123
```

Here a gist with the ouput of the process: https://gist.github.com/afiune/fdabdbd146e564b0ed0f

LICENSE AND AUTHORS
===================
* [Salim Afiune](https://github.com/afiune)
* [Brian Menges](https://github.com/mengesb)

```text
Copyright:: 2015 Chef Software, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
