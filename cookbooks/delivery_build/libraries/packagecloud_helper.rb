#
# Copyright (c) 2014-2015 Chef Software, Inc.
# Copyright (c) 2014 Computology, LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# This is the Proxy Implementation to pull down packages from packagecloud
# currently there is a PR to the packagecloud community cookbook:
# => https://github.com/computology/packagecloud-cookbook/pull/14
module PackageCloud
  module Helper
    def get(uri, params)
      uri.query = URI.encode_www_form(params)
      req       = Net::HTTP::Get.new(uri.request_uri)

      http_request(uri, req)
    end

    def post(uri, params)
      req           = Net::HTTP::Post.new(uri.request_uri)
      req.form_data = params

      req.basic_auth uri.user, uri.password if uri.user

      http_request(uri, req)
    end

    def http_request(uri, request)
      proxy_url = Chef::Config['https_proxy'] || Chef::Config['http_proxy'] || ENV['https_proxy'] || ENV['http_proxy']
      if proxy_url
        proxy_uri = URI.parse(proxy_url)
        proxy     = Net::HTTP::Proxy(proxy_uri.host, proxy_uri.port, proxy_uri.user, proxy_uri.password)

        response = proxy.start(uri.host, use_ssl: true) do |http|
          http.request(request)
        end
      else
        http = Net::HTTP.new(uri.hostname, uri.port)
        http.use_ssl = true

        response = http.start { |h| h.request(request) }
      end

      fail response.inspect unless response.is_a? Net::HTTPSuccess
      response
    end
  end
end
