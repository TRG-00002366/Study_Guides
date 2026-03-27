# Demo: CI/CD for dbt Projects — From PR to Production

## Overview
| Field | Detail |
|-------|--------|
| **Day** | 1-Monday |
| **Topic** | CI/CD for dbt using GitHub Actions |
| **Type** | Hybrid (Concept + Code) |
| **Time** | ~25 minutes |
| **Prerequisites** | Trainees have GitHub accounts; familiar with dbt from Week 5 |

**Weekly Epic:** *Operationalizing Data Excellence — DataOps, Quality, and Governance*

---

## Phase 1: The Concept (Diagram)

**Time:** 8 mins

1. Open `diagrams/dbt-cicd-pipeline.mermaid`
2. Start from the top:
   - *"A developer makes a change to a dbt model — maybe fixing a revenue calculation. What happens next?"*
3. Walk through the **CI** block:
   - PR opens → GitHub Actions triggers automatically
   - `dbt deps` → `dbt compile` (catches syntax) → `dbt test` (catches data issues)
   - *"If tests fail, the developer sees a red X on their PR — they fix before reviewers even look at it."*
4. Walk through the **CD** block:
   - Merge to main → CD deploys to production automatically
   - `dbt run --target prod` → `dbt test --target prod`
   - *"No one runs dbt manually on their laptop for production. Ever."*

> **Key Point:** *"CI catches bugs before they reach main. CD ensures production is always in a known-good state."*

### Discussion Prompt
*"What happens if you skip CI and push directly to main? What's the worst case?"*

---

## Phase 2: The Code (Live Walkthrough)

**Time:** 17 mins

### Step 1: Examine the CI Workflow (5 mins)
1. Open `code/dbt_ci.yml`
2. Walk through each section:
   - **Trigger:** `on: pull_request` — "It only runs when someone opens a PR against main"
   - **Steps:** Checkout → Python → Install dbt → Configure creds → deps → compile → test
3. Highlight the secrets:
   ```yaml
   echo "${{ secrets.DBT_PROFILES_YML }}" > ~/.dbt/profiles.yml
   ```
   - *"Credentials live in GitHub Secrets — never in the code repository"*

### Step 2: Examine the Multi-Environment Profile (4 mins)
1. Open `code/profiles_ci.yml`
2. Point out the three targets:
   - `dev` — local, per-engineer schema (`USER_dev`)
   - `ci` — isolated CI database, minimal permissions
   - `prod` — production, higher thread count
3. *"Each environment is completely isolated. CI tests cannot touch production data."*

### Step 3: Examine the CD Workflow (4 mins)
1. Open `code/dbt_deploy.yml`
2. Note the differences from CI:
   - Triggers on `push` to main (not PR)
   - Uses `environment: production` — can require manual approval in GitHub
   - Runs `dbt run` followed by `dbt test`
3. Point out the commented Slim CI section:
   - *"For large projects, you don't rebuild everything — just what changed and its downstream dependencies"*

### Step 4: Show a Failing Test Scenario (4 mins)
1. Describe verbally (or show a screenshot):
   - *"Imagine a PR that changes a customer model and breaks a NOT NULL test"*
   - The PR shows a red ❌ next to the check
   - The developer clicks in, sees `dbt test` failed, reads the error
   - They fix the model, push again, tests go green ✅
2. *"This feedback loop catches 90% of issues before a human reviewer even looks at the code"*

---

## Key Talking Points

- "CI/CD is NOT optional for production dbt — it's table stakes"
- "Separate environments prevent 'it works on my machine' problems"
- "Credentials in secrets, never in code — this is non-negotiable"
- "Slim CI (`state:modified+`) is critical for large projects with hundreds of models"
- Bridge to Week 5: "Remember dbt tests? Now they run automatically on every PR"

---

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| CI can't connect to Snowflake | Check GitHub Secrets are set correctly |
| Tests pass locally but fail in CI | Different data in CI vs dev database |
| CI is slow | Use Slim CI with `--select state:modified+` |
| Secrets exposed in logs | Use `::add-mask::` in GitHub Actions |

---

## Required Reading Reference

Before this demo, trainees should have read:
- `cicd-for-dbt.md` — CI/CD concepts, GitHub Actions workflows, deployment strategies
- `dataops-lifecycle.md` — DataOps lifecycle phases (context for why CI/CD matters)
