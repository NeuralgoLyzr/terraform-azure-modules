# ---------------------------------------------------------------------------
# Bring-your-own-resource support
# ---------------------------------------------------------------------------
variable "create" {
  type        = bool
  description = "Set to false to use an existing VNet instead of creating one"
  default     = true
}

variable "existing_vnet_name" {
  type        = string
  description = "Name of an existing VNet (only used when create = false)"
  default     = ""
}

# ---------------------------------------------------------------------------
# Identity / naming inputs
# ---------------------------------------------------------------------------
variable "company" {
  type        = string
  description = "Company or org short name used in resource naming (e.g. lyzr)"
}

variable "product" {
  type        = string
  description = "Product or team name used in resource naming (e.g. studio)"
}

variable "environment" {
  type        = string
  description = "Deployment environment"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod."
  }
}

variable "location" {
  type        = string
  description = "Azure region (e.g. westeurope)"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to deploy into"
}

# ---------------------------------------------------------------------------
# Networking
# ---------------------------------------------------------------------------
variable "vnet_address_space" {
  type        = list(string)
  description = "CIDR address space for the VNet"
  default     = ["10.200.0.0/16"]
}

variable "subnets" {
  type = map(object({
    address_prefix    = string
    service_endpoints = optional(list(string), [])
    delegation = optional(object({
      name         = string
      service_name = string
      actions      = list(string)
    }), null)
  }))
  description = "Map of subnet name to configuration"
  default = {
    appGatewaySubnet = {
      address_prefix    = "10.200.1.0/24"
      service_endpoints = []
    }
    gatewaySubnet = {
      address_prefix    = "10.200.2.0/27"
      service_endpoints = []
    }
    aksSubnet = {
      address_prefix    = "10.200.3.0/23"
      service_endpoints = ["Microsoft.ContainerRegistry", "Microsoft.KeyVault", "Microsoft.Storage"]
    }
    dataSubnet = {
      address_prefix    = "10.200.5.0/24"
      service_endpoints = ["Microsoft.AzureCosmosDB", "Microsoft.Sql", "Microsoft.Storage"]
    }
    vmSubnet = {
      address_prefix    = "10.200.6.0/24"
      service_endpoints = ["Microsoft.KeyVault", "Microsoft.Storage"]
    }
    functionAppSubnet = {
      address_prefix    = "10.200.7.0/24"
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
      delegation = {
        name         = "functionapp-delegation"
        service_name = "Microsoft.Web/serverFarms"
        actions      = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
    privateEndpointSubnet = {
      address_prefix    = "10.200.8.0/24"
      service_endpoints = []
    }
  }
}

variable "nsg_rules" {
  type = map(list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  })))
  description = "Map of subnet name to list of NSG rules"
  default = {
    appGatewaySubnet = [
      {
        name                       = "allow-https-inbound"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "Internet"
        destination_address_prefix = "*"
      },
      {
        name                       = "allow-gateway-manager"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "65200-65535"
        source_address_prefix      = "GatewayManager"
        destination_address_prefix = "*"
      },
      {
        name                       = "allow-azure-lb"
        priority                   = 120
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "AzureLoadBalancer"
        destination_address_prefix = "*"
      }
    ]
    aksSubnet = [
      {
        name                       = "allow-appgw-to-aks"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "10.200.1.0/24"
        destination_address_prefix = "*"
      },
      {
        name                       = "allow-aks-internal"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "10.200.3.0/23"
        destination_address_prefix = "10.200.3.0/23"
      }
    ]
    dataSubnet = [
      {
        name                       = "allow-aks-to-data"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "10.200.3.0/23"
        destination_address_prefix = "*"
      },
      {
        name                       = "allow-vm-to-data"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "10.200.6.0/24"
        destination_address_prefix = "*"
      },
      {
        name                       = "allow-func-to-data"
        priority                   = 120
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "10.200.7.0/24"
        destination_address_prefix = "*"
      }
    ]
    vmSubnet = [
      {
        name                       = "allow-ssh-inbound"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "*"
      },
      {
        name                       = "allow-aks-to-vms"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8123"
        source_address_prefix      = "10.200.3.0/23"
        destination_address_prefix = "*"
      },
      {
        name                       = "allow-aks-to-qdrant"
        priority                   = 120
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "6333"
        source_address_prefix      = "10.200.3.0/23"
        destination_address_prefix = "*"
      },
      {
        name                       = "allow-aks-to-keycloak"
        priority                   = 130
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8080"
        source_address_prefix      = "10.200.3.0/23"
        destination_address_prefix = "*"
      }
    ]
    functionAppSubnet = [
      {
        name                       = "allow-https-from-vnet"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "*"
      },
      {
        name                       = "allow-azure-lb-probes"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "AzureLoadBalancer"
        destination_address_prefix = "*"
      }
    ]
    privateEndpointSubnet = [
      {
        name                       = "allow-vnet-inbound"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "*"
      }
    ]
  }
}

# ---------------------------------------------------------------------------
# NAT Gateway
# ---------------------------------------------------------------------------
variable "create_nat_gateway" {
  type        = bool
  description = "Whether to create a NAT Gateway for outbound traffic"
  default     = true
}

variable "nat_gateway_subnets" {
  type        = list(string)
  description = "Subnet names to associate with the NAT Gateway"
  default     = ["aksSubnet", "vmSubnet"]
}

# ---------------------------------------------------------------------------
# Tagging
# ---------------------------------------------------------------------------
variable "owner" {
  type        = string
  description = "Team or person responsible for these resources"
}

variable "cost_center" {
  type        = string
  description = "Cost center for billing"
}

variable "terraform_repo" {
  type        = string
  description = "Name of the Terraform repo managing these resources"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags merged on top of mandatory tags"
  default     = {}
}
