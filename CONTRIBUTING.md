# Contributing to terraform-azure-modules

## What is this repo?

`terraform-azure-modules` is a shared Terraform module library for the org. Any team can pick a module, pass their own values, and provision Azure infrastructure. Nobody hardcodes anything inside the modules — names, CIDRs, sizes all come from the caller.

---

## How to use a module in your repo

Always pin to a version tag. Never use `main`.

```hcl
module "vnet" {
  source = "git::https://github.com/NeuralgoLyzr/terraform-azure-modules.git//modules/vnet?ref=v0.1.0"

  company             = "my-team"
  product             = "my-product"
  environment         = "dev"
  location            = "westeurope"
  resource_group_name = "my-team-my-product-dev-we-rg"
}
```

When a new version is released, upgrading is your team's decision. Update `?ref=v0.1.0` to the new tag, raise a PR in your repo, test in dev first.

---

## How to contribute a change

### Step 1 — Cut a branch from main

```bash
git checkout main
git pull
git checkout -b feat/vnet-add-dns-variable
```

### Step 2 — Make your change

Module structure:

```
modules/<module-name>/
  versions.tf      ← terraform ~> 1.14 and azurerm ~> 4.0
  variables.tf     ← all input variables with descriptions
  locals.tf        ← naming convention, computed values, tags
  main.tf          ← all Azure resources
  outputs.tf       ← everything a caller might need
```

Rules:
- No hardcoded names, CIDRs, or team-specific values inside modules
- Required variables: company, product, environment, location, resource_group_name, owner, cost_center, terraform_repo
- Naming built in locals.tf: `{company}-{product}-{env}-{region-short}-{resource-type}`
- Every module that a client could already have must have a `create` flag and `existing_*` variable
- Tags applied on every resource via `local.mandatory_tags`
- New optional variables must have sensible defaults — no plan diff on existing deployments

### Step 3 — Write your PR title correctly

```
feat(module-name): what you added
fix(module-name): what you fixed
feat(module-name)!: what you changed that breaks existing callers
chore: anything that is not a code change
```

#### Ask yourself before writing the title

| Question | Answer | Use |
|---|---|---|
| Did I add a new optional variable or output? | Yes | `feat` |
| Did I fix a bug without changing the interface? | Yes | `fix` |
| Will any team's code break if they upgrade? | Yes | `feat!` |
| Is it just docs, formatting, CI? | Yes | `chore` |

#### Version bump that results

```
feat  →  MINOR bump  →  0.1.0 becomes 0.2.0
fix   →  PATCH bump  →  0.1.0 becomes 0.1.1
feat! →  MAJOR bump  →  0.1.0 becomes 1.0.0
chore →  no bump     →  version stays the same
```

### Step 4 — Raise a PR to main

- Pipeline runs automatically: terraform fmt, validate, tflint, checkov, PR title check
- All checks must pass before merge
- Get at least one reviewer approval

### Step 5 — Merge to main

Once approved and pipeline is green, merge to main. release-please opens a Release PR automatically. Merge the Release PR to create the tag.

---

## What happens after merge

```
Your PR merged to main
        ↓
release-please pipeline runs
        ↓
release-please opens a Release PR (chore: release x.y.z)
        ↓
Release PR merged
        ↓
Tag vX.Y.Z created on the repo
        ↓
Other teams update ?ref= in their calling code
```

---

## Golden rules

| Rule | Why |
|---|---|
| Never push directly to main | Everything goes through a PR and pipeline |
| Never hardcode names inside modules | Any team must be able to use any module |
| Always pin to a tag in your calling repo | Protects from unexpected breaking changes |
| Test in dev before upgrading tags in prod | A new tag is not automatically safe for prod |
| Breaking change? Use ! in PR title | Warns every team they need to review before upgrading |
| New variable must have a default if optional | Existing callers must not get a plan diff on upgrade |
| Every module that client might bring needs create flag | Supports client bring-your-own-resource pattern |

---

## Questions?

Raise it as a discussion on the PR or reach out to the DevOps team.
