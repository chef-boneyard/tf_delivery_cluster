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

require 'chef/resource'

class Chef
  class Resource
    class TrustedCert < Chef::Resource
      provides :trusted_cert

      def initialize(name, run_context = nil)
        super

        @resource_name = :trusted_cert
        @provider = Chef::Provider::TrustedCert

        # This is the default location of the cacert.pem in chefdk
        @cacert_pem = DeliveryBuild::PathHelper.omnibus_embedded_path('chefdk', 'ssl/certs/cacert.pem')

        @action = :append
        @allowed_actions.push(:append)
      end

      #
      # The `path` of the certificate we want to append to the `cacert_pem`
      #
      def path(arg = nil)
        set_or_return(
          :path,
          arg,
          kind_of: String,
          required: true
        )
      end

      #
      # The `cacert.pem` that we want to manipulate
      #
      def cacert_pem(arg = nil)
        set_or_return(:cacert_pem, arg, kind_of: String)
      end
    end
  end
end
