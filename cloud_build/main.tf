 provider "azurerm" {
   subscription_id = "${var.subscription_id}"
#   client_id       = "REPLACE-WITH-YOUR-CLIENT-ID"
#   client_secret   = "REPLACE-WITH-YOUR-CLIENT-SECRET"
#   tenant_id       = "REPLACE-WITH-YOUR-TENANT-ID"
 }

resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group}"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.resource_group}vnet"
  location            = "${var.location}"
  address_space       = ["${var.address_space}"]
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_subnet" "app_subnet" {
  name                 = "app_subnet"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  address_prefix       = "${var.subnet_prefix_app}"
  network_security_group_id = "${azurerm_network_security_group.bug_app_nsg.id}"
}

resource "azurerm_subnet" "backend_subnet" {
  name                 = "backend_subnet"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  address_prefix       = "${var.subnet_prefix_backend}"
  network_security_group_id = "${azurerm_network_security_group.bug_db_nsg.id}"
}

resource "azurerm_network_security_group" "bug_app_nsg" {
  name                = "bugzilla-access"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group}"
  depends_on          = ["azurerm_resource_group.rg"]
}

resource "azurerm_network_security_rule" "ssh" {
  name                        = "ssh-inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "${var.whatsmyip}/32"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group}"
  network_security_group_name = "${azurerm_network_security_group.bug_app_nsg.name}"
}

resource "azurerm_network_security_rule" "http" {
  name                        = "http-inbound"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group}"
  network_security_group_name = "${azurerm_network_security_group.bug_app_nsg.name}"
}

resource "azurerm_network_security_rule" "default_deny" {
  name                        = "default-deny"
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group}"
  network_security_group_name = "${azurerm_network_security_group.bug_app_nsg.name}"
}

resource "azurerm_network_security_group" "bug_db_nsg" {
  name                = "bugzilla-db-access"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group}"
  depends_on          = ["azurerm_resource_group.rg"]
}

resource "azurerm_network_security_rule" "ssh_db" {
  name                        = "ssh-inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "${var.whatsmyip}/32"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group}"
  network_security_group_name = "${azurerm_network_security_group.bug_db_nsg.name}"
}

resource "azurerm_network_security_rule" "web_allow" {
  name                        = "inbound-from-webserver"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "10.1.0.40/32"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group}"
  network_security_group_name = "${azurerm_network_security_group.bug_db_nsg.name}"
}

resource "azurerm_network_security_rule" "default_deny_db" {
  name                        = "default-deny"
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group}"
  network_security_group_name = "${azurerm_network_security_group.bug_db_nsg.name}"
}
resource "azurerm_network_interface" "app_nic" {
  name                = "${var.rg_prefix}app_nic"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  depends_on          = ["azurerm_subnet.app_subnet"]

  ip_configuration {
    name                          = "${var.rg_prefix}ipconfig"
#    subnet_id                     = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group}/providers/Microsoft.Network/virtualNetworks/${var.resource_group}vnet/subnets/app_subnet"
    subnet_id                     = "${azurerm_subnet.app_subnet.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.0.40"
    public_ip_address_id          = "${azurerm_public_ip.app_pip.id}"
  }
}

resource "azurerm_network_interface" "db_nic" {
  name                = "${var.rg_prefix}db_nic"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  depends_on          = ["azurerm_subnet.backend_subnet"]

  ip_configuration {
    name                          = "${var.rg_prefix}ipconfig"
#    subnet_id                     = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group}/providers/Microsoft.Network/virtualNetworks/${var.resource_group}vnet/subnets/backend_subnet"
    subnet_id                     = "${azurerm_subnet.backend_subnet.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.0.140"
    public_ip_address_id          = "${azurerm_public_ip.db_pip.id}"
  }
}

resource "azurerm_public_ip" "app_pip" {
  name                         = "${var.rg_prefix}app-ip"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "Dynamic"
  domain_name_label            = "${var.dns_name}"
}

resource "azurerm_public_ip" "db_pip" {
  name                         = "${var.rg_prefix}db-ip"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "Dynamic"
  domain_name_label            = "${var.dns_name_db}"
}

#resource "azurerm_storage_account" "stor" {
#  name                     = "${var.dns_name}stor"
#  location                 = "${var.location}"
#  resource_group_name      = "${azurerm_resource_group.rg.name}"
#  account_tier             = "${var.storage_account_tier}"
#  account_replication_type = "${var.storage_replication_type}"
#}

#resource "azurerm_managed_disk" "app_datadisk" {
#  name                 = "${var.hostname}-datadisk"
#  location             = "${var.location}"
#  resource_group_name  = "${azurerm_resource_group.rg.name}"
#  storage_account_type = "Standard_LRS"
#  create_option        = "Empty"
#  disk_size_gb         = "1023"
#}

#resource "azurerm_managed_disk" "db_datadisk" {
#  name                 = "${var.db_hostname}-datadisk"
#  location             = "${var.location}"
#  resource_group_name  = "${azurerm_resource_group.rg.name}"
#  storage_account_type = "Standard_LRS"
#  create_option        = "Empty"
#  disk_size_gb         = "1023"
#}

resource "azurerm_virtual_machine" "app_vm" {
  name                  = "${var.rg_prefix}app_vm"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  vm_size               = "${var.vm_size}"
  network_interface_ids = ["${azurerm_network_interface.app_nic.id}"]

  storage_image_reference {
    publisher = "${var.image_publisher}"
    offer     = "${var.image_offer}"
    sku       = "${var.image_sku}"
    version   = "${var.image_version}"
  }

  storage_os_disk {
    name              = "${var.hostname}-osdisk"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

#  storage_data_disk {
#    name              = "${var.hostname}-datadisk"
#    managed_disk_id   = "${azurerm_managed_disk.app_datadisk.id}"
#    managed_disk_type = "Standard_LRS"
#    disk_size_gb      = "1023"
#    create_option     = "Attach"
#    lun               = 0
#  }

  os_profile {
    computer_name  = "${var.hostname}"
    admin_username = "${var.admin_username}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/${var.admin_username}/.ssh/authorized_keys"
#      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDiQwpJnHVGKv8pgGtXJ0s6RIVdi1P10XsSIAnHMWsqzV3qdR0b2LXr1/KSj3OtUx3i8b018d7ml7t7tH9Bfr1+6tl5pOWD/d563FaY1QxYxKxcmwPUq1JZ9xq6iJ/mW5KHBdu11lLETcbMFOBWyqsp2aLiEHYCZwkp8zxjxfqWqf+gZCVcbfCp6Xn9YggGze/dVCV5fRD0BB88J+Rf5okGxjJW7nt/3uQZJoEWzauG+QdMhCNeBLyWBmEAyi1/wNv4GQhhp9xtJoMfwxvEQaiW6h2amFDhQNCKPODqVphFtTYIAX8wXp910OKccJY8WD3wPKJ1+X89PNBSxK6BU8Vh vmadmin" 
      key_data = "${var.public_key}"
    }
 }


#  boot_diagnostics {
#    enabled     = false
#    storage_uri = "${azurerm_storage_account.stor.primary_blob_endpoint}"
#  }
}

resource "azurerm_virtual_machine" "db_vm" {
  name                  = "${var.rg_prefix}db_vm"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  vm_size               = "${var.vm_size}"
  network_interface_ids = ["${azurerm_network_interface.db_nic.id}"]

  storage_image_reference {
    publisher = "${var.image_publisher}"
    offer     = "${var.image_offer}"
    sku       = "${var.image_sku}"
    version   = "${var.image_version}"
  }

  storage_os_disk {
    name              = "${var.db_hostname}-osdisk"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

#  storage_data_disk {
#    name              = "${var.db_hostname}-datadisk"
#    managed_disk_id   = "${azurerm_managed_disk.db_datadisk.id}"
#    managed_disk_type = "Standard_LRS"
#    disk_size_gb      = "1023"
#    create_option     = "Attach"
#    lun               = 0
#  }

  os_profile {
    computer_name  = "${var.db_hostname}"
    admin_username = "${var.admin_username}"
#    admin_password = "${var.admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/${var.admin_username}/.ssh/authorized_keys"
#      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDiQwpJnHVGKv8pgGtXJ0s6RIVdi1P10XsSIAnHMWsqzV3qdR0b2LXr1/KSj3OtUx3i8b018d7ml7t7tH9Bfr1+6tl5pOWD/d563FaY1QxYxKxcmwPUq1JZ9xq6iJ/mW5KHBdu11lLETcbMFOBWyqsp2aLiEHYCZwkp8zxjxfqWqf+gZCVcbfCp6Xn9YggGze/dVCV5fRD0BB88J+Rf5okGxjJW7nt/3uQZJoEWzauG+QdMhCNeBLyWBmEAyi1/wNv4GQhhp9xtJoMfwxvEQaiW6h2amFDhQNCKPODqVphFtTYIAX8wXp910OKccJY8WD3wPKJ1+X89PNBSxK6BU8Vh vmadmin" 
      key_data = "${var.public_key}"
    }
 }

#  boot_diagnostics {
#    enabled     = false
#    storage_uri = "${azurerm_storage_account.stor.primary_blob_endpoint}"
#  }
}
