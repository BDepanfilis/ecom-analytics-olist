# ecom-analytics-olist (dbt + BigQuery)

[![dbt docs](https://img.shields.io/badge/dbt-docs-live-brightgreen)](https://bdepanfilis.github.io/ecom-analytics-olist/)

End-to-end analytics stack for the public Olist ecommerce dataset, built with **dbt** on **BigQuery**.  
Includes cost guardrails (opt-in query execution), clean staging/core/marts layers, tests, seeds, and docs.

---

## Contents
- [Project layout](#project-layout)
- [Prerequisites](#prerequisites)
- [One-time setup (Windows-friendly)](#one-time-setup-windows-friendly)
- [Credentials & profiles](#credentials--profiles)
- [Cost guardrails](#cost-guardrails)
- [Common commands](#common-commands)
- [Selectors (quick run lists)](#selectors-quick-run-lists)
- [Docs](#docs)
- [Testing & data quality](#testing--data-quality)
- [Seeds](#seeds)
- [CI-friendly runs (no billing)](#ci-friendly-runs-no-billing)
- [Troubleshooting](#troubleshooting)

---

## Project layout

```
dbt/
├─ dbt_project.yml
├─ packages.yml
├─ selectors.yml
├─ macros/
│  ├─ hooks.sql                 # on-run-start guard: blocks BQ unless enabled
│  └─ utils.sql                 # helper macros (safe casts, date keys, etc.)
├─ models/
│  ├─ staging/
│  │  ├─ stg_customers.sql
│  │  ├─ stg_orders.sql
│  │  ├─ stg_order_items.sql
│  │  ├─ stg_payments.sql
│  │  ├─ stg_reviews.sql
│  │  ├─ stg_sellers.sql
│  │  └─ stg_products.sql
│  ├─ core/
│  │  ├─ dim_date.sql
│  │  ├─ dim_customer.sql
│  │  ├─ dim_seller.sql
│  │  ├─ dim_product.sql
│  │  ├─ fact_order_lines.sql
│  │  └─ fact_orders.sql
│  └─ marts/
│     ├─ mart_sales_daily.sql
│     ├─ mart_customer_cohorts.sql
│     ├─ mart_returns_quality.sql
│     └─ mart_marketing_roi.sql
├─ tests/                       # (if you keep custom tests)
├─ seeds/
│  ├─ marketing_spend_daily.csv
│  ├─ product_category_name_translation.csv
│  └─ web_sessions.csv
└─ seeds.yml                    # seed tests (dbt_expectations + built-ins)
```

> Keep YAML model schemas alongside their models (e.g., `models/core/_core_schema.yml`) to document columns & tests.  
> `selectors.yml` always lives at the **project root** (`dbt/`).

---

## Prerequisites

- Python 3.12 (or 3.10/3.11 with matching dbt-bigquery version)
- BigQuery project (even for metadata/docs)
- Service account or gcloud ADC credentials
- `dbt-core==1.10.x` and `dbt-bigquery==1.10.x`

**Install deps**
```bat
python -m venv .venv312
.venv312\Scripts\activate
pip install --upgrade pip
pip install "dbt-bigquery==1.10.1"
dbt deps
```

---

## Credentials & profiles

Create a dbt **profile** pointing at BigQuery. If you’re using a service account JSON:

```yaml
# ~/.dbt/profiles.yml
analytics_olist:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: service-account
      keyfile: C:/ABSOLUTE/PATH/TO/service_account.json
      project: YOUR_GCP_PROJECT
      dataset: analytics_olist
      threads: 4
      timeout_seconds: 300
      location: US
```

Alternatively, with `gcloud auth application-default login`, set:
```bat
set GOOGLE_APPLICATION_CREDENTIALS=%USERPROFILE%\AppData\Roaming\gcloud\application_default_credentials.json
```

---

## Cost guardrails

All BigQuery work is **off by default** via an env var checked in `macros/hooks.sql`.

- **Block queries (safe mode / CI):** `ALLOW_BIGQUERY_RUNS` unset or `FALSE`
- **Allow queries (local dev):** `ALLOW_BIGQUERY_RUNS=TRUE`

Windows CMD:
```bat
rem Block BQ:
set ALLOW_BIGQUERY_RUNS=FALSE

rem Allow BQ:
set ALLOW_BIGQUERY_RUNS=TRUE
```

---

## Common commands

```bat
rem Install dbt packages
dbt deps

rem (Optional) clean build artifacts
dbt clean

rem Load seeds (writes 3 small CSVs to BigQuery)
set ALLOW_BIGQUERY_RUNS=TRUE
dbt seed --full-refresh

rem Full build (no snapshots)
dbt build --exclude resource_type:snapshot

rem Staging only
dbt run --models staging

rem Run tests only
dbt test
```

---

## Selectors (quick run lists)

We include a `selectors.yml` with a `ci` selector that compiles/tests without running heavy stuff.

Example:
```yaml
selectors:
  - name: ci
    description: "Compile + run tests only; no snapshots."
    definition:
      union:
        - method: fqn
          value: "*"
      exclude:
        - method: tag
          value: snapshot
```

Use it:
```bat
dbt compile --selector ci
dbt test    --selector ci
```

> Compiling & testing may still touch metadata; guardrails protect execution queries.

---

## Docs

Build docs (queries BigQuery INFORMATION_SCHEMA for the catalog):

```bat
set ALLOW_BIGQUERY_RUNS=TRUE
dbt docs generate
dbt docs serve --port 8080
```

**No-billing option:** if you already have `target/manifest.json` + `target/catalog.json` from a prior allowed run, you can just:
```bat
dbt docs serve --port 8080
```
(Serving doesn’t query BQ; generating the catalog does.)

---

## Testing & data quality

- Built-in tests: `unique`, `not_null`, `relationships`, `accepted_values`
- Package tests: `dbt_expectations` (value ranges, etc.)
- Model & seed column descriptions live in the model-level schema YAMLs and `seeds.yml`.
- Add new tests directly in the schema YAMLs near each model.

Run:
```bat
dbt test
```

---

## Seeds

We ship three seeds:
- `marketing_spend_daily.csv`
- `product_category_name_translation.csv`
- `web_sessions.csv` (with `events` as string; validated in staging)

Refresh:
```bat
set ALLOW_BIGQUERY_RUNS=TRUE
dbt seed --full-refresh
```

---

## CI-friendly runs (no billing)

```bat
rem Block queries
set ALLOW_BIGQUERY_RUNS=FALSE

rem Lint/parse/compile/tests (tests that require execution will be blocked)
dbt deps
dbt compile --selector ci
dbt test    --selector ci
```

You can still serve previously generated docs (`dbt docs serve`) if `target/` already contains a catalog.

---

## Troubleshooting

**“Env var required but not provided: ALLOW_BIGQUERY_RUNS”**  
Set it explicitly:
```bat
set ALLOW_BIGQUERY_RUNS=TRUE   rem for real runs
rem or
set ALLOW_BIGQUERY_RUNS=FALSE  rem for safe mode
```

**Duplicate macro name**  
Keep a single guard macro. We use `macros/hooks.sql`; don’t add another `assert_env_allows_bq_runs` elsewhere.

**Docs generate fails with missing dataset (snapshots)**  
Create the dataset noted in the error (e.g., `analytics_olist_snapshots`) in BigQuery.

**Seed type errors**  
If BQ complains about numeric types, ensure the CSV values match the types we configure/tests expect (we use decimals in CSV; BQ casts accordingly in staging models if needed).

---

## License

MIT 
