# vault_client
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include vault_client
class vault_client (
  String            $app_name,
  String            $token_service_name,
  String            $version,
  String            $download_url,
  String            $curl_cmd,
  String            $install_path,
  String            $bin_dir,
  String            $config_dir,
  String            $server_url,
  String            $unit_file_dir,
  String            $ca_cert_path,
  String            $config_path,
  String            $helper_path,
  String            $token_path,
  String            $init_token_path,
  Integer           $timer_frequency,
  Optional[String]  $init_token,
  Optional[String]  $token,
  Optional[String]  $init_role,
  Optional[Vault_client::Certs] $certs,
  Optional[Vault_client::Secrets] $secrets,
) {
  $path = defined($::path) ? {
    default => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/bin',
    true    => $::path,
  }

  if !$init_token and !$token {
    fail('You must provide either init_token or token')
  }

  if $init_token and $token {
    fail('You must provide either init_token or token, not both')
  }

  if $init_token {
    $init_token_enabled = true
  } else {
    $init_token_enabled = false
  }

  exec { "${module_name}-systemctl-daemon-reload":
    command     => 'systemctl daemon-reload',
    refreshonly => true,
    path        => $path
  }

  contain vault_client::install
  contain vault_client::config
  contain vault_client::service

  Class['vault_client::install']
  -> Class['vault_client::config']
  ~> Class['vault_client::service']
}
