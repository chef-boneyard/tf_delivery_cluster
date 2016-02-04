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

# Attempt to use latest pacakges possible for Ubuntu releases greater than 14.04.
#
# Note that this is also guarded with a `== 'lucid'` check which is the current
# upstream behavior in apt-chef. Once this behavior is updated it should
# short-circuit this fix and then can be removed. Love, Fletcher ;)
if ubuntu_after_trusty? && node['apt-chef']['codename'] == 'lucid'
  node.set['apt-chef']['codename'] = 'trusty'
end
