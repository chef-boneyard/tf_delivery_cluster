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

%w(root dot_chef).each do |dir|
  directory node['delivery_build'][dir] do
    owner node['delivery_build']['build_user'] unless windows?
    group node['delivery_build']['build_user'] unless windows?
    mode '0755'
    recursive true
  end
end

%w(bin lib etc).each do |dir|
  directory node['delivery_build'][dir] do
    owner 'root' unless windows?
    mode '0755'
    recursive true
  end
end

# The SSH wrapper for Git
template File.join(node['delivery_build']['bin'], 'git_ssh') do
  source 'git_ssh.erb'
  owner 'root' unless windows?
  mode '0755'
end

# The SSH Known Hosts File
file node['delivery_build']['ssh_known_hosts_file'] do
  owner 'dbuild' unless windows?
  mode '0644'
end

if node['delivery_build']['sentry_dsn']
  execute 'install_sentry-raven' do
    command '/opt/chefdk/bin/chef gem install sentry-raven'
  end
end

# Executes a job from pushy
template File.join(node['delivery_build']['bin'], 'delivery-cmd') do
  source 'delivery-cmd.erb'
  owner 'root' unless windows?
  mode '0755'
end

template File.join(node['delivery_build']['bin'], 'delivery-cmd.cmd') do
  only_if { windows? }
  source 'delivery-cmd.cmd.erb'
end

# a bunch of keys we need for the build
# this is inside the 'if change' block mainly
# because otherwise that would fail on the very-first
# TK-driven run in the dev setup
{ 'builder_key'  => 'builder_key',
  'delivery_pem' => 'delivery.pem' }.each do |key_name, file_name|
  data_bag_coords = node['delivery_build']['builder_keys'][key_name]
  data_bag_content = DeliveryHelper.encrypted_data_bag_item(data_bag_coords['bag'],
                                                            data_bag_coords['item'])
  # TODO: the 'builder_key' should clearly be dependent on the enterprise
  # and so stored at an ent-level workspace dir
  file ::File.join(node['delivery_build']['etc'], file_name) do
    # FIXME: here, for 'delivery_pem', we effectively allow just about
    # any committer (in the delivery sense) to do whatever she wants
    # on the CS server. No need to emphasize how bad that is.
    owner node['delivery_build']['build_user'] unless windows?
    group 'root' unless windows?
    mode '0600'
    content data_bag_content[data_bag_coords['key']]
  end

  file ::File.join(node['delivery_build']['dot_chef'], file_name) do
    # FIXME: here, for 'delivery_pem', we effectively allow just about
    # any committer (in the delivery sense) to do whatever she wants
    # on the CS server. No need to emphasize how bad that is.
    owner node['delivery_build']['build_user'] unless windows?
    group 'root' unless windows?
    mode '0600'
    content data_bag_content[data_bag_coords['key']]
  end
end

# the knife file to talk to CS as delivery
delivery_config = ::File.join(node['delivery_build']['etc'], 'delivery.rb')
template delivery_config do
  source 'delivery.rb.erb'
  owner node['delivery_build']['build_user'] unless windows?
  group 'root' unless windows?
  mode '0644'
  variables(lazy { { 'root' => node['delivery_build']['chef_root'] } })
end

# This is used by the delivery CLI-based build node workflow
knife_config = ::File.join(node['delivery_build']['dot_chef'], 'knife.rb')
template knife_config do
  source 'delivery.rb.erb'
  owner node['delivery_build']['build_user'] unless windows?
  mode '0644'
  variables(lazy { { 'root' => node['delivery_build']['chef_root'] } })
end

# Fetch the SSL certificate for the CS if necessary. For example, it's
# primarily not necessary when running in local mode (e.g.,
# test-kitchen w/ the chef_zero provisioner).
unless Chef::Config[:local_mode]
  execute 'fetch_ssl_certificate' do
    command "knife ssl fetch -c #{delivery_config}"
    not_if "knife ssl check -c #{delivery_config}"
  end

  if node['delivery_build']['api']
    # Fetch the SSL certificate for the Delivery Server
    execute 'fetch_delivery_ssl_certificate' do
      command "knife ssl fetch -c #{delivery_config} #{node['delivery_build']['api']}"
      not_if "knife ssl check -c #{delivery_config} #{node['delivery_build']['api']}"
      only_if { node['delivery_build']['api'] =~ /^https/ ? true : false }
    end
  end
end
