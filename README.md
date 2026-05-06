# terraform-azure-modules

Versioned Terraform module library for the Lyzr platform. All modules target `terraform ~> 1.14` and `azurerm ~> 4.0`.

---

## Module Catalogue

| Module | What it builds |
|---|---|
| [vnet](modules/vnet/README.md) | VNet, subnets, NSGs, NAT Gateway |
| [application-gateway](modules/application-gateway/README.md) | Application Gateway with WAF, SSL termination, AGIC support |
| [private-endpoint](modules/private-endpoint/README.md) | Private Endpoint with Private DNS Zone |
| [aks](modules/aks/README.md) | AKS cluster, node pools, managed identity |
| [container-registry](modules/container-registry/README.md) | Azure Container Registry |
| [postgresql-flexible](modules/postgresql-flexible/README.md) | PostgreSQL Flexible Server |
| [mysql-flexible](modules/mysql-flexible/README.md) | MySQL Flexible Server |
| [cosmosdb-mongo](modules/cosmosdb-mongo/README.md) | Cosmos DB MongoDB API |
| [redis](modules/redis/README.md) | Azure Cache for Redis |
| [storage-account](modules/storage-account/README.md) | Storage Account, blob containers |
| [service-bus](modules/service-bus/README.md) | Service Bus namespace, queues, topics |
| [key-vault](modules/key-vault/README.md) | Key Vault |
| [function-app](modules/function-app/README.md) | Linux Function App |
| [application-insights](modules/application-insights/README.md) | Application Insights, Log Analytics Workspace |
| [virtual-machine](modules/virtual-machine/README.md) | Linux Virtual Machine |
| [dns-zone](modules/dns-zone/README.md) | Azure DNS Zone and records (optional) |
| [state-backend](modules/state-backend/README.md) | Azure Storage for Terraform remote state |

---

## Using a Module

### 1. Source pinning

Always pin to a version tag. Never use `?ref=main`.

```hcl
module "vnet" {
  source = "git::https://github.com/NeuralgoLyzr/terraform-azure-modules.git//modules/vnet?ref=v0.1.0"

  company             = "mycompany"
  product             = "myproduct"
  environment         = "dev"
  location            = "westeurope"
  resource_group_name = "mycompany-myproduct-dev-we-rg"
}
```

### 2. Bring your own resources

Every module that could already exist in a client environment supports a `create` flag:

```hcl
module "vnet" {
  source = "git::https://github.com/NeuralgoLyzr/terraform-azure-modules.git//modules/vnet?ref=v0.1.0"

  create          = false
  existing_vnet_name = "my-existing-vnet"
  resource_group_name = "my-existing-rg"
  environment     = "prod"
  location        = "westeurope"
}
```

### 3. Naming convention

All resource names are built automatically inside `locals.tf` using this pattern:

```
{company}-{product}-{environment}-{region-short}-{resource-type}
```

Example: `lyzr-studio-dev-we-vnet`

### 4. Mandatory tags

Every resource gets these tags automatically:

```hcl
Environment   = var.environment
Product       = var.product
ManagedBy     = "terraform"
Owner         = var.owner
CostCenter    = var.cost_center
TerraformRepo = var.terraform_repo
Module        = "<module-name>"
```

Pass additional tags via `var.tags` — they are merged on top.

### 5. Remote state references

```hcl
data "terraform_remote_state" "networking" {
  backend = "azurerm"
  config = {
    resource_group_name  = "lyzr-studio-tfstate-we-rg"
    storage_account_name = "lyzrstudiotfstatest"
    container_name       = "tfstate"
    key                  = "dev/networking/terraform.tfstate"
  }
}

subnet_id = data.terraform_remote_state.networking.outputs.subnet_ids["aksSubnet"]
```

---

## Adding a New Module

See [CONTRIBUTING.md](CONTRIBUTING.md) for full guidance.

---

## Versioning

Releases are automated by release-please. Commit title drives the version bump:

| PR title prefix | Version bump |
|---|---|
| `feat(<module>):` | MINOR |
| `fix(<module>):` | PATCH |
| `feat(<module>)!:` | MAJOR |
| `chore:` | none |

---

## Local Development

```bash
# Format all modules
terraform fmt -recursive modules/

# Validate a single module
terraform -chdir=modules/vnet init -backend=false && terraform -chdir=modules/vnet validate

# Lint a single module
tflint --init
tflint --chdir=modules/vnet

# Security scan
checkov -d modules/vnet --framework terraform
```
