output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "vm_public_ip" {
  value = azurerm_public_ip.this.ip_address
}

output "vm_ssh_command" {
  value = "ssh ${var.admin_username}@${azurerm_public_ip.this.ip_address}"
}

output "servicebus_namespace_name" {
  value = azurerm_servicebus_namespace.this.name
}

output "servicebus_topic_name" {
  value = azurerm_servicebus_topic.this.name
}

output "servicebus_connection_string" {
  value     = azurerm_servicebus_namespace_authorization_rule.app.primary_connection_string
  sensitive = true
}

output "servicebus_env_line" {
  value     = "SERVICE_BUS_CONNECTION_STRING=${azurerm_servicebus_namespace_authorization_rule.app.primary_connection_string}"
  sensitive = true
}
