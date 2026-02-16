require 'spec_helper'

# describe 'managedmac::ntp', :type => 'class' do
describe 'managedmac::ntp' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:service) do
        case facts[:macosx_productversion_major]
        when '10.12'
          'org.ntp.ntpd'
        else
          'com.apple.timed'
        end
      end

      context 'when $enable is invalid' do
        let(:params) do
          { enable: 'whatever' }
        end

        it { is_expected.to raise_error(Puppet::PreformattedError, %r{Evaluation Error: Error while evaluating a Resource Statement}) }
      end

      context 'when $servers is invalid' do
        let(:params) do
          { enable: 'whatever' }
        end

        it { is_expected.to raise_error(Puppet::PreformattedError, %r{Evaluation Error: Error while evaluating a Resource Statement}) }
      end

      context 'when $enable == undef' do
        let(:params) do
          { enable: :undef }
        end

        it { is_expected.to compile.with_all_deps }
      end

      context 'when $enable == false' do
        let(:params) do
          {
            enable: false,
            servers: ['time.apple.com', 'time1.google.com'],
          }
        end

        specify do
          is_expected.to contain_file('ntp_conf').that_comes_before("Service[#{service}]")\
                                                 .with('content' => "server\stime.apple.com")
        end
        specify do
          is_expected.to contain_service(service).that_requires('File[ntp_conf]')\
                                                 .with('ensure' => 'stopped', 'enable' => true)
        end
        it { is_expected.not_to contain_exec('ntp_sync') }
      end

      context 'when $enable == true' do
        let(:params) do
          {
            enable: true,
            servers: ['time.apple.com', 'time1.google.com'],
          }
        end

        specify do
          is_expected.to contain_file('ntp_conf').that_comes_before("Service[#{service}]").with(
            'content' => <<-DOC.gsub(%r{^\s+}, '')
                              # This file is managed by Puppet, and is refreshed regularly.
                              server time.apple.com
                              server time1.google.com
                            DOC
          )
        end
        specify do
          is_expected.to contain_service(service).that_requires('File[ntp_conf]')\
                                                 .with('ensure' => 'running', 'enable' => true)
        end
      end
    end
  end
end
