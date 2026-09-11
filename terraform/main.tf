# Grupo de recursos del laboratorio
data "azurerm_resource_group" "rg-lab" {
  name = var.rg-name
}
# Grupo de recursos de la key vault
data "azurerm_resource_group" "rg-kv-name" {
  name = var.rg-kv-name
}
# Key Vault con secreto SSH para el laboratorio
data "azurerm_key_vault" "kv-ssh" {
  name                = var.kv-ssh-name
  resource_group_name = data.azurerm_resource_group.rg-kv-name.name
}
# Secreto SSH
data "azurerm_key_vault_secret" "ssh_secret" {
  name         = var.kv-ssh-secret
  key_vault_id = data.azurerm_key_vault.kv-ssh.id
}

# NSG PARA PERMITIR ACCESO SSH Y PRUEBAS
module "nsg_ssh" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.5.1"

  name                = "nsg-${var.prefix}-${var.project-code}-01"
  resource_group_name = data.azurerm_resource_group.rg-lab.name
  location            = data.azurerm_resource_group.rg-lab.location

  security_rules = {
    "Allow-SSH-Lab" = {
      name                       = "Allow-SSH-Lab"
      priority                   = 1000
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    "Allow-SSH-Lab-Custom" = {
      name                       = "Allow-SSH-Lab-Custom"
      priority                   = 1100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "5022"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Permitir entrada por puerto personalizado"
    }
  }

  tags = {
    Environment = var.prefix
  }
}

# VNET Y SUBNET
module "vnet" {
  depends_on = [module.nsg_ssh]

  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.22.2"

  name = "vnet-${var.prefix}-${var.project-code}-01"

  location  = data.azurerm_resource_group.rg-lab.location
  parent_id = data.azurerm_resource_group.rg-lab.id

  address_space = ["10.0.0.0/16"]

  subnets = {
    "subnet1" = {
      name             = "subnet1"
      address_prefixes = ["10.0.1.0/24"]
      network_security_group = {
        id = module.nsg_ssh.resource_id
      }
    }
  }

  tags = {
    Environment = var.prefix
  }
}

# IP PUBLICA PARA VM
resource "azurerm_public_ip" "pip" {
  name                = "pip-${var.prefix}-${var.project-code}-01"
  location            = data.azurerm_resource_group.rg-lab.location
  resource_group_name = data.azurerm_resource_group.rg-lab.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = var.prefix
  }
}

# VM DEBIAN
module "debian_vm" {
  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "0.21.0"

  depends_on = [azurerm_public_ip.pip]

  name                = "vm-${var.prefix}-${var.project-code}-01"
  resource_group_name = data.azurerm_resource_group.rg-lab.name
  location            = data.azurerm_resource_group.rg-lab.location
  zone                = null

  os_type  = "Linux"
  sku_size = "Standard_D2alds_v7"
  # az vm list-skus --location chilecentral --resource-type virtualMachines --size Standard_D --all --output table
  # az vm list-usage --location eastus2 --output table
  disable_password_authentication = true

  admin_username = var.debian-user
  admin_ssh_keys = [{
    username   = var.debian-user
    public_key = data.azurerm_key_vault_secret.ssh_secret.value
  }]

  encryption_at_host_enabled = false

  source_image_reference = {
    publisher = "Debian"
    offer     = "debian-12"
    sku       = "12-gen2"
    version   = "latest"
  }

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  network_interfaces = {
    "nic1" = {
      name = "nic-${var.prefix}-${var.project-code}-01"
      ip_configurations = {
        "ipconfig1" = {
          name                          = "internal"
          private_ip_address_allocation = "Dynamic"
          private_ip_subnet_resource_id = module.vnet.subnets["subnet1"].resource_id
          public_ip_address_resource_id = azurerm_public_ip.pip.id
        }
      }
    }
  }

  tags = {
    Environment = var.prefix
    rol         = "debian_lab"
  }
}
