# vault_client::config
# Private Class
class vault_client::config inherits vault_client {

  if $vault_client::init_token {
    file { $vault_client::init_token_path:
      ensure  => present,
      mode    => '0600',
      replace => false,
      owner   => 'root',
      group   => 'root',
      content => $vault_client::init_token
    }
  }

  if $vault_client::token {
    file  { $vault_client::token_path:
      ensure  => present,
      mode    => '0600',
      owner   => 'root',
      group   => 'root',
      content => $vault_client::token
    }
  }

  file { $vault_client::config_path:
    ensure  => file,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('vault_client/config.erb')
  }

  if $vault_client::certs {
    $vault_client::certs.each | $cert, $params | {
      vault_client::cert_service { $cert:
        * => $params
      }
    }
  }

  if $vault_client::secrets {
    $vault_client::secrets.each | $secret, $params | {
      vault_client::secret_service { $secret:
        * => $params
      }
    }
  }
}
