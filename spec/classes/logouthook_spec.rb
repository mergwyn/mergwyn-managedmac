require 'spec_helper'

describe 'managedmac::logouthook', type: 'class' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'when passed no params' do
        it { is_expected.not_to contain_managedmac__hook('logout') }
      end

      context 'when enable == true' do
        context 'when $scripts is undefined' do
          let(:params) do
            { enable: true }
          end

          it { is_expected.to raise_error(Puppet::PreformattedError, %r{Evaluation Error: Error while evaluating a Resource Statement}) }
        end

        context 'when scripts is defined' do
          the_scripts = '/Library/Logouthooks'
          let(:params) do
            { enable: true, scripts: the_scripts }
          end

          it { is_expected.to contain_file(the_scripts) }

          it {
            is_expected.to contain_managedmac__hook('logout').with(
              'enable'  => true,
              'scripts' => the_scripts,
            )
          }
        end
      end

      context 'when enable == false' do
        let(:params) do
          { enable: false }
        end

        it {
          is_expected.to contain_managedmac__hook('logout').with(
            'enable'  => false,
            'scripts' => nil,
          )
        }
      end
    end
  end
end
