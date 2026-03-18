# dbt Project Initialization Demo

> **Day:** 4-Thursday  
> **Duration:** ~15 minutes  
> **Prerequisites:** Python installed, Snowflake Free Trial

---

## Phase 1: Create Virtual Environment

```bash
# Create a dedicated Python environment for dbt
python -m venv dbt_env

# Activate the environment
# Windows:
dbt_env\Scripts\activate

# Mac/Linux:
source dbt_env/bin/activate

# Verify Python is from the venv
which python  # Should show path to dbt_env
python --version
```

---

## Phase 2: Install dbt-snowflake

```bash
# Install dbt with Snowflake adapter
pip install dbt-snowflake

# Verify installation
dbt --version

# Expected output:
# Core:
#   - installed: 1.7.x
# Adapters:
#   - snowflake: 1.7.x
```

---

## Phase 3: Initialize dbt Project

```bash
# Create a new dbt project
dbt init snowflake_training

# Answer the interactive prompts:
# - Which database would you like to use? [1] snowflake
# - account: <your_account_id>  (e.g., abc12345.us-east-1)
# - user: <your_username>
# - password: (leave blank, we'll use env var)
# - role: ACCOUNTADMIN
# - warehouse: COMPUTE_WH
# - database: DEV_DB
# - schema: DBT_INSTRUCTOR
# - threads: 4
```

**Instructor Note:** Each trainee should use their own schema: `DBT_<their_name>`

---

## Phase 4: Configure profiles.yml

The `profiles.yml` file is created in your home directory:
- **Windows:** `C:\Users\<username>\.dbt\profiles.yml`
- **Mac/Linux:** `~/.dbt/profiles.yml`

### Recommended profiles.yml (with env var for password):

```yaml
snowflake_training:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: <ACCOUNT_IDENTIFIER>  
      # Format: abc12345.us-east-1 or org-account
      
      user: <YOUR_USERNAME>
      
      # Use environment variable for password (security best practice)
      password: "{{ env_var('SNOWFLAKE_PASSWORD') }}"
      
      database: DEV_DB
      schema: DBT_INSTRUCTOR  # Each trainee uses DBT_<their_name>
      warehouse: COMPUTE_WH
      role: ACCOUNTADMIN
      threads: 4
```

### Set the password environment variable:

```bash
# Windows (PowerShell)
$env:SNOWFLAKE_PASSWORD = "your_password_here"

# Windows (CMD)
set SNOWFLAKE_PASSWORD=your_password_here

# Mac/Linux
export SNOWFLAKE_PASSWORD="your_password_here"
```

---

## Phase 5: Verify Connection

```bash
# Navigate to project directory
cd snowflake_training

# Test the connection
dbt debug
```

**Expected Output (success):**
```
Connection:
  account: abc12345.us-east-1
  user: your_username
  database: DEV_DB
  schema: DBT_INSTRUCTOR
  warehouse: COMPUTE_WH
  role: ACCOUNTADMIN
  ...
  Connection test: OK connection ok
```

---

## Phase 6: Project Structure Tour

After `dbt init`, you'll have this structure:

```
snowflake_training/
|-- dbt_project.yml      # Project configuration
|-- models/              # SQL transformation models
|   |-- example/         # Sample models (can delete)
|-- seeds/               # CSV files for reference data
|-- snapshots/           # SCD Type 2 tracking
|-- tests/               # Custom data tests
|-- macros/              # Reusable SQL/Jinja functions
|-- analyses/            # Ad-hoc SQL files (not run by dbt)
```

### dbt_project.yml walkthrough:

```yaml
name: 'snowflake_training'
version: '1.0.0'

# Profile name (matches profiles.yml)
profile: 'snowflake_training'

# Model materialization defaults
models:
  snowflake_training:
    # Staging models as views (fast, cheap)
    staging:
      +materialized: view
    # Mart models as tables (optimized for queries)
    marts:
      +materialized: table
```

---

## Phase 7: First Run (Verify Everything Works)

```bash
# Run the example models included with dbt init
dbt run

# You should see output like:
# Found 2 models, 0 tests...
# Running 1 of 2 TABLE model...
# Completed successfully
```

Check Snowflake to verify:
- Navigate to DEV_DB > DBT_INSTRUCTOR schema
- You should see the example model tables

---

## Troubleshooting Common Issues

| Error | Solution |
|-------|----------|
| `Connection failed` | Check account format (abc12345.us-east-1), verify password env var |
| `Role does not exist` | Change role to your actual role or ACCOUNTADMIN |
| `Database does not exist` | Create DEV_DB in Snowflake first |
| `Permission denied` | Ensure your role has CREATE TABLE privileges on the schema |
| `Could not find profile` | Check profiles.yml is in ~/.dbt/ directory |

---

## Key Takeaways

1. **profiles.yml** = Snowflake connection (like Airflow connections) - keep out of Git
2. **dbt_project.yml** = Project config (like pyproject.toml or package.json)
3. **dbt debug** = First command to run after setup
4. **Environment variables** for passwords = security best practice
5. **Each trainee** should use their own schema to avoid conflicts

---

## Bridge to Spark/Airflow

| dbt Concept | Equivalent |
|-------------|------------|
| profiles.yml | Airflow connections |
| dbt_project.yml | pyproject.toml |
| dbt run | spark-submit / airflow trigger |
| models/ | Spark transformations |
| dbt debug | spark-shell test connection |

"dbt is like Airflow + Spark for SQL - you define transformations, and it handles dependencies and execution."
