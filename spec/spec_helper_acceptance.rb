require 'beaker-rspec'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

UNSUPPORTED_PLATFORMS = %w([windows] [Darwin]).freeze

run_puppet_install_helper
install_ca_certs unless ENV['PUPPET_INSTALL_TYPE'] =~ %r{pe}i
install_module_on(hosts)
install_module_dependencies_on(hosts)

RSpec.configure do |c|
  module_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  c.formatter = :documentation

  c.before :suite do
    # Sync modules to all hosts
    hosts.each do |host|
      if fact_on(host, 'osfamily') == 'Debian'
        on host, 'apt-get install -y unzip'
      elsif fact_on(host, 'osfamily') == 'RedHat'
        on host, 'yum install -y unzip'
      end
      on host, 'iptables -F INPUT'
      on host, 'ln -sf /etc/puppetlabs/code/modules/vault_client/files/vault-dev-server.service /etc/systemd/system/vault-dev-server.service'
      on host, 'systemctl daemon-reload'
      on host, 'systemctl start vault-dev-server.service'
      copy_module_to(host, source: module_root, module_name: 'vault_client')
    end
  end
end
