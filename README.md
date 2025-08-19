# ecom-analytics-olist (dbt project)

**Curated analytics warehouse for the public Olist e‑commerce dataset, built with dbt.**  
This repo turns raw Olist tables into a clean star schema and business-ready marts for revenue, marketing ROI, customer cohorts, and returns quality. It includes data tests, seeds, and auto‑published dbt Docs (lineage) to GitHub Pages.

> Live docs: **https://bdepanfilis.github.io/ecom-analytics-olist**

---

## Why this project matters (Analytics / Data Engineering)
- **End‑to‑end ELT**: sources → staging (canonicalizes raw) → core dims/facts → marts for consumption.
- **Data quality**: schema & data tests with `dbt_utils` and `dbt_expectations` to prevent silent data drift.
- **Developer ergonomics**: DuckDB profile for local/CI compile & docs; optional BigQuery execution guarded by an environment flag to avoid accidental warehouse spend.
- **Observability**: dbt Docs published via GitHub Actions/GitHub Pages (automated lineage and table documentation).
- **Reproducible**: seeds (synthetic marketing/web data) included; versions pinned in `packages.yml`.
- **Portable**: works on Windows/macOS/Linux; no external services required for local development.

- Clear **ELT layering** (staging → core → marts) with naming conventions and modular SQL.
- **Data quality** via tests and package usage (`dbt_utils`, `dbt_expectations`).
- **Documentation & lineage** shipped to GitHub Pages; exposure metadata included.
- Sensible **cost controls** and a **warehouse‑agnostic** dev workflow (DuckDB first).
- Clean, reproducible repo structure with seeds, selectors, and profiles.

---

## Tech stack
- **dbt Core** (project structure, Jinja-SQL macros)
- **DuckDB** (local dev & CI compile/docs target)
- **BigQuery (optional)** for warehouse execution — disabled by default via an environment “safety guard”
- dbt packages: `dbt_utils`, `dbt_expectations`, `dbt_date`
- **GitHub Actions** → **GitHub Pages** for automated docs

> Note: Exact dbt/dbt‑adapter versions are pinned in `packages.yml` and were validated during setup.

---

## Model layers & outputs

```
models/
├─ staging/                        # Source-conformed staging models (one-to-one with raw Olist tables)
│  ├─ stg_customers.sql
│  ├─ stg_orders.sql
│  ├─ stg_order_items.sql
│  ├─ stg_payments.sql
│  ├─ stg_products.sql
│  ├─ stg_reviews.sql
│  └─ stg_sellers.sql
├─ core/                           # Business-ready dimensions & facts
│  ├─ dim_customer.sql
│  ├─ dim_product.sql
│  ├─ dim_seller.sql
│  ├─ fact_orders.sql
│  └─ fact_order_lines.sql
└─ marts/                          # Presentation layer for BI / analysis
   ├─ mart_sales_daily.sql
   ├─ mart_marketing_roi.sql
   ├─ mart_customer_cohorts.sql
   └─ mart_returns_quality.sql
```

- **Sources**: defined under `models/_sources/` (or `sources.yml`), pointing to Olist raw tables (e.g., `olist.olist_orders_dataset`, `olist.olist_order_items_dataset`, …).
- **Seeds** (`/seeds`): small CSVs to enrich the model set, e.g.
  - `marketing_spend_daily.csv` – mock channel spend for ROI
  - `product_category_name_translation.csv` – pt‑BR → English
  - `web_sessions.csv` – minimal traffic/session data for attribution examples
- **Tests**: schema/data tests across layers, e.g. `accepted_values`, `relationships`, and `dbt_expectations` checks (nulls, ranges, set membership).  
  See `models/**/_*schema.yml` files.
- **Exposure**: a sample “Dashboard” exposure documented in `_exposures.yml` to demonstrate governance/ownership metadata.

---

## Quick start (local, no warehouse needed)

```bash
# 1) (Recommended) create a venv
python -m venv .venv
# Windows
.\.venv\Scripts\activate
# macOS/Linux
source .venv/bin/activate

# 2) Install dbt + adapters + linting
pip install --upgrade pip
pip install dbt-core dbt-duckdb sqlfluff sqlfluff-templater-dbt

# 3) Install dbt packages
dbt deps

# 4) Use the DuckDB profile (already included). Then compile & generate docs:
dbt compile --target duckdb
dbt docs generate --target duckdb

# 5) Open local docs
dbt docs serve
```

> The repo includes a DuckDB profile for CI/docs. No external services are required to **compile** or **generate docs** locally.

---

## Running against BigQuery (optional)

BigQuery execution is intentionally **off by default** to avoid accidental spend in CI or on first run.
To enable it on your machine:

1) Configure your `~/.dbt/profiles.yml` with a `bigquery` target for profile `olist` (or reuse the provided example under `.github/profiles`).  
2) Set the env flag to acknowledge you want to run BQ:

```bash
# Windows PowerShell
$env:ALLOW_BIGQUERY_RUNS="1"

# macOS/Linux bash/zsh
export ALLOW_BIGQUERY_RUNS=1
```

3) Build selectively or the whole project:

```bash
dbt build --target bigquery --select staging+ core+ marts
```

> **Safety guard**: if `ALLOW_BIGQUERY_RUNS` is not set to `1`, dbt will refuse to run against BigQuery. This is enforced via a small macro hooked into `on-run-start`.

---

## Project commands you’ll use often

```bash
# Run everything (choice of target)
dbt build --target duckdb
dbt build --target bigquery  # requires ALLOW_BIGQUERY_RUNS=1 and BQ creds

# Generate docs (also used by CI)
dbt docs generate --target duckdb

# Unit of work (materialize one layer and its dependencies)
dbt build --select staging+
dbt build --select core+
dbt build --select marts+

# Lint SQL (templated via dbt)
sqlfluff lint models macros seeds --dialect bigquery
```

---

## CI/CD
- **Docs pipeline** (GitHub Actions): compiles the project on DuckDB and publishes dbt Docs to **GitHub Pages**.  
  This guarantees docs availability without touching a paid warehouse.
- Optional **compile-only CI** job validates parsing on PRs (fast feedback loop).
- Packages are pinned; `dbt deps` runs in CI to lock deterministic versions.

---

## Data & licensing
- **Dataset**: Olist public e‑commerce dataset (commonly distributed via Kaggle). Raw table names are referenced via dbt `source()` definitions (see`sources.yml`).  
- **License**: MIT (see `LICENSE`).

---

## Repo map (top level)
```
.github/                 # CI workflows & example profiles (DuckDB/BQ)
macros/                  # Project macros (guards, helpers)
models/                  # Staging, core, marts, exposures & tests
seeds/                   # Small CSVs for enrichment
scripts/                 # (Optional) helper scripts
dbt_project.yml          # Project config
packages.yml             # Pinned packages
profiles.yml             # Example profiles (for reference)
selectors.yml            # Named node selectors for fast iteration
README.md                # This file
```

---
