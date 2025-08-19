{% macro assert_env_allows_bq_runs() %}
  {# If caller asked to skip (e.g., compile/docs), do nothing #}
  {% if var('skip_on_run_start', false) %}
    {{ return('') }}
  {% endif %}

  {# Hard guard: only allow warehouse work when explicitly enabled #}
  {% if env_var('ALLOW_BIGQUERY_RUNS') | upper != 'TRUE' %}
    {{ exceptions.raise_compiler_error("BigQuery runs are disabled. Set ALLOW_BIGQUERY_RUNS=TRUE to execute queries.") }}
  {% endif %}

  {# Cheap no-op query so the hook is a valid operation when allowed #}
  {{ return('select 1') }}
{% endmacro %}
