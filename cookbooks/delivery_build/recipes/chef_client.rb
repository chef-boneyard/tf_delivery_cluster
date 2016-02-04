#
# Cookbook Name:: delivery_build
# recipe:: chef_client
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

root = if windows?
         'C:/chef'
       else
         '/etc/chef'
       end

node.set['delivery_build']['chef_root'] = root

directory root do
  mode 0755
  recursive true
end

file "#{root}/client.rb" do
  mode 0644
end

directory "#{root}/trusted_certs" do
  mode 0755
end

Dir["#{root}/trusted_certs/*"].each do |cert|
  file cert do
    mode 0644
  end
end
