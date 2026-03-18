# Demo: Conditional Formatting — Data-Driven Visual Cues

## Overview
| Field | Detail |
|-------|--------|
| **Day** | 3-Wednesday |
| **Topic** | Conditional Formatting and DAX-Driven Styling |
| **Type** | Hybrid (Concept + Code) |
| **Time** | ~15 minutes |
| **Prerequisites** | Report with table/matrix visuals created |

**Weekly Epic:** *Data Storytelling — From Warehouse to Insight with Power BI and Streamlit*

---

## Phase 1: The Concept (Diagram)

**Time:** 3 mins

1. Open `diagrams/formatting-decision-tree.mermaid`
2. Walk through when to use each formatting type:
   - **Data bars** → Show relative magnitude
   - **Color scales** → Gradient from low to high
   - **Icons** → Status indicators (up/down/neutral)
   - **DAX-driven** → Full custom control with measures

> **Key Rule:** *"Don't overdo it — too many colors confuse. Pick ONE formatting technique per column."*

---

## Phase 2: The Code (Live Implementation)

**Time:** 12 mins

### Step 1: Data Bars (3 mins)
1. Create a **Table** visual with:
   - `DIM_PRODUCT[manufacturer]`
   - `[Total Revenue]`
2. Select Total Revenue column
3. **Format** > **Cell elements** > **Data bars** ON
4. *"Data bars show relative magnitude at a glance"*

### Step 2: Color Scales (3 mins)
1. In same table, add `[Avg Order Value]`
2. **Format** > **Cell elements** > **Background color**
3. Select **Color scale**
4. Configure:
   - Minimum: Light green
   - Maximum: Dark green
5. *"Color scales highlight high and low performers"*

### Step 3: Rule-Based Icons (3 mins)
1. Add `[YoY Growth]` measure to table (if created, or explain verbally)
2. **Format** > **Cell elements** > **Icons**
3. **Rules** tab:
   - If value > 0.1: Up arrow (green)
   - If value >= 0: Right arrow (yellow)
   - If value < 0: Down arrow (red)
4. *"Icons communicate status instantly"*

### Step 4: DAX-Driven Formatting (3 mins)

Create a formatting measure (reference `code/dax_conditional_formatting.txt`):
```dax
Revenue Color = 
IF([Total Revenue] > 10000000, "#2E7D32",
IF([Total Revenue] > 5000000, "#66BB6A",
"#FFEB3B"))
```

1. Apply to background color:
   - **Format** > **Cell elements** > **Background color**
   - Select **Field value**
   - Choose `[Revenue Color]`
2. *"DAX measures give ultimate formatting control — any logic, any color"*

---

## Key Talking Points

- "Conditional formatting guides user attention to what matters"
- "Rules should match business thresholds — not arbitrary numbers"
- "DAX-driven formatting is the most flexible but requires measure maintenance"

---

## Required Reading Reference

Before this demo, trainees should have read:
- `conditional-formatting.md` — Formatting techniques and best practices
- `analyze-feature.md` — AI-powered insights
