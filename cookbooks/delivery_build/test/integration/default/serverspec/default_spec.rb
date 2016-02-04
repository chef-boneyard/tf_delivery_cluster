require 'spec_helper'

describe 'delivery_build::default' do
  # Push-Jobs
  describe service('opscode-push-jobs-client') do
    it { should be_running }
  end

  # ChefDK
  describe 'ChefDK' do
    context package('chefdk') do
      it { should be_installed }
    end

    context command('chef -v') do
      its(:stdout) { should match(/Chef Development Kit/) }
      its(:exit_status) { should eq 0 }
    end
  end

  # Git
  describe package('git') do
    it { should be_installed }
  end

  # delivery-cli
  #
  # Currently we are just building the delivery-cli for:
  # => debian 14.04
  # => rhel >= 6
  #
  # TODO: Build a cli for older versions and remove guard
  describe 'delivery-cli', if: ['14.04', '6'].include?(os[:release]) do
    context package('delivery-cli') do
      it { should be_installed }
    end

    context command('delivery --version') do
      its(:stdout) { should match(/delivery/) }
      its(:exit_status) { should eq 0 }
    end
  end

  # User dbuild
  describe user('dbuild') do
    it { should exist }
    it { should have_home_directory '/var/opt/delivery/workspace' }
  end

  # Workspace
  describe 'Workspace Configuration' do
    if %w(debian ubuntu redhat centos).include?(os[:family])
      context file('/var/opt/delivery/workspace') do
        it { should be_directory }
        it { should be_owned_by 'dbuild' }
      end

      context file('/var/opt/delivery/workspace/.chef') do
        it { should be_directory }
        it { should be_owned_by 'dbuild' }
      end

      %w(
        /var/opt/delivery/workspace/.chef/builder_key
        /var/opt/delivery/workspace/.chef/delivery.pem
        /var/opt/delivery/workspace/.chef/knife.rb
        /var/opt/delivery/workspace/etc/builder_key
        /var/opt/delivery/workspace/etc/delivery.pem
        /var/opt/delivery/workspace/etc/delivery.rb
      ).each do |dbuild_file|
        context file(dbuild_file) do
          it { should be_file }
          it { should be_owned_by 'dbuild' }
        end
      end

      %w(
        /var/opt/delivery/workspace/bin/git_ssh
        /var/opt/delivery/workspace/bin/delivery-cmd
      ).each do |root_file|
        context file(root_file) do
          it { should be_file }
          it { should be_owned_by 'root' }
        end
      end
      # TODO: Windows tests
      # else # Windows
    end
  end
end
