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

class DeliveryBuild
  class PathHelper
    def self.omnibus_path(product, path)
      if Chef::Platform.windows?
        ::File.join('C:', 'opscode', product, path)
      else
        ::File.join('/opt', product, path)
      end
    end

    def self.omnibus_embedded_path(product, path)
      omnibus_path(product, ::File.join('embedded', path))
    end

    def self.omnibus_chefdk_paths
      [omnibus_path('chefdk', 'bin'), omnibus_embedded_path('chefdk', 'bin')].compact.join(::File::PATH_SEPARATOR)
    end
  end
end
