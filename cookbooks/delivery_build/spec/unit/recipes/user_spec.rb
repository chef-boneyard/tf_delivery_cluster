#
# Cookbook Name:: delivery_build
# Spec:: user
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

describe 'delivery_build::user' do
  context 'by default' do
    before do
      default_mocks
    end

    cached(:chef_run) do
      runner = ChefSpec::SoloRunner.new
      runner.converge('delivery_build::user')
    end

    it 'converges successfully' do
      chef_run
    end

    it 'creates the home directory tree before create the dbuild user' do
      expect(chef_run).to create_directory('/var/opt/delivery').with(
        mode: '0755',
        recursive: true
      )
    end

    it 'adds the build user' do
      expect(chef_run).to create_user('dbuild').with(
        home: '/var/opt/delivery/workspace',
        comment: 'Delivery Build'
      )
    end
  end
end
