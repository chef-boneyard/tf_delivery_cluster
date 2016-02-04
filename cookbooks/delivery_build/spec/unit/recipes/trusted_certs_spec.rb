#
# Cookbook Name:: delivery_build
# Spec:: chefdk
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

require 'spec_helper'

describe 'delivery_build::trusted_certs' do
  context 'by default' do
    before do
      default_mocks
    end

    cached(:chef_run) do
      runner = ChefSpec::SoloRunner.new
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      chef_run
    end
  end

  context "with a node['delivery_build']['trusted_certs'] set" do
    cached(:chef_run) do
      runner = ChefSpec::SoloRunner.new do |node|
        node.set['delivery_build']['trusted_certs'] = {
          'Delivery Supermarket Server' => '/my/path/to/supermarket.crt',
          'Delivery Github Enterprise' => '/etc/chef/trusted_certs/github.crt',
          'Another Component' => '/the/component.crt'
        }
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      chef_run
    end

    it 'appends the trusted_certs to chefdk/cacert.pem' do
      expect(chef_run).to append_trusted_cert('Delivery Supermarket Server')
        .with_path('/my/path/to/supermarket.crt')
      expect(chef_run).to append_trusted_cert('Delivery Github Enterprise')
        .with_path('/etc/chef/trusted_certs/github.crt')
      expect(chef_run).to append_trusted_cert('Another Component')
        .with_path('/the/component.crt')
    end
  end
end
