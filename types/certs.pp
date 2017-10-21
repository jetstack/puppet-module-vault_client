# Struct for certs
type Vault_client::Certs = Hash[ String, Struct[{
  base_path           => String,
  common_name         => String,
  role                => String,
  Optional[uid]       => Integer,
  Optional[gid]       => Integer,
  Optional[key_type]  => String,
  Optional[key_bits]  => Integer,
  Optional[frequency] => Integer,
  Optional[exec_post] => Array,
  Optional[alt_names] => Array[String],
  Optional[ip_sans]   => Array[String]
}]]
