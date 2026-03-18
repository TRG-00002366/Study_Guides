# Demo: Building the Star Schema in Power BI

## Overview
| Field | Detail |
|-------|--------|
| **Day** | 2-Tuesday |
| **Topic** | Data Modeling — Star Schema in Power BI |
| **Type** | Hybrid (Concept + Implementation) |
| **Time** | ~15 minutes |
| **Prerequisites** | Monday demos complete, Snowflake data imported into Power BI |

**Weekly Epic:** *Data Storytelling — From Warehouse to Insight with Power BI and Streamlit*

---

## Phase 1: The Concept (Whiteboard/Diagram)

**Time:** 5 mins

1. Open `diagrams/star-schema-model.mermaid`
2. Review the star schema design from Week 5:
   - **Fact table** at center: `FCT_ORDER_LINES` (measures: quantity, price, amount)
   - **Dimensions** surrounding it: `DIM_DATE`, `DIM_CUSTOMER`, `DIM_PRODUCT`
   - Each dimension connects via a **surrogate key** (1:* relationship)
3. Open `diagrams/WHITEBOARD_PLAN.md` for the cardinality discussion script

> **Discussion Prompt:** *"This is the SAME star schema from Week 5 — now in Power BI's engine. Why does the shape matter? Because filters flow FROM dimensions TO fact."*

---

## Phase 2: The Code (Live Implementation)

**Time:** 10 mins

### Step 1: Review Current State (3 mins)
1. Open the Power BI file from Monday
2. Switch to **Model View**
3. Point out auto-detected relationships
4. *"Power BI made guesses — let's verify they match our Week 5 design"*

### Step 2: Verify and Create Relationships (4 mins)

**Expected Relationships:**
```
DIM_DATE (date_key)         ----1:*---- FCT_ORDER_LINES (date_key)
DIM_CUSTOMER (customer_key) ----1:*---- FCT_ORDER_LINES (customer_key)
DIM_PRODUCT (product_key)   ----1:*---- FCT_ORDER_LINES (product_key)
```

1. **Delete incorrect relationships** (if any):
   - Right-click relationship line > Delete

2. **Create correct relationships:**
   - Drag `DIM_DATE.date_key` to `FCT_ORDER_LINES.date_key`
   - Drag `DIM_CUSTOMER.customer_key` to `FCT_ORDER_LINES.customer_key`
   - Drag `DIM_PRODUCT.product_key` to `FCT_ORDER_LINES.product_key`

3. **Verify settings for each** (double-click the line):
   - Cardinality: **One to many (1:*)**
   - Cross-filter direction: **Single**
   - Check "Make this relationship active"

### Step 3: Validate the Model (3 mins)
1. Point out the star shape in Model View
   - *"See how the fact table is at center? Dimensions surround it like points of a star"*
2. Explain filter direction arrows
   - *"Filters flow FROM dimensions TO fact — this is intentional"*
3. Create a quick test visual:
   - Drag `DIM_CUSTOMER[market_segment]` to axis
   - Drag `FCT_ORDER_LINES[net_amount]` to values
   - *"If relationships are wrong, this would show blanks or errors"*

---

## Key Talking Points

- "Relationships are critical — wrong relationships = wrong numbers"
- "Single direction filtering is the default for a reason"
- "The star shape isn't just theory — it directly affects how DAX calculations work"

---

## Required Reading Reference

Before this demo, trainees should have read:
- `designing-schemas.md` — Star schema in Power BI
- `writing-queries.md` — Power BI query patterns
