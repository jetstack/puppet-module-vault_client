# vault_client::cert_service
# TODO: This likely can be converted to a puppet task, once that project is stable
# A description of what this defined type does
#
# @summary A short summary of the purpose of this defined type.
#
# @example
#   vault_client::cert_service { 'namevar': }
define vault_client::cert_service(
  String        $base_path,
  String        $common_name,
  String        $role,
  Integer       $uid = 0,
  Integer       $gid = 0,
  String        $key_type = 'rsa',
  Integer       $key_bits = 2048,
  Integer       $freguency = 86400,
  Array         $exec_post = [],
  Array[String] $alt_names = [],
  Array[String] $ip_sans  = [],
) {

  $service_name = "${name}-cert"
  $trigger_cmd  = "/usr/bin/systemctl start ${service_name}.service"

  file { "${vault_client::unit_file_dir}/${service_name}.service":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/cert.service.erb"),
  }
  ~> service { "${service_name}.service" :
    enable  => true,
    require => File["${vault_client::unit_file_dir}/${service_name}.service"],
    notify  => Exec["${module_name}-systemctl-daemon-reload"]
  }

  exec { "${service_name}-trigger":
    command     => $trigger_cmd,
    user        => 'root',
    refreshonly => true,
    notify      => Exec["${module_name}-systemctl-daemon-reload"]
  }
  -> exec { "${service_name}-create-if-missing":
    command => $trigger_cmd,
    creates => "${base_path}.pem",
    path    => $vault_client::path,
    notify  => Exec["${module_name}-systemctl-daemon-reload"]
  }
  -> file { "${base_path}.pem":
    ensure => present,
    mode   => '0644',
    owner  => 'root',
    group  => 'root'
  }


  file { "${vault_client::unit_file_dir}/${service_name}.timer":
    ensure  => file,
    content => template("${module_name}/cert.timer.erb"),
    notify  => Exec["${module_name}-systemctl-daemon-reload"]
  }
  ~> service { "${service_name}.timer":
    ensure => 'running',
    enable => true,
    notify => Exec["${module_name}-systemctl-daemon-reload"]
  }
}
