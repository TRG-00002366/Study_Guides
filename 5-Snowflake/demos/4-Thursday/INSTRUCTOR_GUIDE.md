# Instructor Guide: Thursday Demos (dbt Fundamentals)

## Overview
**Day:** 4-Thursday - dbt Fundamentals (Pair Programming Day)  
**Total Demo Time:** ~65 minutes  
**Prerequisites:** DEV_DB with BRONZE.RAW_EVENTS table, Python installed, (Optional for replication demo: multi-account setup or ORGADMIN privileges)

---

## Pre-Demo Setup (Do this before class!)

### 1. Create Python Environment
```bash
# Create virtual environment
python -m venv dbt_env

# Activate (Windows)
dbt_env\Scripts\activate

# Activate (Mac/Linux)
source dbt_env/bin/activate

# Install dbt-snowflake
pip install dbt-snowflake
```

### 2. Have profiles.yml Template Ready
```yaml
snowflake_training:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: <ACCOUNT_ID>  # e.g., abc12345.us-east-1
      user: <USERNAME>
      password: "{{ env_var('SNOWFLAKE_PASSWORD') }}"
      database: DEV_DB
      schema: DBT_INSTRUCTOR
      warehouse: COMPUTE_WH
      role: ACCOUNTADMIN
      threads: 4
```

### 3. Ensure BRONZE.RAW_EVENTS has data (from Wednesday demos)

---

## Demo 1: dbt Project Initialization

**Directory:** `demo_dbt_init/`  
**Time:** ~15 minutes

### Phase 1: Project Creation (5 mins)
1. Run `dbt init snowflake_training`
2. Answer prompts (database, schema, warehouse)
3. Walk through created file structure

### Phase 2: Connection Test (5 mins)
1. Set SNOWFLAKE_PASSWORD environment variable
2. Run `dbt debug` to verify connection
3. Troubleshoot common issues

### Phase 3: Project Structure Tour (5 mins)
1. Explain `dbt_project.yml`
2. Show models/, seeds/, tests/ directories
3. Explain profiles.yml location

### Key Talking Points
- "profiles.yml is like Airflow connections - keep it out of Git"
- "dbt_project.yml is your project config, like pyproject.toml"
- "dbt debug is your first sanity check"

---

## Demo 2: Sources and Staging Models

**Files:** `demo_dbt_sources.yml`, `demo_dbt_models.sql`  
**Time:** ~15 minutes

### Phase 1: Define Sources (5 mins)
1. Create `models/staging/sources.yml`
2. Reference BRONZE.RAW_EVENTS
3. Explain source() function

### Phase 2: Create Staging Model (7 mins)
1. Create `models/staging/stg_events.sql`
2. Use source() to reference raw data
3. Apply simple transformations (UPPER, casting)
4. Run `dbt run --select stg_events`

### Phase 3: View Results in Snowflake (3 mins)
1. Check DBT_INSTRUCTOR schema in Snowsight
2. Show the generated view/table
3. Query the results

### Key Talking Points
- "source() is like an Airflow sensor pointing to external data"
- "ref() is coming next - it's how you chain models together"
- "dbt wrote the CREATE VIEW for you"

---

## Demo 3: Model Dependencies with ref()

**File:** `demo_dbt_models.sql` (continued)  
**Time:** ~10 minutes

### Phase 1: Create Intermediate Model (5 mins)
1. Create `models/marts/fct_event_counts.sql`
2. Use ref('stg_events') to reference staging
3. Show the DAG relationship

### Phase 2: Run Full Pipeline (5 mins)
1. Run `dbt run` (all models)
2. Check Snowflake for both tables
3. Show `dbt run --select +fct_event_counts` (with upstream)

### Key Talking Points
- "ref() tells dbt about dependencies, like Airflow >>"
- "dbt figures out the order automatically"
- "The + prefix means 'include upstream models'"

---

## Demo 4: dbt Tests

**File:** `demo_dbt_tests.yml`  
**Time:** ~10 minutes

### Phase 1: Add Schema Tests (5 mins)
1. Create `models/staging/staging.yml`
2. Add unique, not_null tests to event_id
3. Add accepted_values test to event_type

### Phase 2: Run Tests (5 mins)
1. Run `dbt test`
2. Show passing tests
3. Intentionally break a test to show failure output

### Key Talking Points
- "Tests are like Airflow data quality operators"
- "unique and not_null are built-in"
- "When tests fail, dbt gives you the SQL to debug"

---

## Demo 5: Database Replication

**File:** `demo_database_replication.sql`  
**Time:** ~15 minutes

### Phase 1: Concepts Overview (3 mins)
1. Explain replication use cases (DR, data sharing, read replicas)
2. Show `SHOW REPLICATION ACCOUNTS;` and `SHOW REGIONS;`
3. Discuss when replication is needed vs. cloning

### Phase 2: Replication Group Syntax (5 mins)
1. Walk through CREATE REPLICATION GROUP syntax
2. Explain OBJECT_TYPES, ALLOWED_DATABASES, REPLICATION_SCHEDULE
3. Show secondary database creation syntax

### Phase 3: In-Account Clone Demo (5 mins)
1. Create demo source database with sample orders
2. Clone the database (instant, zero-copy)
3. Insert new records into source to show drift
4. Compare record counts between source and clone

### Phase 4: Failover Concepts (2 mins)
1. Explain `ALTER DATABASE ... PRIMARY` for failover
2. Discuss Business Critical edition requirements
3. Show clone vs. replication comparison table

### Key Talking Points
- "Replication is like Airflow's backup DAG strategy - ensuring continuity"
- "Zero-copy clones share storage until data diverges"
- "For true DR, use Replication Groups across regions"
- "Unlike traditional replication, no log shipping or lag troubleshooting"

---

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| dbt debug fails | Check password env var, account format |
| Model not found | Verify file is in models/ directory |
| Permission denied | Check role in profiles.yml |
| Source not found | Check database/schema in sources.yml |
| ref() circular dependency | Restructure model hierarchy |

---

## Pair Programming Setup

After demos, trainees pair up:
- **Driver:** Types code in VS Code
- **Navigator:** References docs, validates DAG structure
- **Rotation:** Switch after completing staging layer

Each pair creates:
1. Their own schema: DBT_<trainee_name>
2. One staging model
3. One mart model
4. Tests on both

---

## Transition to Friday
"Today you learned dbt fundamentals: sources, staging, ref(), and tests. Tomorrow we'll cover advanced topics: incremental models, Jinja templating, and materializations."
