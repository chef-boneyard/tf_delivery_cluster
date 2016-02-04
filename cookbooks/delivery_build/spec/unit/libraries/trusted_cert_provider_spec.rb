require 'spec_helper'
require 'chef/provider'
require 'chef/node'
require 'chef/run_context'
require 'chef/event_dispatch/dispatcher'

describe Chef::Provider::TrustedCert do
  let(:node) { Chef::Node.new }
  let(:events) { Chef::EventDispatch::Dispatcher.new }
  let(:run_context) { Chef::RunContext.new(node, {}, events) }
  let(:new_resource) { Chef::Resource::TrustedCert.new('Delivery Cert') }
  let(:provider) { described_class.new(new_resource, run_context) }
  let(:cacert_pem) do
    <<-EOF
MY AWESOME CERT
===============
-----BEGIN CERTIFICATE-----
MIICPDCCAaUCEDyRMcsf9tAbDpq40ES/Er4wDQYJKoZIhvcNAQEFBQAwXzELMAkGA1UEBhMCVVMx
CEHwxWsKzH4PIRnN5GfcX6kb5sroc50i2JhucwNhkcV8sEVAbkSdjbCxlnRhLQ2pRdKkkirWmnWX
bj9T/UWZYB2oK0z5XqcJ2HUw19JlYD1n1khVdWk/kfVIC0dpImmClr7JyDiGSnoscxlIaU5rfGW/
-----END CERTIFICATE-----
    EOF
  end
  let(:new_cert) do
    <<-EOF
-----BEGIN CERTIFICATE-----
MIIFjTCCA3WgAwIBAgIEGErM1jANBgkqhkiG9w0BAQsFADBWMQswCQYDVQQGEwJDTjEwMC4GA1UE
CgwnQ2hpbmEgRmluYW5jaWFsIENlcnRpZmljYXRpb24gQXV0aG9yaXR5MRUwEwYDVQQDDAxDRkNB
IEVWIFJPT1QwHhcNMTIwODA4MDMwNzAxWhcNMjkxMjMxMDMwNzAxWjBWMQswCQYDVQQGEwJDTjEw
-----END CERTIFICATE-----
    EOF
  end
  let(:both_certs_together) do
    <<-EOF
MY AWESOME CERT
===============
-----BEGIN CERTIFICATE-----
MIICPDCCAaUCEDyRMcsf9tAbDpq40ES/Er4wDQYJKoZIhvcNAQEFBQAwXzELMAkGA1UEBhMCVVMx
CEHwxWsKzH4PIRnN5GfcX6kb5sroc50i2JhucwNhkcV8sEVAbkSdjbCxlnRhLQ2pRdKkkirWmnWX
bj9T/UWZYB2oK0z5XqcJ2HUw19JlYD1n1khVdWk/kfVIC0dpImmClr7JyDiGSnoscxlIaU5rfGW/
-----END CERTIFICATE-----

Delivery Cert
===============
-----BEGIN CERTIFICATE-----
MIIFjTCCA3WgAwIBAgIEGErM1jANBgkqhkiG9w0BAQsFADBWMQswCQYDVQQGEwJDTjEwMC4GA1UE
CgwnQ2hpbmEgRmluYW5jaWFsIENlcnRpZmljYXRpb24gQXV0aG9yaXR5MRUwEwYDVQQDDAxDRkNB
IEVWIFJPT1QwHhcNMTIwODA4MDMwNzAxWhcNMjkxMjMxMDMwNzAxWjBWMQswCQYDVQQGEwJDTjEw
-----END CERTIFICATE-----
    EOF
  end

  before do
    new_resource.path '/my/new/awesome.cert'
  end

  describe '#action_append' do
    context 'when the trusted_cert does not exists' do
      before do
        allow(::File).to receive(:read)
          .with('/opt/chefdk/embedded/ssl/certs/cacert.pem')
          .and_return(cacert_pem)
        allow(::File).to receive(:read)
          .with('/my/new/awesome.cert')
          .and_return(new_cert)
        allow(::File).to receive(:open)
          .and_return(true)
      end
      it 'appends the provided cert to the chefdk/cacert' do
        provider.action_append
        expect(new_resource.updated_by_last_action?).to eql(true)
      end
    end

    context 'when the trusted_cert exists' do
      before do
        allow(::File).to receive(:read)
          .with('/opt/chefdk/embedded/ssl/certs/cacert.pem')
          .and_return(both_certs_together)
        allow(::File).to receive(:read)
          .with('/my/new/awesome.cert')
          .and_return(new_cert)
      end
      it 'does not appends the cert' do
        provider.action_append
        expect(new_resource.updated_by_last_action?).to eql(false)
      end
    end
  end
end
