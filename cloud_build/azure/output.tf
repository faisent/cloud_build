output "webserver address" {
  value = "${azurerm_public_ip.app_pip.domain_name_label}.${azurerm_public_ip.app_pip.location}.cloudapp.azure.com"
}

output "dbserver address" {
  value = "${azurerm_public_ip.db_pip.domain_name_label}.${azurerm_public_ip.db_pip.location}.cloudapp.azure.com"
}
