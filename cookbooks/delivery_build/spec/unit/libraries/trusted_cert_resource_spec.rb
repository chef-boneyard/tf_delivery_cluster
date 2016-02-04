require 'spec_helper'
require 'chef/resource'

describe Chef::Resource::TrustedCert do
  before(:each) do
    @resource = described_class.new('Supermarket Self Sign Cert')
    @resource.path '/path/to/my/supermarket.crt'
  end

  describe '#initialize' do
    it 'creates a new Chef::Resource object and sets defaults' do
      expect(@resource).to be_a(Chef::Resource)
      expect(@resource.provider).to eql(Chef::Provider::TrustedCert)
      expect(@resource.name).to eql('Supermarket Self Sign Cert')
      expect(@resource.resource_name).to eql(:trusted_cert)

      expect(@resource.path).to eql('/path/to/my/supermarket.crt')
      expect(@resource.cacert_pem).to eql('/opt/chefdk/embedded/ssl/certs/cacert.pem')

      expect(@resource.action).to eql(:append)
      expect(@resource.allowed_actions).to include(:append)
    end
  end

  describe '#path' do
    it 'is required' do
      resource = described_class.new('I shall fail')
      expect { resource.path }
        .to raise_error(Chef::Exceptions::ValidationFailed)
    end
  end

  it 'fails if NO resource name is defined' do
    expect { described_class.new }.to raise_error(ArgumentError)
  end
end
