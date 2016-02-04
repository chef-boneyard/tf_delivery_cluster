#
# Copyright:: Copyright (c) 2015 Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/provider'

class Chef
  class Provider
    class TrustedCert < Chef::Provider
      def whyrun_supported?
        true
      end

      def load_current_resource
        # not needed, but need to override
      end

      def action_append
        converge_by "Append #{new_resource.name} to " \
                    "#{new_resource.cacert_pem}" do
          unless trusted_cert_exists?
            append_trusted_cert
            new_resource.updated_by_last_action(true)
          end
        end
      end

      private

      #
      # Append the provided trusted_cert to the cacert.pem file
      #
      def append_trusted_cert
        ::File.open(new_resource.cacert_pem, 'a') do |io|
          io.puts "\nDelivery #{new_resource.name}"
          io.puts '========================='
          io.puts contents
        end
      end

      #
      # Validate that the cert is not already on the cacert.pem file
      #
      def trusted_cert_exists?
        ::File.read(new_resource.cacert_pem).match(Regexp.escape(contents))
      end

      def contents
        ::File.read(Chef::Config.platform_specific_path(new_resource.path))
      end
    end
  end
end
