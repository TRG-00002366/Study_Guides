# Exercise: Setting Up CI/CD for a dbt Project

## Overview
**Day:** 1-Monday
**Duration:** 2-3 hours
**Mode:** Individual (Implementation)
**Prerequisites:** Git/GitHub basics; dbt fundamentals from Week 5

---

## Required Reading

Before starting this exercise, review the following content:

| Topic | File | Focus Areas |
|-------|------|-------------|
| CI/CD for dbt | [cicd-for-dbt.md](../../content/1-Monday/cicd-for-dbt.md) | GitHub Actions, environments, deployment strategies |
| DataOps Lifecycle | [dataops-lifecycle.md](../../content/1-Monday/dataops-lifecycle.md) | CI/CD within the DataOps lifecycle |

---

## Learning Objectives
By the end of this exercise, you will be able to:
1. Create a GitHub Actions workflow that validates dbt models on pull requests
2. Configure multi-environment dbt profiles (dev, ci, prod)
3. Understand the difference between CI (test) and CD (deploy) pipelines
4. Use GitHub Secrets for credential management

---

## The Scenario

Your team's dbt project has been running manually — engineers run `dbt run` from their laptops and push to production by hand. Last week, a broken model made it to production and corrupted the executive dashboard. Your manager has asked you to set up a proper CI/CD pipeline so this never happens again.

---

## Core Tasks

### Task 1: Complete the CI Workflow (45 mins)

1. Open `starter_code/dbt_ci_template.yml`
2. This is a **partially completed** GitHub Actions workflow. Complete the `TODO` sections:
   - Add the correct trigger (should run on pull requests to `main`)
   - Add the `dbt deps` step
   - Add the `dbt compile --target ci` step
   - Add the `dbt test --target ci` step
3. Review the completed workflow and verify the step order makes sense

**Checkpoint:** Your workflow file has no `TODO` markers remaining.

---

### Task 2: Configure Multi-Environment Profiles (30 mins)

1. Open `starter_code/profiles_template.yml`
2. Complete the three targets:
   - `dev` — Your personal development schema (use `{{ env_var('USER') }}_dev` for schema)
   - `ci` — CI environment with `CI_DB` database and `ci_test` schema
   - `prod` — Production with `PROD_DB` database, `analytics` schema, and 8 threads
3. Ensure ALL credentials use `{{ env_var('...') }}` — never hardcode values

**Checkpoint:** Three complete targets with no hardcoded credentials.

---

### Task 3: Create a CD Workflow (45 mins)

Now create the deployment workflow **from scratch**:

1. Create a new file: `dbt_deploy.yml`
2. It should:
   - Trigger on push to `main` (not on PRs)
   - Install dbt and configure credentials
   - Run `dbt run --target prod`
   - Run `dbt test --target prod` (validate after deployment)
   - Use the `environment: production` setting for approval gates
3. Add comments explaining each step

**Hint:** Reference the CI workflow as a starting point, but change the trigger and target.

**Checkpoint:** Complete CD workflow that differs from CI in trigger, target, and purpose.

---

### Task 4: Document the CI/CD Process (30 mins)

Create a `CI_CD_RUNBOOK.md` file documenting:

1. **Pipeline Overview:** What happens when a developer opens a PR? What happens on merge?
2. **Environment Table:**

| Environment | Database | Schema | Warehouse | Purpose |
|-------------|----------|--------|-----------|---------|
| dev | | | | |
| ci | | | | |
| prod | | | | |

3. **Failure Scenarios:** What should a developer do when:
   - CI tests fail on their PR?
   - CD deployment fails after merge?
   - A model passes CI but breaks in prod?

**Checkpoint:** Runbook covers all three scenarios with action steps.

---

## Deliverables

Submit the following:

1. **Completed CI workflow** (`dbt_ci_template.yml` with all TODOs filled)
2. **Completed profiles** (`profiles_template.yml` with 3 targets)
3. **CD workflow** (new `dbt_deploy.yml` file)
4. **CI/CD Runbook** (`CI_CD_RUNBOOK.md`)

---

## Definition of Done

- [ ] CI workflow triggers on pull requests to main
- [ ] CI workflow runs: deps → compile → test
- [ ] Profiles have dev, ci, and prod targets
- [ ] No hardcoded credentials anywhere
- [ ] CD workflow triggers on push to main
- [ ] CD workflow runs: deps → run → test
- [ ] Runbook documents the full CI/CD process
- [ ] Runbook covers 3 failure scenarios

---

## Stretch Goals (Optional)

1. Add a **Slim CI** step using `--select state:modified+` to only test changed models
2. Add a **docs generation** step that runs `dbt docs generate` in CI
3. Add a step that posts test results as a PR comment using GitHub Actions
4. Configure branch protection rules documentation (require CI to pass before merge)

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| YAML syntax errors | Use a YAML linter or check indentation (2 spaces) |
| `env_var` not found | In CI, set values via GitHub Secrets |
| Workflow doesn't trigger | Check `on:` section — branch name must match |
| dbt can't find profiles | Set `DBT_PROFILES_DIR` environment variable |
| Tests pass in CI but fail in prod | CI and prod databases have different data |
