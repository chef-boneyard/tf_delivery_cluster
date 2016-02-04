require 'spec_helper'

describe DeliveryBuild::PathHelper do
  describe '.omnibus_chefdk_paths' do
    context 'on windows' do
      before do
        ENV['SYSTEMDRIVE'] = 'C:'
        stub_const('File::PATH_SEPARATOR', ';')
        allow(Chef::Platform).to receive(:windows?).and_return(true)
      end

      let(:chefdk)          { 'C:/opscode/chefdk/bin' }
      let(:chefdk_embedded) { 'C:/opscode/chefdk/embedded/bin' }

      it 'returns a windows like path with chefdk' do
        expect(DeliveryBuild::PathHelper.omnibus_chefdk_paths).to eq("#{chefdk};#{chefdk_embedded}")
      end
    end

    context 'elsewhere' do
      let(:chefdk)          { '/opt/chefdk/bin' }
      let(:chefdk_embedded) { '/opt/chefdk/embedded/bin' }

      it 'returns a linux like path with chefdk' do
        expect(DeliveryBuild::PathHelper.omnibus_chefdk_paths).to eq("#{chefdk}:#{chefdk_embedded}")
      end
    end
  end

  describe '.omnibus_embedded_path' do
    let(:product) { 'chefdk' }
    let(:path) { 'ssl/certs' }

    context 'on Windows' do
      before do
        ENV['SYSTEMDRIVE'] = 'C:'
        stub_const('File::PATH_SEPARATOR', ';')
        allow(Chef::Platform).to receive(:windows?).and_return(true)
      end

      it 'returns Windows location' do
        expect(DeliveryBuild::PathHelper.omnibus_embedded_path(product, path)).to eq('C:/opscode/chefdk/embedded/ssl/certs')
      end
    end

    context 'elsewhere' do
      it 'returns POSIX location' do
        expect(DeliveryBuild::PathHelper.omnibus_embedded_path(product, path)).to eq('/opt/chefdk/embedded/ssl/certs')
      end
    end
  end
end
