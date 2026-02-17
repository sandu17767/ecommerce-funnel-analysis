# 📊 E-Commerce Funnel Analysis  
### Session-Level Behavioral Modeling & Revenue Impact Case Study

---

## 📌 Project Overview

This project analyzes user behavior across the **View → Cart → Purchase** funnel to identify conversion bottlenecks and quantify revenue impact from targeted optimization.

Using 2 million event records from a large-scale e-commerce dataset, I constructed a sequential session-level funnel, performed category and price exposure segmentation, and translated findings into measurable business recommendations.

Rather than stopping at descriptive metrics, this project focuses on structured hypothesis testing, disciplined modeling decisions, and business impact quantification.

---

## 🎯 Business Objective

- Identify the primary conversion bottleneck  
- Determine whether performance issues are site-wide or segment-specific  
- Test price sensitivity assumptions using data-driven segmentation  
- Quantify potential revenue uplift from improving conversion  
- Provide actionable optimization recommendations  

---

## 🔎 Analytical Framework & Hypotheses

Before beginning analysis, the following hypotheses were defined:

- **H1:** Higher product prices reduce add-to-cart likelihood  
- **H2:** Conversion performance varies significantly by product category  
- **H3:** Low-priced segments attract lower purchase intent  
- **H4:** Tracking inconsistencies may distort raw funnel metrics  

Each hypothesis was tested through structured segmentation and consistent session-level modeling.

---

## 🗂 Dataset Summary

- Source: Kaggle eCommerce Behavior Dataset  
- 2M sampled event rows (from 5GB dataset)  
- 446,930 unique user sessions  
- Event types: `view`, `cart`, `purchase`  
- Key fields used: `user_session`, `event_type`, `category_code`, `price`  

---

## 🛠 Methodology

## Data Cleaning & Preparation

To ensure reliable funnel metrics, several data quality and tracking issues were handled during transformation.
### Event → Session Transformation
- Raw data contained multiple events per session.
- Aggregated events into **session-level flags** (viewed, carted, purchased).
- Prevents inflated activity and ensures the funnel reflects real user journeys.

### Sequential Funnel Enforcement
Tracking gaps showed purchases without cart events.  
To maintain a logical journey:

- Cart counted **only if a view occurred**
- Purchase counted **only if view + cart occurred**

This preserves the true sequence: **View → Cart → Purchase**

### Missing Category Handling
- Some events had **NULL category codes**.
- Excluded only from **category analysis** to avoid distorted comparisons.
- Retained for overall funnel calculations.

### Invalid Price Values
- Detected view events with **price = 0** (likely missing/incorrect data).
- Excluded from price segmentation to ensure accurate percentile buckets.

**Result:** Clean, session-level data ready for behavioural and conversion analysis.

These steps ensured reliable conversion metrics and trustworthy business insights.

## 📊 Core Funnel Results

| Stage | Sessions | Conversion |
|--------|----------|------------|
| View | 446,794 | — |
| Cart (after View) | 17,938 | 4.03% |
| Purchase (after Cart) | 10,116 | 56.39% |
| Clean View → Purchase | — | ~2.26% |

### 🔍 Key Insight

The primary bottleneck occurs at the **View → Cart stage**, not checkout.

Once users reach the cart, checkout performance is strong (56.39%), indicating that optimization efforts should focus on improving add-to-cart behavior.

---

## 🧩 Category-Level Behavioral Patterns

Session-category modeling was performed to determine whether performance issues were global or segment-specific.

### Key Findings:

- High-performing categories (e.g., smartphones) convert at ~8%+  
- Some accessory-heavy or low-ticket categories show near-zero sequential conversion  
- A significant number of low-price sessions include missing `category_code`  

### Strategic Observation:

Conversion performance is **highly category-dependent**, indicating that site-wide optimization may dilute ROI.  
Targeted category-level interventions are likely to yield stronger returns.

---

## 💰 Price Exposure Segmentation

To evaluate price sensitivity, session-level price exposure was constructed as follows:

1. Computed **average viewed price per session**  
2. Excluded `price = 0` from percentile calculation (documented separately)  
3. Created quartile-based price buckets using percentile cutoffs  

### Session-Level Price Buckets

- Q1 (Low Exposure) ≤ 79.66  
- Q2 ≤ 186.62  
- Q3 ≤ 418.37  
- Q4 (High Exposure) > 418.37  

### View → Cart by Price Bucket

| Bucket | Conversion |
|--------|------------|
| Q1 (Low Exposure) | 1.84% |
| Q2 | 4.91% |
| Q3 | 4.47% |
| Q4 (High Exposure) | 4.86% |

### Strategic Insight

Contrary to initial expectations, **low price exposure sessions convert worst**.

This suggests:

- Cheap product browsing may reflect low purchase intent  
- Accessory-heavy categories attract comparison shoppers  
- Conversion variation is driven by a combination of price exposure and category composition — not simply high prices suppressing demand  

---

## 🧩 Data Quality & Modeling Considerations

### Missing Category Codes

A significant portion of low-price exposure sessions contained missing `category_code` values.

**Approach taken:**
- Retained records in overall funnel calculations  
- Excluded NULL categories from category-level segmentation  
- Documented impact transparently  

---

### Purchase Without Cart Events

Some sessions recorded purchase events without corresponding cart events.

**Approach taken:**
- Enforced sequential funnel logic (View → Cart → Purchase)  
- Excluded sessions without intermediate cart events from stage progression  
- Documented as potential tracking inconsistency  

This preserved logical integrity while avoiding inflated conversion rates.

---

### Session-Level Price Representation

Price segmentation was based on **average viewed price per session**.

**Rationale:**
- Aligns with session-based funnel modeling  
- Reflects overall browsing price exposure  
- Reduces influence of extreme single-product views  

Price = 0 records were excluded from percentile calculations and treated as data irregularities.

---

## 📈 Business Impact Modeling

Scenario:

Increase View → Cart from **4.03% → 5%**

Estimated Impact:

- +4,402 additional cart sessions  
- +2,482 additional purchases  
- ~£395K revenue uplift (assuming stable average order value)  

### Strategic Conclusion

Incremental improvements at the primary bottleneck stage generate disproportionate revenue impact without increasing traffic.

---

## 💡 Strategic Recommendations

### 1️⃣ Prioritize View → Cart Optimization
- Improve product page persuasion  
- Strengthen trust signals (reviews, returns, warranties)  
- Add urgency indicators (stock levels, promotions)  

### 2️⃣ Focus on Underperforming Categories
- Audit low-performing accessory-heavy segments  
- Improve differentiation and product storytelling  
- Benchmark pricing competitiveness  

### 3️⃣ Optimize Low-Price Segments Strategically
- Introduce bundles and cross-sell opportunities  
- Implement shipping threshold incentives  
- Reduce comparison friction  

### 4️⃣ Audit Tracking & Categorization
- Investigate purchase-without-cart inconsistencies  
- Improve event logging reliability  
- Address missing product classification  

---

## ⚠️ Limitations

- No inventory or stock-level data available  
- No traffic source or demographic segmentation  
- Revenue modeling assumes stable average order value  
- Tracking inconsistencies may understate true cart behavior  

---

## 🧠 Skills Demonstrated

- Advanced SQL (CTEs, aggregation, segmentation)  
- Session-level behavioral modeling  
- Funnel bottleneck identification  
- Percentile-based price segmentation  
- Revenue impact scenario modeling  
- Data quality auditing  
- Business-first analytical storytelling  

---

## 📌 Final Conclusion

Conversion inefficiency is concentrated at the **View → Cart stage** and varies significantly by category and price exposure.

Optimization should be segment-specific rather than site-wide.

This project demonstrates structured hypothesis testing, disciplined modeling decisions, and measurable business impact translation — aligning technical execution with strategic business thinking.





## Project Story (How I Approached This Problem)

The goal of this project was to understand how customers move through an e-commerce purchase journey and identify where the biggest loss of potential buyers occurs.

I built a **session-level sequential funnel** to model the real customer journey:

View → Add to Cart → Purchase

A key decision was using **session-level analysis instead of event-level**.  
A single session can contain many product views, which would inflate activity and distort conversion if analysed at event level. Session-level modelling reflects real customer behaviour more accurately.

To preserve the true journey, I enforced **sequential funnel logic**, ensuring that:
- A cart must follow a view
- A purchase must follow a cart

This prevented tracking inconsistencies from inflating downstream conversion rates.

### Key Finding — The Bottleneck

The analysis revealed a major drop between **View → Cart (4.01%)**, while **Cart → Purchase remained strong (56.39%)**.

This indicates that checkout performs well, but **very few customers add products to their cart**.

### Understanding the Root Causes

To understand *why* this happens, I segmented the funnel by:

**1. Product Category**
Conversion varied dramatically across categories, with some exceeding 8% while others showed almost zero conversion. This suggests the issue is **category-specific**, not a site-wide problem.

**2. Session Price Exposure**
I calculated the **average price viewed per session** and divided sessions into quartiles to maintain balanced comparison groups.

The lowest price sessions converted the worst, suggesting these users have **lower purchase intent and higher price comparison behaviour**.

### Business Impact

Finally, I modelled a realistic improvement scenario.

Increasing View → Cart conversion from **4.01% to 5%** could generate an estimated:

**≈ £395,000 additional revenue**

This connects behavioural analytics directly to business value and highlights where optimisation efforts should focus.
