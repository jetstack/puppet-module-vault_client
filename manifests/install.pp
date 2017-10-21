# Private class
class vault_client::install inherits vault_client {
  file { $vault_client::install_path:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { $vault_client::bin_dir:
    ensure  => directory,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    purge   => true,
    require => File[$vault_client::install_path]
  }

  exec { "${vault_client::app_name}-${vault_client::version}-download":
    command => "${vault_client::curl_cmd} -sL ${vault_client::download_url}\
    -o ${vault_client::bin_dir}/${vault_client::app_name}-${vault_client::version}",
    creates => "${vault_client::bin_dir}/${vault_client::app_name}-${vault_client::version}",
    require => File[$vault_client::bin_dir]
  }
  -> file { "${vault_client::bin_dir}/${vault_client::app_name}-${vault_client::version}":
    ensure => 'file',
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }
  -> file { "${vault_client::bin_dir}/${vault_client::app_name}":
    ensure => 'link',
    target => "${vault_client::bin_dir}/${vault_client::app_name}-${vault_client::version}"
  }

  file { $vault_client::config_dir:
    ensure => directory,
    mode   => '0700'
  }
}
