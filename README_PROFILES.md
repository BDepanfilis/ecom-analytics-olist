# dbt profile

Create (or edit) `~/.dbt/profiles.yml`:

```yaml
ecom_olist:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: service-account
      keyfile: /ABSOLUTE/PATH/TO/your-service-account.json
      project: YOUR_GCP_PROJECT
      dataset: analytics_olist
      threads: 4
      timeout_seconds: 300
      location: US
      priority: interactive
```
