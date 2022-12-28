output "id" {
  value = oci_core_instance.Zabbix.*.id
}

output "public_ip" {
  value = join(", ", oci_core_instance.Zabbix.*.public_ip)
}

output "zabbix_user_name" {
  value = var.zabbix_name
}

output "zabbix_schema_name" {
  value = var.zabbix_schema
}

output "zabbix_host_name" {
  value = oci_core_instance.Zabbix.*.display_name
}
