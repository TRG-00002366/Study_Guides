# Whiteboard Plan: ETL → Refresh → Dashboard Timeline

## Drawing Script

### Draw a Timeline

```
6:00 AM                                     7:00 AM         7:30 AM
  |                                            |               |
  ├── Airflow DAG starts ──────────────────────┤               |
  |   • Extract from source systems            |               |
  |   • Bronze → Silver → Gold (dbt)           |               |
  |   • Data quality checks                    |               |
  |                                            |               |
  |                                   ETL Complete              |
  |                                            |               |
  |                                            ├── Power BI    |
  |                                            |   Scheduled   |
  |                                            |   Refresh     |
  |                                            |   Starts      |
  |                                            |               |
  |                                            |          Refresh Done
  |                                            |               |
  |                                            |               ├── Dashboard Updated
  |                                            |               |   Users see fresh data
```

### Key Points to Write

1. **Schedule Order Matters:**
   - Airflow ETL → finishes → THEN Power BI refresh starts
   - If refresh runs DURING ETL, dashboard may show partial data

2. **Timing Strategy:**
   - ETL often runs in early morning (e.g., 4–6 AM)
   - Schedule Power BI refresh 1–2 hours AFTER ETL expected completion
   - Add buffer for ETL delays

3. **Monitoring Chain:**
   ```
   Airflow Alerts (ETL failures)
        ↓
   Power BI Refresh Alerts (credential/connection issues)
        ↓
   Data Alerts (business threshold monitoring)
   ```

4. **Question for Class:**
   > "What happens if your Airflow DAG fails but Power BI still refreshes?"
   > Answer: Dashboard shows yesterday's data — users may not notice unless you have alerts.
