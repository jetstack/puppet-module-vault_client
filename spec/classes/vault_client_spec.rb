require 'spec_helper'

describe 'vault_client' do
  on_supported_os(facterversion: '2.4').each do |os, os_facts|
    context "on #{os}" do
      version = '0.8.8'
      let(:facts) { os_facts }

      let(:params) do
        {
          init_token:   'test-token',
          init_role:    'test-master',
          ca_cert_path: '/etc/vault/ca.pem',
        }
      end

      it { is_expected.to compile }

      it { is_expected.to contain_class('vault_client::install') }
      it { is_expected.to contain_class('vault_client::config') }
      it { is_expected.to contain_class('vault_client::service') }

      context 'with niether of init_token and token specified' do
        let(:params) do
          {
            ca_cert_path: '/etc/vault/ca.pem',
          }
        end

        it { is_expected.to compile.and_raise_error(%r{You must provide either init_token or token}) }
      end

      context 'with init_token and token specified' do
        let(:params) do
          {
            init_token: 'test-token',
            token:      'test-token',
            ca_cert_path: '/etc/vault/ca.pem',
          }
        end

        it { is_expected.to compile.and_raise_error(%r{You must provide either init_token or token, not both}) }
      end

      it { is_expected.to contain_exec('vault_client-systemctl-daemon-reload') }

      describe 'vault_client::install' do
        context 'when default params' do
          let(:params) do
            {
              token:        'test-token',
              ca_cert_path: '/etc/vault/ca.pem',
            }
          end

          it { is_expected.to contain_file('/opt/vault-helper') }
          it { is_expected.to contain_file('/opt/vault-helper/bin') }
          it { is_expected.to contain_exec("vault-helper-#{version}-download") }
          it { is_expected.to contain_file("/opt/vault-helper/bin/vault-helper-#{version}") }
          it { is_expected.to contain_file('/opt/vault-helper/bin/vault-helper').with('target' => "/opt/vault-helper/bin/vault-helper-#{version}") }
          it { is_expected.to contain_file('/etc/vault') }
        end
      end
      describe 'vault_client::config' do
        context 'with init_token = init-token-all' do
          let(:params) do
            {
              init_token: 'init-token-all',
              init_role:  'test-master',
              ca_cert_path: '/etc/vault/ca.pem',
            }
          end

          it { is_expected.to contain_file('/etc/vault/init-token').with('content' => 'init-token-all') }
          it { is_expected.to contain_file('/etc/vault/config').with_content(%r{VAULT_INIT_ROLE=test-master}) }
          it { is_expected.not_to contain_file('/etc/vault/token') }
        end

        context 'with token = test-token' do
          let(:params) do
            {
              token: 'test-token',
              ca_cert_path: '/etc/vault/ca.pem',
            }
          end

          it { is_expected.to contain_file('/etc/vault/token').with('content' => 'test-token') }
          it { is_expected.to contain_file('/etc/vault/config').without_content(%r{VAULT_INIT_ROLE=test-master}) }
          it { is_expected.not_to contain_file('/etc/vault/init-token') }
        end
        context 'with certs' do
          let(:params) do
            {
              certs: {
                cert1: {
                  base_path: '/tmp/cert1',
                  common_name: 'cert1',
                  role: 'test-role',
                },
                cert2: {
                  base_path: '/tmp/cert2',
                  common_name: 'cert2',
                  role: 'test-role',
                },
              },
              token: 'test-token',
              ca_cert_path: '/etc/vault/ca.pem',
            }
          end

          it { is_expected.to contain_vault_client__cert_service('cert1') }
          it { is_expected.to contain_vault_client__cert_service('cert2') }
          describe 'vault_client::cert_service' do
            it { is_expected.to contain_file('/etc/systemd/system/cert1-cert.service') }
            it { is_expected.to contain_file('/etc/systemd/system/cert1-cert.timer') }
            it { is_expected.to contain_file('/etc/systemd/system/cert2-cert.service') }
            it { is_expected.to contain_file('/etc/systemd/system/cert2-cert.timer') }
            it { is_expected.to contain_file('/tmp/cert1.pem') }
            it { is_expected.to contain_file('/tmp/cert2.pem') }
            it { is_expected.to contain_service('cert1-cert.service') }
            it { is_expected.to contain_service('cert1-cert.timer') }
            it { is_expected.to contain_service('cert2-cert.service') }
            it { is_expected.to contain_service('cert2-cert.timer') }
            it { is_expected.to contain_exec('cert1-cert-create-if-missing') }
            it { is_expected.to contain_exec('cert1-cert-trigger') }
            it { is_expected.to contain_exec('cert2-cert-create-if-missing') }
            it { is_expected.to contain_exec('cert2-cert-trigger') }
          end
        end
        context 'with certs with invalid param' do
          let(:params) do
            {
              certs: {
                cert1: {
                  base_path: '/tmp/cert1',
                  common_name: 'cert1',
                  role: 'test-role',
                  gid: '0',
                },
                cert2: {
                  base_path: '/tmp/cert2',
                  common_name: 'cert2',
                  role: 'test-role',
                },
              },
              token: 'test-token',
              ca_cert_path: '/etc/vault/ca.pem',
            }
          end

          it { is_expected.not_to compile }
        end
      end
      context 'with secrets' do
        let(':params') do
          {
            secrets: {
              test1: {
                secret_path: '/test/secrets/secret',
                field: 'key',
                dest_path: '/tmp/test1',
              },
              test2: {
                secret_path: '/test/secrets/secret2',
                field: 'key',
                dest_path: '/tmp/test2',
              },
            },
            token: 'test-token',
            ca_cert_path: '/etc/vault/ca.pem',
          }
        end

        it { is_expected.to contain_file('/etc/systemd/system/test1-secret.service') }
        it { is_expected.to contain_service('test1-secret.service') }
        it { is_expected.to contain_vault_client__secret_service('test1') }
      end
      describe 'vault_client::service' do
        context 'when default params' do
          let(:params) do
            {
              token: 'test-token',
              ca_cert_path: '/etc/vault/ca.pem',
            }
          end

          it { is_expected.to contain_file('/etc/systemd/system/vault-token-renewal.service') }
          it { is_expected.to contain_file('/etc/systemd/system/vault-token-renewal.timer') }
          it { is_expected.to contain_exec('vault-token-renewal-trigger') }
          it { is_expected.to contain_service('vault-token-renewal.timer') }
        end
      end
    end
  end
end
