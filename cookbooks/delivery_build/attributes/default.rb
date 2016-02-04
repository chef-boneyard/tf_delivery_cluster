#
# Copyright 2015 Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_attribute 'delivery-base'

# The repo that we should pull chefdk and delivery-cli
default['delivery_build']['repo_name'] = 'chef/stable'

# Directories we need for the builder workspace
default['delivery_build']['root'] = platform_family == 'windows' ? 'C:/delivery/ws' : '/var/opt/delivery/workspace'

default['delivery_build']['bin'] = File.join(node['delivery_build']['root'], 'bin')
default['delivery_build']['lib'] = File.join(node['delivery_build']['root'], 'lib')
default['delivery_build']['etc'] = File.join(node['delivery_build']['root'], 'etc')
default['delivery_build']['dot_chef'] = File.join(node['delivery_build']['root'], '.chef')

# Settings for the Delivery SSH Wrapper
default['delivery_build']['ssh_user'] = 'builder'
default['delivery_build']['ssh_key'] = File.join(node['delivery_build']['etc'], 'builder_key')
default['delivery_build']['ssh_log_level'] = 'INFO'
default['delivery_build']['ssh_known_hosts_file'] = File.join(node['delivery_build']['etc'], 'delivery-git-ssh-known-hosts')

# Build User
default['delivery_build']['build_user'] = 'dbuild'

# In which encrypted data bags to find the needed keys, i.e.
# the private key for the 'builder' delivery user, and the
# private key for the 'delivery' Chef user
default['delivery_build']['builder_keys'] = {
  'builder_key' => {
    'bag' => 'keys',
    'item' => 'delivery_builder_keys',
    # a data bag is a hash; what key in the hash?
    'key' => 'builder_key'
  },
  'delivery_pem' => {
    'bag' => 'keys',
    'item' => 'delivery_builder_keys',
    'key' => 'delivery_pem'
  }
}

# Sentry DSN for use with exception handling in delivery-cmd
default['delivery_build']['sentry_dsn'] = nil

# The location of the Delivery API
default['delivery_build']['api'] = nil

# If set, download the package from the given url.
default['delivery_build']['delivery-cli']['version'] = nil

# package options for installing delivery-cli
# example: "--nogpgcheck" if package is unsigned
default['delivery_build']['delivery-cli']['options'] = nil

if platform_family == 'windows'
  # This sucks mightily, but is necessary until chef-ingedient works on Windows and delivery-cli is properly publishing.
  # Until both those things are true, these values will need to be updated every time a new build of Windows delivery-cli is uploaded.
  default['delivery_build']['delivery-cli']['artifact'] = 'https://s3.amazonaws.com/delivery-packages/cli/delivery-cli-0.0.0%2B20151029184247-1-x64.msi'
  default['delivery_build']['delivery-cli']['checksum'] = '4ff91024745801bc2a0f294a8581a175ebb6c6c7dabddba465ed3d3da52163eb'
else
  default['delivery_build']['delivery-cli']['artifact'] = nil
  default['delivery_build']['delivery-cli']['checksum'] = nil
end

# ChefDK version
#
# Specify the chefdk version you want to install on the build-nodes
# set it to `latest` to always be in the latest version (:upgrade)
default['delivery_build']['chefdk_version'] = if platform_family == 'windows'
                                                # Currently there is no "easy" way to get the latest version
                                                # of chefdk for windows systems, therefore we will hardcode it
                                                # until we have a final solution for this.
                                                '0.9.0'
                                              else
                                                'latest'
                                              end

# Add trusted_certs to the build-node chefdk/cacerts.pem via trusted_certs.rb
# Example:
# {
#   'Delivery Supermarket Server' => '/my/supermarket.crt',
#   'Delivery Github Enterprise' => '/the/github.crt',
#   'Another Component' => '/another/component.crt'
# }
default['delivery_build']['trusted_certs'] = {}

delivery_cmd = File.join(node['delivery_build']['bin'], 'delivery-cmd')

default['push_jobs']['whitelist'] = { 'chef-client'         => 'chef-client',
                                      /^delivery-cmd (.+)$/ => "#{delivery_cmd} '\\1'" }
