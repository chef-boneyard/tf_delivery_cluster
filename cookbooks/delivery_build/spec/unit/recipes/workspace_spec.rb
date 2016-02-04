#
# Cookbook Name:: delivery_build
# Spec:: workspace
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

describe 'delivery_build::workspace' do
  context 'by default' do
    before do
      default_mocks
    end

    let(:dirs) { %w(bin lib etc) }

    cached(:chef_run) do
      runner = ChefSpec::SoloRunner.new do |node|
        node.set['delivery_build']['chef_root'] = '/etc/chef'
      end
      runner.converge('delivery_build::workspace')
    end

    cached(:windows_chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'windows', version: '2012R2')
      runner.converge('delivery_build::workspace')
    end

    describe 'windows' do
      let(:workspace) { 'C:/delivery/ws' }

      it 'should create the workspace' do
        expect(windows_chef_run).to create_directory(workspace).with(
          mode: '0755',
          recursive: true
        )
      end

      it 'should create subdirectories' do
        dirs.each do |dir|
          path = File.join(workspace, dir)
          expect(windows_chef_run).to create_directory(path).with(
            mode: '0755',
            recursive: true
          )
        end
      end

      it 'should add the delivery-cmd.cmd' do
        filename = "#{workspace}/bin/delivery-cmd.cmd"
        expect(windows_chef_run).to render_file(filename)
      end

      it 'creates the delivery-cmd' do
        filename = '/var/opt/delivery/workspace/bin/delivery-cmd'
        expect(chef_run).to render_file(filename).with_content(
          /class Streamy/
        )
        expect(chef_run).to_not render_file(filename).with_content(
          /Raven/
        )
      end
    end

    describe 'ubuntu' do
      it 'converges successfully' do
        chef_run
      end

      let(:workspace) { '/var/opt/delivery/workspace' }

      it 'should create the workspace own by dbuild' do
        expect(chef_run).to create_directory(workspace).with(
          owner: 'dbuild',
          group: 'dbuild',
          mode: '0755',
          recursive: true
        )
      end

      it 'should create the .chef own by dbuild' do
        expect(chef_run).to create_directory(File.join(workspace, '.chef')).with(
          owner: 'dbuild',
          group: 'dbuild',
          mode: '0755',
          recursive: true
        )
      end

      it 'should create subdirectories own by root' do
        dirs.each do |dir|
          path = File.join(workspace, dir)
          expect(chef_run).to create_directory(path).with(
            owner: 'root',
            mode: '0755',
            recursive: true
          )
        end
      end

      it 'writes the ssh wrapper' do
        filename = '/var/opt/delivery/workspace/bin/git_ssh'
        expect(chef_run).to create_template(filename).with(
          owner: 'root',
          mode: '0755'
        )
        [
          Regexp.new('-o UserKnownHostsFile=/var/opt/delivery/workspace/etc/delivery-git-ssh-known-hosts'),
          Regexp.new('-o IdentityFile=/var/opt/delivery/workspace/etc/builder_key'),
          Regexp.new('-l builder')
        ].each do |check|
          expect(chef_run).to render_file(filename).with_content(check)
        end
      end

      it 'creates the known hosts file' do
        expect(chef_run).to create_file('/var/opt/delivery/workspace/etc/delivery-git-ssh-known-hosts')
      end

      it 'creates the delivery-cmd' do
        filename = '/var/opt/delivery/workspace/bin/delivery-cmd'
        expect(chef_run).to create_template(filename).with(
          owner: 'root',
          mode: '0755'
        )
        expect(chef_run).to render_file(filename).with_content(
          /class Streamy/
        )
        expect(chef_run).to_not render_file(filename).with_content(
          /Raven/
        )
      end

      it 'creates the builder ssh key' do
        ['/var/opt/delivery/workspace/etc/builder_key',
         '/var/opt/delivery/workspace/.chef/builder_key'
        ].each do |filename|
          expect(chef_run).to create_file(filename).with(
            owner: 'dbuild',
            mode: '0600'
          )
          # This means you got it from the data bag
          expect(chef_run).to render_file(filename).with_content(
            'rocks_is_aerosmiths_best_album'
          )
        end
      end

      it 'creates the delivery.pem for the chef server' do
        ['/var/opt/delivery/workspace/etc/delivery.pem',
         '/var/opt/delivery/workspace/.chef/delivery.pem'
        ].each do |filename|
          expect(chef_run).to create_file(filename).with(
            owner: 'dbuild',
            mode: '0600'
          )
          # This means you got it from the data bag
          expect(chef_run).to render_file(filename).with_content(
            'toys_in_the_attic_is_aerosmiths_best_album'
          )
        end
      end

      it 'creates the knife.rb' do
        filename = '/var/opt/delivery/workspace/.chef/knife.rb'
        expect(chef_run).to create_template(filename).with(
          owner: 'dbuild',
          mode: '0644'
        )
        [
          Regexp.new('node_name\s+"delivery"'),
          Regexp.new('client_key\s+"#{current_dir}/delivery.pem"'),
          Regexp.new('trusted_certs_dir\s+"/etc/chef/trusted_certs"')
        ].each do |check|
          expect(chef_run).to render_file(filename).with_content(check)
        end
      end

      it 'fetches the delivery chef server ssl key' do
        expect(chef_run).to run_execute('fetch_ssl_certificate').with(
          command: 'knife ssl fetch -c /var/opt/delivery/workspace/etc/delivery.rb'
        )
      end

      it 'does not fetch the ssl certificate for the delivery api by default' do
        expect(chef_run).to_not run_execute('fetch_delivery_ssl_certificate')
      end
    end

    context "with node['delivery_build']['api'] set" do
      before do
        default_mocks
      end

      cached(:chef_run) do
        runner = ChefSpec::SoloRunner.new
        runner.node.normal['delivery_build']['api'] = 'https://192.168.33.1'
        runner.converge('delivery_build::workspace')
      end

      it 'fetches the delivery chef server ssl key' do
        expect(chef_run).to run_execute('fetch_delivery_ssl_certificate').with(
          command: 'knife ssl fetch -c /var/opt/delivery/workspace/etc/delivery.rb https://192.168.33.1'
        )
      end
    end

    context "with node['delivery_build']['sentry_dsn'] set" do
      before do
        default_mocks
      end

      cached(:chef_run) do
        runner = ChefSpec::SoloRunner.new
        runner.node.normal['delivery_build']['sentry_dsn'] = 'https://sentry_dsn'
        runner.converge('delivery_build::workspace')
      end

      it 'adds raven gem to chefdk' do
        expect(chef_run).to run_execute('install_sentry-raven').with(
          command: '/opt/chefdk/bin/chef gem install sentry-raven'
        )
      end

      it 'configures delivery-cmd to use Raven' do
        filename = '/var/opt/delivery/workspace/bin/delivery-cmd'
        expect(chef_run).to render_file(filename).with_content(
          /Raven/
        )
      end
    end
  end
end
