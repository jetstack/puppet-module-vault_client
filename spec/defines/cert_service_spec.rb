require 'spec_helper'

describe 'vault_client::cert_service', type: :define do
  on_supported_os(facterversion: '2.4').each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      let(:title) do
        'test1'
      end

      let(:service_name) do
        "#{title}-cert.service"
      end

      let(:timer_name) do
        "#{title}-cert.timer"
      end

      let(:service_file) do
        "/etc/systemd/system/#{service_name}"
      end

      let(:timer_file) do
        "/etc/systemd/system/#{timer_name}"
      end

      let(:pre_condition) do
        [
          "
          class{'vault_client':
            token => 'token1'
          }
          ",
        ]
      end

      let(:params) do
        {
          common_name: 'commonname1',
          role: 'role1',
          base_path: '/tmp/test',
        }
      end

      context 'should create a vault cert service' do
        it do
          is_expected.to contain_service(timer_name)
          is_expected.to contain_file(service_file).with_content(%r{EnvironmentFile=/etc/vault/config})
          is_expected.to contain_file(timer_file)
          is_expected.to contain_file('/tmp/test.pem')
          is_expected.to contain_exec('test1-cert-create-if-missing')
          is_expected.to contain_exec('test1-cert-trigger')
          is_expected.to contain_service('test1-cert.service')
        end
      end
    end
  end
end
