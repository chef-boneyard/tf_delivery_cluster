#
# Cookbook Name:: delivery_build
# Spec:: chef_client_spec
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

describe 'delivery_build::chef_client' do
  context 'by default' do
    before do
      default_mocks
    end

    cached(:chef_run) do
      runner = ChefSpec::SoloRunner.new
      runner.converge('delivery_build::chef_client')
    end

    cached(:windows_chef_run) do
      ENV['USERPROFILE'] = 'C:/Users/Administrator'
      ENV['SYSTEMDRIVE'] = 'C:'
      runner = ChefSpec::SoloRunner.new(platform: 'windows', version: '2012R2')
      runner.converge('delivery_build::chef_client')
    end

    describe 'ubuntu' do
      it 'converges successfully' do
        chef_run
      end

      it 'sets /etc/chef perms to 0755' do
        expect(chef_run).to create_directory('/etc/chef').with(
          mode: 0755
        )
      end

      it 'sets client.rb perms to 0644' do
        expect(chef_run).to create_file('/etc/chef/client.rb').with(
          mode: 0644
        )
      end

      it 'sets trusted_certs perms to 0755' do
        expect(chef_run).to create_directory('/etc/chef/trusted_certs').with(
          mode: 0755
        )
      end
    end

    describe 'windows' do
      it 'sets client.rb perms to 0644' do
        expect(windows_chef_run).to create_file('C:/chef/client.rb').with(
          mode: 0644
        )
      end
    end
  end
end
