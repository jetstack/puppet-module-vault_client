require 'spec_helper'

describe 'vault_client::secret_service', type: :define do
  on_supported_os(facterversion: '2.4').each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      let(:title) do
        'test1'
      end

      let(:service_name) do
        "#{title}-secret.service"
      end

      let(:service_file) do
        "/etc/systemd/system/#{service_name}"
      end

      let(:pre_condition) do
        [
          "
            class{ 'vault_client':
              token         => 'token1',
              unit_file_dir => '/etc/systemd/system',
              curl_cmd      => '/usr/bin/curl',
            }
          ",
        ]
      end

      let(:params) do
        {
          dest_path: '/tmp/dest_path1',
          secret_path: '/my/secret1',
          field: 'field1',
          user: 'user1',
          group: 'group1',
        }
      end

      context 'should create a vault secert service' do
        it do
          is_expected.to contain_service(service_name)
          is_expected.to contain_file(service_file).with_content(%r{EnvironmentFile=/etc/vault/config})
          is_expected.to contain_file(service_file).with_content(%r{/opt/bin/vault-helper read /my/secret1 -f field1 -d /tmp/dest_path1})
        end
      end
    end
  end
end
