#!/bin/bash
# =============================================================================
# DEMO: dbt Documentation
# Day: 5-Friday
# Duration: ~10 minutes
# Purpose: Generate and serve interactive dbt documentation
# =============================================================================
#
# INSTRUCTOR NOTES:
# The dbt docs feature is a "wow" moment - auto-generated documentation
# with lineage graphs. Make sure to show the lineage visualization.
#
# KEY POINT: "This is auto-generated from your YAML descriptions and SQL.
# Share with stakeholders so they can trace data lineage themselves."
# =============================================================================


# =============================================================================
# PHASE 1: Generate Documentation
# =============================================================================

# Generate the documentation (static site files)
echo "Generating dbt documentation..."
dbt docs generate

# This creates files in the target/ directory:
# - target/catalog.json (metadata about all models)
# - target/manifest.json (DAG and model definitions)
# - target/run_results.json (last run status)


# =============================================================================
# PHASE 2: Serve Documentation Locally
# =============================================================================

# Start a local web server to view docs
echo "Starting documentation server on port 8081..."
dbt docs serve --port 8081

# This will:
# 1. Start a local web server
# 2. Open your browser to http://localhost:8081
# 3. Display interactive documentation


# =============================================================================
# WHAT TO SHOW IN THE BROWSER
# =============================================================================

# 1. MODEL LIST
#    - Left sidebar shows all models
#    - Click on a model to see its details
#    - Shows description, columns, and tests

# 2. COLUMN DOCUMENTATION
#    - Comes from your schema.yml files
#    - Shows data types, descriptions, tests applied

# 3. SOURCE DOCUMENTATION
#    - Shows external data sources
#    - Includes freshness information

# 4. THE LINEAGE GRAPH (THE WOW MOMENT!)
#    - Click the graph icon in bottom-right corner
#    - Shows full DAG from sources to marts
#    - Can filter to show just one model's dependencies
#    - Interactive - click nodes to navigate

# 5. SEARCH
#    - Use the search bar to find models, columns
#    - Great for large projects


# =============================================================================
# LINEAGE GRAPH EXPLORATION (Demo Walkthrough)
# =============================================================================

# In the browser:

# 1. Click the small graph icon in the bottom-right corner
#    (Opens the full lineage view)

# 2. You should see a DAG like:
#
#    BRONZE.RAW_EVENTS (source)
#           |
#           v
#      stg_events (staging)
#           |
#           v
#    fct_event_counts (mart)
#           |
#           v
#    fct_daily_events (incremental)

# 3. Click on a node (e.g., stg_events)
#    - Shows model details panel
#    - Can filter graph to show only related nodes

# 4. Use filtering options:
#    - "+1" shows one level of dependencies
#    - "Show all" shows complete lineage
#    - Can select multiple nodes

# 5. Click "Sources" filter to highlight external data


# =============================================================================
# ALTERNATIVE: GENERATE FOR SHARING
# =============================================================================

# Generate docs for hosting on a static server
dbt docs generate --target-path ./docs_output

# The files in docs_output/ can be:
# - Hosted on GitHub Pages
# - Uploaded to S3 with static website hosting
# - Deployed to any web server

# Some teams set up CI/CD to auto-deploy docs on merge to main


# =============================================================================
# INSTRUCTOR TALKING POINTS
# =============================================================================

# 1. "Everything here is auto-generated from your YAML descriptions.
#     Write good descriptions once, get documentation for free."

# 2. "The lineage graph is like Airflow's Graph View, but for data
#     transformations. Click on any model to trace its dependencies."

# 3. "This is what you share with data analysts and stakeholders.
#     They can trace any column back to its source."

# 4. "The search feature is huge for large projects - find any
#     model, column, or source instantly."

# 5. "Many teams deploy this to a shared URL so everyone can access it.
#     No need to run dbt locally just to see documentation."


# =============================================================================
# CLEANUP
# =============================================================================

# Stop the server with Ctrl+C
# The docs are also viewable by opening target/index.html directly


echo "Documentation demo complete!"
echo ""
echo "Key takeaways:"
echo "1. dbt docs generate - Creates documentation files"
echo "2. dbt docs serve - Starts local web server"
echo "3. Lineage Graph - Click the icon in bottom-right"
echo "4. Descriptions from YAML become searchable docs"
echo "5. Share with stakeholders via static hosting"
