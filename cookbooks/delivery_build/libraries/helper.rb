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
# Why is this a class, and not a module? Why not a class method?
#
# Well, kids - turns out the way Chef loads these makes it impossible
# to mock a Class method. So we can't test this cookbook if we do that.
# Good times.
class DeliveryHelper
  def self.encrypted_data_bag_item(bag, id, secret = nil)
    dh = DeliveryHelper.new
    dh.encrypted_data_bag_item(bag, id, secret)
  end

  def encrypted_data_bag_item(bag, id, secret = nil)
    Chef::Log.debug "Loading encrypted data bag item #{bag}/#{id}"

    if secret.nil? && Chef::Config[:encrypted_data_bag_secret].nil?
      fail 'Please specify Chef::Config[:encrypted_data_bag_secret]'
    end

    secret ||= File.read(Chef::Config[:encrypted_data_bag_secret]).strip
    Chef::EncryptedDataBagItem.load(bag, id, secret)
  end
end
