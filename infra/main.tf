resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.vnet_cidr]
}

resource "azurerm_subnet" "aks" {
  name                 = var.aks_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.aks_subnet_cidr]
}

# App Gateway subnet for AGIC add-on (your --appgw-subnet-cidr requirement)
resource "azurerm_subnet" "appgw" {
  name                 = var.appgw_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.appgw_subnet_cidr]
}

# Generate SSH keypair (like --generate-ssh-keys)
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Optional: write private/public keys to local files
resource "local_file" "ssh_private_key" {
  filename        = "${path.module}/id_rsa"
  content         = tls_private_key.ssh.private_key_pem
  file_permission = "0600"
}

resource "local_file" "ssh_public_key" {
  filename        = "${path.module}/id_rsa.pub"
  content         = tls_private_key.ssh.public_key_openssh
  file_permission = "0644"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
  }

  default_node_pool {
    name                 = "system"
    vm_size              = var.node_vm_size
    vnet_subnet_id       = azurerm_subnet.aks.id

    # requirement: node count 1, autoscaler min=1 max=2
    node_count           = var.node_count
    auto_scaling_enabled = true
    min_count            = var.autoscaler_min_count
    max_count            = var.autoscaler_max_count
  }

  linux_profile {
    admin_username = var.admin_username

    ssh_key {
      key_data = tls_private_key.ssh.public_key_openssh
    }
  }

  # Helps avoid recreate loops in some environments
  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count
    ]
  }
}
