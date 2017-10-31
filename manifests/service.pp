# vault_client::service
# Private Class
class vault_client::service inherits vault_client {

  file { "${vault_client::unit_file_dir}/${vault_client::token_service_name}.service":
    ensure  => file,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template("${module_name}/token-renewal.service.erb"),
    notify  => Exec["${module_name}-systemctl-daemon-reload"]
  }
  ~> exec { "${vault_client::token_service_name}-trigger":
    command     => "systemctl start ${vault_client::token_service_name}.service",
    path        => $vault_client::path,
    refreshonly => true,
    require     => Exec["${module_name}-systemctl-daemon-reload"]
  }

  file { "${vault_client::unit_file_dir}/${vault_client::token_service_name}.timer":
    ensure  => file,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template("${module_name}/token-renewal.timer.erb")
  }
  ~> service { "${vault_client::token_service_name}.timer":
    ensure => 'running',
    enable => true
  }
}
