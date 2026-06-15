# Configure the Terraform runtime requirements.
terraform {
  required_version = ">= 1.1.0"

  required_providers {
    # Azure Resource Manager provider and version
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.3.3"
    }
  }

  variable "labelPrefix" {
    type = string
    default = "jccst8918"
  }
  variable "region" {
    type = string 
    default = "canadacentral"
  }
  variable "admin_username" {
    type = string
  }

  resource "azurerm_resource_group" "main" {
    name = "${var.labelPrefix}-A05-RG"
    location = "${var.region}"
    tags = {
        Class = "CST8918"
        Assignment = "Lab"
        Lab = "A05"
    }
  }
  resource "azurerm_public_ip" "example" {
    name = "${var.labelPrefix}publicip"
    resource_group_name = azurerm_resource_group.main.name
    location = "${var.region}"
    allocation_method = "Static"
    tags={
        Class = "CST8918"
        Assignment = "Lab"
        Lab = "A05"
    }
  }

  resource "azurerm_virtual_network" "example"{
    name = "${var.labelPrefix}vnet"
    location = "${var.region}"
    resource_group_name = azurerm_resource_group.main.name    
    address_space = ["10.0.0.0/16]

    tags={
        Class = "CST8918"
        Assignment = "Lab"
        Lab = "A05"
    }
  } 
  resource "azurerm_subnet" "example"{
    name = "${var.labelPrefix}subnet"
    resource_group_name = azurerm_resource_group.main.name    
    virtual_network_name = azurerm_virtual_network.example.name
    address_space = ["10.0.1.0/24]    
  }

  resource "azurerm_network_security_group" "example" {
    name = "${var.labelPrefix}nsg"
    location = "${var.region}"
    resource_group_name = azurerm_resource_group.main.name    

    security_rule{
      name = "sshaccess"
      priority=100
      direction "Inbound"
      access = "Allow"
      protocol = "Tcp"
      source_port_range = "*"
      destination_port_range = "22"
      source_address_prefix = "*"
      destination_address_prefix = "*"
    }

    security_rule{
      name = "httpaccess"
      priority=100
      direction "Inbound"
      access = "Allow"
      protocol = "Tcp"
      source_port_range = "*"
      destination_port_range = "80"
      source_address_prefix = "*"
      destination_address_prefix = "*"
    }
  }

  resource "azurerm_network_interface" "example" {
    name = "${var.labelPrefix}nsg"
    location = "${var.region}"
    resource_group_name = azurerm_resource_group.main.name   

    ip_configuration{
      name = "vmnic"
      subnet_id = azurerm_subnet.example.id
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id = azurerm_public_ip.example.id
    }
  }

  resource "azurerm_subnet_network_security_group_association" "example"{
    subnet_id = azurerm.subnet.example.id
    network_security_group_id = azurerm_network_security_group.example.id    
  }

  data "cloudinit_config" "example"{
    gzip = false
    base64_encode = true

    part {
      filename = "init.sh"
      content_type = "text/x-shellscript"
      content = file("init.sh")
    }
  }

  resource "azurerm_virtual_machine" "main"{
    name = "${var.labelPrefix}vnet"
    location = "${var.region}"
    resource_group_name = azurerm_resource_group.main.name    
    network_interface_ids = [azurerm_network_interface.example.id]
    vm_size = "Standard_Bs1"

    storage_image_reference {
      publisher = "Canonical"
      offer = "0001-com-ubuntu-server-jammy"
      sku = "22_04-lts"
      version = "latest"      
    }

    storage_os_disk {
      name = "cst8918lab5osdisk1"
      caching = "ReadWrite"
      create_option = "FromImage"
      managed_disk_type = "Standard_LRS"
    }

    os_profile {
      compute_name = "hostname
      admin_username = 
      admin_password = 
    }

    os_profile_linux_config {
      disable_password_authentication = false
    }

    tags={
        Class = "CST8918"
        Assignment = "Lab"
        Lab = "A05"
    }
  }
    
}

# Define providers and their config params
provider "azurerm" {
  # Leave the features block empty to accept all defaults
  features {}
}

provider "cloudinit" {
  # Configuration options
}