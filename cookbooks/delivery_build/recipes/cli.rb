if node['delivery_build']['delivery-cli']['artifact']
  extension = value_for_platform_family(debian: 'deb', rhel: 'rpm', windows: 'msi')
  pkg_path = "#{Chef::Config[:file_cache_path]}/delivery-cli.#{extension}"

  remote_file pkg_path do
    checksum node['delivery_build']['delivery-cli']['checksum'] if node['delivery_build']['delivery-cli']['checksum']
    source node['delivery_build']['delivery-cli']['artifact']
  end

  package 'delivery-cli' do
    source pkg_path
    version node['delivery_build']['delivery-cli']['version']
    provider value_for_platform_family(
      debian:  Chef::Provider::Package::Dpkg,
      rhel:    Chef::Provider::Package::Rpm,
      windows: Chef::Provider::Package::Windows
    )
  end
else
  chef_ingredient 'delivery-cli' do
    channel node['delivery_build']['repo_name'].sub(%r{^chef/}, '').to_sym
    options node['delivery_build']['delivery-cli']['options']
    action :upgrade
  end
end
