#
# Cookbook Name:: delivery_build
# Spec:: cli
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

describe 'delivery_build::cli' do
  context 'by default' do
    before do
      default_mocks
    end

    let(:default_runner) do
      ChefSpec::SoloRunner.new
    end

    let(:chef_run) do
      default_runner.converge('delivery_build::cli')
    end

    it 'converges successfully' do
      chef_run
    end

    it 'installs delivery-cli from the stable channel by default' do
      expect(chef_run).to upgrade_chef_ingredient('delivery-cli').with_channel(:stable)
    end

    %w(chef/stable stable).each do |value|
      it "installs delivery-cli from the stable channel when repo_name is set to '#{value}'" do
        default_runner.node.set['delivery_build']['repo_name'] = value
        expect(chef_run).to upgrade_chef_ingredient('delivery-cli').with_channel(:stable)
      end
    end

    %w(chef/current current).each do |value|
      it "installs delivery-cli from the current channel when repo_name is set to '#{value}'" do
        default_runner.node.set['delivery_build']['repo_name'] = value
        expect(chef_run).to upgrade_chef_ingredient('delivery-cli').with_channel(:current)
      end
    end
  end
end
