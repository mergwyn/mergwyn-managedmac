require 'spec_helper'

describe 'managedmac::logouthook', type: 'class' do
  context 'when passed no params' do
    it { is_expected.not_to contain_managedmac__hook('logout') }
  end

  context 'when enable == true' do
    context 'when $scripts is undefined' do
      let(:params) do
        { enable: true }
      end

      it { is_expected.to raise_error(Puppet::Error, %r{not an absolute path}) }
    end

    context 'when scripts is defined' do
      the_scripts = '/Library/Logouthooks'
      let(:params) do
        { enable: true, scripts: the_scripts }
      end

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
