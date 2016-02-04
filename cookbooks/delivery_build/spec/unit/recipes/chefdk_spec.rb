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

describe 'delivery_build::chefdk' do
  context 'by default' do
    before do
      default_mocks
    end

    let(:default_runner) do
      ChefSpec::SoloRunner.new do |node|
        node.set['delivery_build']['chefdk_version'] = '0.4.0'
      end
    end

    let(:chef_run) do
      default_runner.converge(described_recipe)
    end

    cached(:windows_chef_run) do
      ENV['USERPROFILE'] = 'C:/Users/Administrator'
      runner = ChefSpec::SoloRunner.new(platform: 'windows', version: '2012R2') do |node|
        node.set['delivery_build']['chefdk_version'] = '0.4.0'
      end
      runner.converge(described_recipe)
    end

    describe 'ubuntu' do
      it 'converges successfully' do
        chef_run
      end

      it 'installs chefdk v0.4.0' do
        expect(chef_run).to install_chef_ingredient('chefdk').with_version('0.4.0')
      end

      it 'installs chefdk from the stable channel by default' do
        expect(chef_run).to install_chef_ingredient('chefdk').with_channel(:stable)
      end

      %w(chef/stable stable).each do |value|
        it "installs chefdk from the stable channel when repo_name is set to '#{value}'" do
          default_runner.node.set['delivery_build']['repo_name'] = value
          expect(chef_run).to install_chef_ingredient('chefdk').with_channel(:stable)
        end
      end

      %w(chef/current current).each do |value|
        it "installs chefdk from the current channel when repo_name is set to '#{value}'" do
          default_runner.node.set['delivery_build']['repo_name'] = value
          expect(chef_run).to install_chef_ingredient('chefdk').with_channel(:current)
        end
      end

      context 'when chefdk_version is latest' do
        before do
          chef_run.node.set['delivery_build']['chefdk_version'] = 'latest'
          chef_run.converge(described_recipe)
        end

        it 'upgrades chefdk' do
          expect(chef_run).to upgrade_chef_ingredient('chefdk')
        end
      end

      it 'configures .gemrc' do
        expect(chef_run).to create_file('/root/.gemrc').with(
          mode: '0644'
        )
      end
    end

    describe 'windows' do
      it 'installs chefdk' do
        expect(windows_chef_run).to install_windows_package('Chef Development Kit v0.4.0')
      end

      it 'configures .gemrc' do
        expect(windows_chef_run).to create_file('C:/Users/Administrator/.gemrc').with(
          mode: '0644'
        )
      end
    end
  end
end
