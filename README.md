# Insurance Analytics Base Table

Building a single customer-level analytics table from four separate policy systems — in MySQL and in R — then using it to answer who buys what, through which channel.

**Stack:** MySQL · R · dplyr · ggplot2
**Data:** four source tables — customers, motor, health and travel policies. Not included (coursework data).

---

## The problem

An insurer holds its data in four places: one customer table, and three policy tables that don't talk to each other. Nobody can answer "how many of our customers hold more than one product" without joining them first.

The job is to build the **analytics base table** — one row per customer, every product flattened onto it — and then prove the table is trustworthy before anyone analyses anything with it.

---

## What the build does

**One row per customer, left joins throughout.** Customers is the base; motor, health and travel are joined on their respective policy IDs. Left joins matter here — an inner join would silently drop every customer who doesn't hold all three products, which is most of them.

**Column names are disambiguated on the way in.** Three policy tables each have a start date, an end date and a type. Flattened onto one row they'd collide, so they become `MotorPolicyStart`, `HealthPolicyStart`, `TravelPolicyStart` and so on. Unglamorous, and the thing that makes the table usable.

**Product ownership is derived, not assumed.** `has_motor`, `has_health` and `has_travel` are set from whether a policy start date survived the join. This turns absence into a fact you can count.

---

## Data quality

The table is audited before it's used, not after.

| Check | Rule |
|---|---|
| Impossible ages | `Age < 0` or `Age > 100` → NA rather than deleted, so the row survives for other analyses |
| Missing claims | `clm` and `Numclaims` nulls → 0 — no policy record means no claims, not unknown claims |
| Date logic | Policy end must be on or after policy start, checked for all three product lines |
| Claim flag validity | Flag must be 0 or 1; anything else caught |
| Negative claims | Claim counts below zero caught |
| Invalid card type | `"0"` → NA |
| Duplicates | Grouped by customer ID, anything appearing more than once flagged |
| Key missingness | Null counts audited for age, gender, location and channel |
| Uniqueness | Row count checked against distinct customer count — the test that the joins didn't fan out |

**Vehicle value is winsorised at the 99th percentile** rather than trimmed. Extreme vehicle values are real customers, not errors — capping keeps them in the table while stopping a handful of supercars dragging every mean.

The row-count-versus-distinct-customer check is the important one. A left join that accidentally matches one-to-many inflates the table without any obvious symptom, and every downstream average silently becomes wrong.

---

## The analysis

Four questions, each a grouped aggregation off the finished table:

| Output | What it computes |
|---|---|
| `q1_channel_profile` | Customers per communication channel — count, share, median age, age IQR |
| `q2_uptake_by_channel` | Motor / health / travel uptake rate per channel |
| `q3_uptake_by_age` | The same uptake rates by age group (under 30, 30–49, 50+, unknown) |
| `q4_motor_claims_by_channel` | Motor holders only — claim rate, median and IQR of claim counts, median and IQR of exposure, by channel |

Medians and IQRs rather than means and standard deviations throughout, because age and claim counts are both skewed and a mean would misdescribe them.

---

## Why it's built twice

The same pipeline exists in SQL and in R, and they do different halves of the job well. SQL constructs the base table and runs the structural audits — joins, uniqueness, null counts, referential logic — which is what a database is for. R does the cleaning decisions, the derived features and the visualisation, which is what SQL is bad at. Doing both is the point of the exercise: knowing which tool to reach for is most of data management.

---

## Run it

```sql
-- MySQL: creates the database, renames source tables, builds insurance.abt_insurance
SOURCE insurance_abt.SQL;
```

```r
# Requires: dplyr, ggplot2
source("insurance_ant_raw_code.R")
```

Source data is not distributed with this repository.

---

## Licence

MIT — see `LICENSE`.

---

## Notes

Written with AI assistance for code drafting; the table design, quality rules and analytical questions are my own.
