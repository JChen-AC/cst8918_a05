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
    name = "${var.labelPrefix}vnet"
    resource_group_name = azurerm_resource_group.main.name    
    virtual_network_name = azurerm_virtual_network.example.name
    address_space = ["10.0.1.0/24]    
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