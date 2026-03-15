locals {
  tags = {
    project = var.project_name
    managed = "terraform"
  }

  allowed_ports = [22, 80, 443, 3001, 3002]

  teammate_ssh_key_commands = join("\n", [
    for k in var.teammate_ssh_public_keys :
    "echo '${replace(k, "'", "'\\\"'\\\"'")}' >> /home/${var.admin_username}/.ssh/authorized_keys"
  ])
}

resource "random_string" "sb_suffix" {
  length  = 6
  upper   = false
  lower   = true
  numeric = true
  special = false
}

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.tags
}

resource "azurerm_role_assignment" "teammates_rg_contributor" {
  for_each = toset(var.teammate_principal_object_ids)

  scope                = azurerm_resource_group.this.id
  role_definition_name = "Contributor"
  principal_id         = each.value
}

# NETWORK

resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.project_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.10.0.0/16"]
  tags                = local.tags
}

resource "azurerm_subnet" "this" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_network_security_group" "this" {
  name                = "nsg-${var.project_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
}

resource "azurerm_network_security_rule" "inbound" {
  for_each = { for p in local.allowed_ports : tostring(p) => p }

  name                        = "allow-${each.value}"
  priority                    = 100 + each.value
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = tostring(each.value)
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.this.name
}

resource "azurerm_public_ip" "this" {
  name                = "pip-${var.project_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_network_interface" "this" {
  name                = "nic-${var.project_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.this.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this.id
  }
}

resource "azurerm_network_interface_security_group_association" "this" {
  network_interface_id      = azurerm_network_interface.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}

# Linux VM to run containers

resource "azurerm_linux_virtual_machine" "this" {
  name                            = var.vm_name
  resource_group_name             = azurerm_resource_group.this.name
  location                        = azurerm_resource_group.this.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.this.id]
  tags                            = local.tags

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
    #!/bin/bash
    set -eux
    apt-get update
    apt-get install -y ca-certificates curl gnupg lsb-release
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" > /etc/apt/sources.list.d/docker.list
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    usermod -aG docker ${var.admin_username}
    install -d -m 700 -o ${var.admin_username} -g ${var.admin_username} /home/${var.admin_username}/.ssh
    touch /home/${var.admin_username}/.ssh/authorized_keys
    chown ${var.admin_username}:${var.admin_username} /home/${var.admin_username}/.ssh/authorized_keys
    chmod 600 /home/${var.admin_username}/.ssh/authorized_keys
    ${local.teammate_ssh_key_commands}
  EOF
  )
}

# Service Bus to PUB/SUB

resource "azurerm_servicebus_namespace" "this" {
  name                = "sb${var.project_name}${random_string.sb_suffix.result}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = var.servicebus_sku
  tags                = local.tags
}

resource "azurerm_servicebus_topic" "this" {
  name         = "demo-topic"
  namespace_id = azurerm_servicebus_namespace.this.id
}

resource "azurerm_servicebus_subscription" "subscription_a" {
  name               = "subscription-a"
  topic_id           = azurerm_servicebus_topic.this.id
  max_delivery_count = 2
}

resource "azurerm_servicebus_subscription" "subscription_b" {
  name               = "subscription-b"
  topic_id           = azurerm_servicebus_topic.this.id
  max_delivery_count = 2
}

resource "azurerm_servicebus_namespace_authorization_rule" "app" {
  name         = "app-access"
  namespace_id = azurerm_servicebus_namespace.this.id

  listen = true
  send   = true
  manage = true
}
