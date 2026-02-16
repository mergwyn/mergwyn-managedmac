require 'spec_helper'

describe 'managedmac::activedirectory', type: 'class' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:default_params) do
        {
          hostname: 'foo.ad.com',
          username: 'account',
          password: 'password',
        }
      end

      context 'when $enable == undef' do
        it { is_expected.to compile.with_all_deps }
      end

      context 'when $enable == false' do
        context 'when $provider is INVALID' do
          let(:params) do
            { enable: false, provider: 'whatever' }
          end

          it {
            is_expected.to raise_error(Puppet::PreformattedError, %r{Parameter :provider must be 'dsconfigad'})
          }
        end

        context 'when $provider == :dsconfigad' do
          specify do
            is_expected.not_to contain_dsconfigad('foo.ad.com')
          end
        end

        context "when $evaluate == 'no'" do
          let(:params) do
            { enable: false, provider: 'dsconfigad', evaluate: 'no' }
          end

          specify do
            is_expected.not_to contain_dsconfigad('foo.ad.com')
          end
        end

        context 'when $evaluate == true' do
          let(:params) do
            { enable: false, provider: 'dsconfigad', hostname: 'foo.ad.com', evaluate: 'true' }
          end

          specify do
            is_expected.to contain_dsconfigad('foo.ad.com').with_ensure('absent')
          end
        end
      end

      context 'when $enable == true' do
        context 'when $provider is INVALID' do
          let(:params) do
            { enable: false, provider: 'whatever' }
          end

          it {
            is_expected.to raise_error(Puppet::PreformattedError, %r{Parameter :provider must be 'dsconfigad'})
          }
        end

        context 'when REQUIRED params are NOT set' do
          let(:params) do
            { enable: true }
          end

          it {
            is_expected.to raise_error(Puppet::PreformattedError, %r{You must specify a.*param})
          }
        end

        context 'when $evaluate is false' do
          let(:params) do
            { enable: false, provider: 'dsconfigad', evaluate: 'false' }
          end

          context 'when $provider == :dsconfigad' do
            specify do
              is_expected.not_to contain_dsconfigad('foo.ad.com')
            end
          end

          context "when $evaluate == 'no'" do
            let(:params) do
              { enable: false, provider: 'dsconfigad', evaluate: 'no' }
            end

            specify do
              is_expected.not_to contain_dsconfigad('foo.ad.com')
            end
          end

          context 'when $evaluate == true' do
            let(:params) do
              default_params.merge(enable: false, provider: 'dsconfigad', evaluate: 'true')
            end

            specify do
              is_expected.to contain_dsconfigad('foo.ad.com').with_ensure('absent')
            end
          end
        end
      end

      context 'when $enable == true' do
        context 'when $provider is INVALID' do
          let(:params) do
            default_params.merge(enable: true, provider: 'whatever')
          end

          it {
            is_expected.to raise_error(Puppet::Error, %r{Parameter :provider must be 'dsconfigad'})
          }
        end

        context 'when $evaluate is INVALID' do
          let(:params) do
            default_params.merge(enable: true, evaluate: 'whatever')
          end

          it {
            is_expected.to raise_error(Puppet::PreformattedError, %r{Evaluation Error: Error while evaluating a Resource Statement})
          }
        end

        context 'when $provider == :dsconfigad' do
          let(:required_params) do
            default_params.merge(
              enable: true,
              computer: 'computer',
            )
          end

          context 'when REQUIRED params are set' do
            let(:params) do
              required_params
            end

            specify do
              is_expected.to contain_dsconfigad('foo.ad.com').with_ensure('present')
            end
          end

          context 'when $evaluate == undef' do
            let(:params) do
              required_params.merge(evaluate: :undef)
            end

            specify do
              is_expected.to contain_dsconfigad('foo.ad.com').with_ensure('present')
            end
          end

          context "when $evaluate == 'true'" do
            let(:params) do
              required_params.merge(evaluate: 'true')
            end

            specify do
              is_expected.to contain_dsconfigad('foo.ad.com').with_ensure('present')
            end
          end

          context "when $evaluate == 'yes'" do
            let(:params) do
              required_params.merge(evaluate: 'yes')
            end

            specify do
              is_expected.to contain_dsconfigad('foo.ad.com').with_ensure('present')
            end
          end

          context "when $evaluate == 'no'" do
            let(:params) do
              required_params.merge(evaluate: 'no')
            end

            specify do
              is_expected.not_to contain_dsconfigad('foo.ad.com')
            end
          end

          context "when $evaluate == 'false'" do
            let(:params) do
              required_params.merge(evaluate: 'false')
            end

            specify do
              is_expected.not_to contain_dsconfigad('foo.ad.com')
            end
          end
        end
      end
    end
  end
end
