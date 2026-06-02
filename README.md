# azure-iac-0

Infrastructure-as-code for an Azure landing zone, built with [Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/overview). The repo defines a subscription-scoped entry template, reusable modules for hub networking and Key Vault, and GitHub Actions workflows for linting, validation, security scanning, and deployment.

## Overview

| Component | Purpose |
|-----------|---------|
| `main.bicep` | Subscription-scoped template that creates the core resource group (`{prefix}-core-rg`). |
| `modules/network.bicep` | Hub virtual network with Firewall, Gateway, and Bastion subnets (Azure Verified Modules). |
| `modules/keyvault.bicep` | Key Vault with RBAC authorization and template-deployment access enabled. |

Modules are intended to be deployed into the core resource group (or other groups you define) as the landing zone grows. Wire them from `main.bicep` or separate scoped deployments when you are ready to roll out network and secrets infrastructure.

### Hub network layout

`modules/network.bicep` provisions a hub VNet (`{namePrefix}-hub-vnet`) on `10.0.0.0/16` by default and derives subnet prefixes with `cidrSubnet()`:

| Subnet | Default prefix length |
|--------|------------------------|
| Firewall | /26 |
| Gateway | /26 |
| Bastion | /26 |

Both modules pull from the public Bicep registry ([AVM virtual network](https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/network/virtual-network), [AVM Key Vault](https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/key-vault/vault)).

## Repository structure

```
.
├── main.bicep                 # Subscription entry point (resource group)
├── modules/
│   ├── network.bicep          # Hub VNet and subnets
│   └── keyvault.bicep         # Key Vault
└── .github/workflows/
    ├── unit-test.yml          # PR: lint, validate, what-if, Checkov
    └── lint-validate-deploy.yml  # main: lint, validate, deploy
```

## Prerequisites

- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) with Bicep support (`az bicep install` if needed)
- An Azure subscription and permissions to create resource groups and deploy templates
- For CI/CD: a GitHub repository with Azure OIDC federation configured for `azure/login@v2`

## Parameters

### `main.bicep`

| Parameter | Default | Description |
|-----------|---------|-------------|
| `location` | `eastus2` | Azure region for the core resource group. |
| `prefix` | `js` | Name prefix; resource group becomes `{prefix}-core-rg`. |

### `modules/network.bicep`

| Parameter | Default | Description |
|-----------|---------|-------------|
| `location` | Resource group location | Azure region. |
| `namePrefix` | `js` | Prefix for the VNet name. |
| `ipAddressSpace` | `10.0.0.0` | VNet base address (without CIDR suffix). |
| `CIDR` | `/16` | CIDR suffix for the VNet. |
| `subnets` | Firewall, Gateway, Bastion `/26` each | Subnet names and prefix lengths for `cidrSubnet()`. |

### `modules/keyvault.bicep`

| Parameter | Default | Description |
|-----------|---------|-------------|
| `namePrefix` | `js` | Prefix for the vault name. |
| `location` | Resource group location | Azure region. |

## Local development

Log in and set your subscription:

```bash
az login
az account set --subscription "<subscription-id>"
```

Compile and lint templates:

```bash
az bicep build --file main.bicep
az bicep build --file modules/network.bicep
az bicep build --file modules/keyvault.bicep
```

Deploy the subscription template (creates the core resource group):

```bash
az deployment sub create \
  --location eastus2 \
  --template-file main.bicep \
  --parameters location=eastus2 prefix=js
```

Deploy a module into an existing resource group:

```bash
az deployment group create \
  --resource-group js-core-rg \
  --template-file modules/network.bicep

az deployment group create \
  --resource-group js-core-rg \
  --template-file modules/keyvault.bicep
```

Preview changes before apply:

```bash
az deployment group what-if \
  --resource-group js-core-rg \
  --template-file modules/network.bicep
```

## CI/CD

### Pull requests (`unit-test.yml`)

Runs on pull requests targeting `main`:

1. **Lint** — `az bicep build` on `main.bicep`
2. **Validate** — Azure login (OIDC), deployment validate and what-if against the configured resource group
3. **Security** — [Checkov](https://www.checkov.io/) for Bicep (SARIF uploaded to GitHub Security)

### `main` branch (`lint-validate-deploy.yml`)

Runs on push to `main`:

1. **Lint** and **Validate** (same as above)
2. **Deploy** — deployment stack create to the production environment (requires approval if you configure the `production` environment in GitHub)

### Required GitHub secrets

| Secret | Used for |
|--------|----------|
| `AZURE_CLIENT_ID` | OIDC app registration client ID |
| `AZURE_TENANT_ID` | Azure AD tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Target subscription |
| `AZURE_RESOURCE_GROUP_NAME` | Resource group for validate / what-if / deploy |
| `AZURE_KEYVAULT_RESOURCEGROUP_NAME` | Key Vault resource group (workflow parameters) |
| `AZURE_KEYVAULT_NAME` | Key Vault name (workflow parameters) |

Workflows also reference `main.bicepparam` and inline parameters for subscription and Key Vault settings. Add or update `main.bicepparam` when you connect `main.bicep` to Key Vault and align parameter names with the workflows.

Configure [federated credentials](https://learn.microsoft.com/entra/workload-id/workload-identity-federation-create-trust) on the app registration so GitHub Actions can authenticate without stored client secrets.

## Roadmap / integration notes

- Compose `modules/network.bicep` and `modules/keyvault.bicep` from `main.bicep` (nested module deployments scoped to `coreResourceGroup`).
- Add `main.bicepparam` (and match workflow `parameters` / `parameters-file` inputs).
- Reconcile deployment scope: `main.bicep` uses `targetScope = 'subscription'`, while workflows currently use resource group scope—adjust one side so validate and deploy match your intended topology.

## License

Add a license file if you plan to share or open-source this repository.
