variable "resource_group" {
  description = "The name of the resource group in which to create the virtual network."
}

variable "subscription_id" {
  description = "The subscription ID for this deploy"
  default = "39ac48fb-fea0-486a-ba84-e0ae9b06c663"
}

variable "location" {
  description = "The location/region where the virtual network is created. Changing this forces a new resource to be created."
  default     = "eastus"
}

variable "whatsmyip" {
  description = "Get your TF/hopefully ansible host's PIP and put here, used for allowing ssh to the nodes"
}

variable "rg_prefix" {
  description = "The shortened abbreviation to represent your resource group that will go on the front of some resources."
  default     = "stt"
}

variable "hostname" {
  description = "VM name for the webserver, as I nixed boot diags doesn't have to be storage account friendly"
}

variable "db_hostname" {
  description = "VM name for the db host"
}

variable "dns_name" {
  description = "Label for the Domain Name. Specifically for the bugzilla frontend"
}

variable "dns_name_db" {
  description = "Label for the Domain Name. Specifically for the database, no I don't like having a public db either, but still in test-mode"
}

variable "virtual_network_name" {
  description = "The name for the virtual network."
  default     = "vnet"
}

variable "address_space" {
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  default     = "10.1.0.0/24"
}

variable "subnet_prefix_app" {
  description = "The address prefix to use for the subnet."
  default     = "10.1.0.0/25"
}

variable "subnet_prefix_backend" {
  description = "The address prefix to use for the subnet."
  default     = "10.1.0.128/25"
}

variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  default     = "Standard_A0"
}

variable "image_publisher" {
  description = "name of the publisher of the image (az vm image list)"
  default     = "OpenLogic"
}

variable "image_offer" {
  description = "the name of the offer (az vm image list)"
  default     = "CentOS"
}

variable "image_sku" {
  description = "image sku to apply (az vm image list)"
  default     = "6.9"
}

variable "image_version" {
  description = "version of the image to apply (az vm image list)"
  default     = "latest"
}

variable "admin_username" {
  description = "administrator user name"
  default     = "vmadmin"
}

variable "public_key" {
  description = "put your public key data here"
}
