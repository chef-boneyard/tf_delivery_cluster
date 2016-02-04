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
require 'chefspec'
require 'chefspec/berkshelf'
require 'chef/sugar'

ChefSpec::Coverage.start!

TOPDIR = File.expand_path(File.join(File.dirname(__FILE__), '..'))
$LOAD_PATH << File.expand_path(File.dirname(__FILE__))
Dir.glob('libraries/*.rb') { |file| require File.expand_path(file) }

RSpec.configure do |config|
  config.before(:each) do
    # We need to stub the build_user_home because ChefSpec isn't smart enough
    # to realize that a resource has already been touched once the attribute
    # changes. Global state is hard...
    allow_any_instance_of(Chef::Recipe).to receive(:build_user_home)
      .and_return('/home/omnibus')
  end

  config.log_level = :fatal

  # Guard against people using deprecated RSpec syntax
  config.raise_errors_for_deprecations!

  # Why aren't these the defaults?
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  # Set a default platform (this is overriden as needed)
  config.platform  = 'ubuntu'
  config.version   = '12.04'

  # Be random!
  config.order = 'random'
end

def default_mocks
  dh = double('DeliveryHelper')
  allow(dh).to receive(:encrypted_data_bag_item).with(any_args).and_return(
    'builder_key' => 'rocks_is_aerosmiths_best_album',
    'delivery_pem' => 'toys_in_the_attic_is_aerosmiths_best_album'
  )
  allow(DeliveryHelper).to receive(:new).and_return(dh)
  stub_command('chef --version | grep 0.4.0').and_return(false)
  stub_command('knife ssl check -c /var/opt/delivery/workspace/etc/delivery.rb').and_return(false)
  stub_command('knife ssl check -c /var/opt/delivery/workspace/etc/delivery.rb https://192.168.33.1').and_return(false)
  stub_command('knife ssl check -c C:/delivery/ws/etc/delivery.rb').and_return(false)
  stub_command('knife ssl check -c C:/delivery/ws/etc/delivery.rb https://192.168.33.1').and_return(false)
  stub_command("    $KeyPath = 'HKLM:\\SYSTEM\\CurrentControlSet\\Services\\pushy-client'\n    (Get-ItemProperty -Path $KeyPath).ImagePath.Contains('-c /etc/chef/push-jobs-client.rb')\n")
end
