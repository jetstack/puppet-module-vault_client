# A struct to define required inputs for getting vault secrets
type  Vault_client::Secrets = Hash[String, Struct[{
  secret_path         => String,
  field               => String,
  dest_path           => String,
  Optional[uid]       => Integer,
  Optional[gid]       => Integer,
  Optional[user]      => String,
  Optional[exec_post] => Array
}]]
