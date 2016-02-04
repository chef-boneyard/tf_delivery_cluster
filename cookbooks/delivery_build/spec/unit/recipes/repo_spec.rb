#
# Cookbook Name:: delivery_build
# Spec:: repo
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

    cached(:chef_run) do
      runner = ChefSpec::SoloRunner.new do |_node|
      end
      runner.converge('delivery_build::repo')
    end

    cached(:vivid_chef_run) do
      # looks like this platform is not shipping with fauxhai and we can't
      # write into the chefdk's gem path as it could be owned by another user,
      # so we'll vendor our own copy
      json = File.expand_path(File.join(File.dirname(__FILE__),
                                        %w(.. .. fixtures ubuntu-15.04.json)))

      runner = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '15.04', path: json)
      runner.converge('delivery_build::repo')
    end

    it 'converges successfully' do
      chef_run
    end

    describe 'ubuntu-15.04' do
      it 'sets the apt-chef codename to trusty' do
        expect(vivid_chef_run.node['apt-chef']['codename']).to eq('trusty')
      end
    end
  end
end
