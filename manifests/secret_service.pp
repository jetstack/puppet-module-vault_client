# TODO: document
define vault_client::secret_service (
  String $secret_path,
  String $field,
  String $dest_path,
  Integer $uid = 0,
  Integer $gid = 0,
  String $user = 'root',
  String $group = 'root',
  Array $exec_post = [],
)
{
  $service_name = "${name}-secret"

  file { "${vault_client::unit_file_dir}/${service_name}.service":
    ensure  => file,
    content => template("${module_name}/secret.service.erb"),
    notify  => Exec["${module_name}-systemctl-daemon-reload"],
  }

  service { "${service_name}.service":
    ensure    => 'running',
    enable    => true,
    subscribe => File["${vault_client::unit_file_dir}/${service_name}.service"]
  }
}
