# Whiteboard Plan: Star Schema Relationships

## Drawing Script

### Step 1: Draw the Star (3 mins)

Draw on the whiteboard:

```
                    ┌──────────────┐
                    │  DIM_DATE    │
                    │  date_key PK │
                    └──────┬───────┘
                           │ 1:*
    ┌──────────────┐       │        ┌──────────────┐
    │ DIM_CUSTOMER │───────┼────────│ DIM_PRODUCT  │
    │ customer_key │  1:*  │  1:*   │ product_key  │
    └──────────────┘       │        └──────────────┘
                    ┌──────┴───────┐
                    │ FCT_ORDER    │
                    │  _LINES      │
                    │ (Center)     │
                    └──────────────┘
```

### Step 2: Explain Cardinality

**Draw arrows and label them:**

| Relationship | Type | Meaning |
|-------------|------|---------|
| DIM_DATE → FCT | 1:* | One date has many order lines |
| DIM_CUSTOMER → FCT | 1:* | One customer has many orders |
| DIM_PRODUCT → FCT | 1:* | One product appears in many order lines |

### Step 3: Filter Direction Discussion

Draw a large arrow from each dimension toward the fact table:

```
DIM_DATE       ──filter──→  FCT_ORDER_LINES
DIM_CUSTOMER   ──filter──→  FCT_ORDER_LINES
DIM_PRODUCT    ──filter──→  FCT_ORDER_LINES
```

**Key Question to Ask:**
> "When a user selects '2023' in a slicer, which direction does the filter travel?"
> 
> Answer: FROM `DIM_DATE` TO `FCT_ORDER_LINES` — the fact table gets filtered.

**Why Single Direction?**
- Prevents ambiguous query results
- Matches how users naturally think: "Show me sales FOR this year"
- Bidirectional creates performance and correctness issues

### Step 4: Anti-Pattern Warning

Draw a BAD example:
```
DIM_CUSTOMER ←→ FCT_ORDER_LINES ←→ DIM_PRODUCT
     ↑                                    ↑
     └────────── WRONG ───────────────────┘
     (direct relationship between dimensions)
```

"Never connect two dimensions directly — always go through the fact table."
