# Instructor Guide: Friday Demos

## Overview
**Day:** 5-Friday - dbt Transformations & Use Cases  
**Total Demo Time:** ~45 minutes  
**Prerequisites:** Thursday dbt project created and working

---

## Demo 1: dbt Transformations (Advanced)

**File:** `demo_dbt_transformations.sql`  
**Time:** ~20 minutes

### Key Points
1. Incremental models - process only new data
2. is_incremental() returns FALSE on first run
3. {{ this }} references the current table
4. Jinja templating for loops and conditionals
5. Custom macros for reusable logic
6. dbt compile to preview generated SQL

### Talking Points
- "Incremental models are like Spark's merge into Delta Lake"
- "First run = full load, subsequent runs = only new data"
- "Jinja is like Python f-strings but for SQL"
- "Use dbt compile to debug complex Jinja"

---

## Demo 2: dbt Materializations

**File:** `demo_dbt_materializations.sql`  
**Time:** ~15 minutes

### Key Points
1. VIEW - no storage, computes at query time
2. TABLE - stored data, fast queries, full rebuild
3. INCREMENTAL - stored data, only new rows processed
4. EPHEMERAL - no table created, inlined as CTE

### Decision Matrix
| Materialization | Storage | Compute on Query | Best For |
|-----------------|---------|------------------|----------|
| view | None | Every query | Staging |
| table | Full | None | Marts |
| incremental | Full | None | Large facts |
| ephemeral | None | Every query | Logic reuse |

### Talking Points
- "VIEW = cheap to create, slow to query. Good for staging."
- "TABLE = fast to query, slow to rebuild. Good for marts."
- "INCREMENTAL = best of both for large data."
- "Set defaults in dbt_project.yml to avoid repetition."

---

## Demo 3: dbt Documentation

**File:** `demo_dbt_docs.sh`  
**Time:** ~10 minutes

### Key Points
1. dbt docs generate - creates documentation
2. dbt docs serve - starts local web server
3. Lineage graph visualization
4. Column-level documentation from YAML

### The Wow Moment
Show the lineage graph - click the icon in bottom-right corner of the docs UI.

### Talking Points
- "Everything here is auto-generated from your YAML descriptions"
- "The lineage graph is like Airflow's Graph View for data"
- "Share this URL with stakeholders for self-service data discovery"

---

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Incremental processes all data | Check is_incremental() filter logic |
| Jinja syntax errors | Use dbt compile to see generated SQL |
| dbt docs serve port in use | Use --port flag: dbt docs serve --port 8082 |
| Lineage graph empty | Ensure models use ref() for dependencies |

---

## Week 5 Wrap-Up

### Key Accomplishments
- Snowflake architecture and setup
- Data loading with COPY INTO and Snowpipe
- Streams & Tasks for automation
- Star schema design
- dbt project creation and models
- Incremental processing and materializations

### What's Next (Week 6: Visualization)
"You've built the data foundation. Next week, you'll connect Power BI and Streamlit to visualize this data."
