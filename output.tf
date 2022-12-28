output "zabbix_public_ip" {
  value = module.zabbix.public_ip
}

output "zabbix_db_user" {
  value = module.zabbix.zabbix_user_name
}

output "zabbix_schema" {
  value = module.zabbix.zabbix_schema_name
}

output "zabbix_db_password" {
  value = var.zabbix_password
}

output "heatwave_instance_ip" {
  value = module.mds-instance.private_ip
}

output "ssh_private_key" {
  value = local.private_key_to_show
}
