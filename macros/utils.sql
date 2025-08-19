-- macros/utils.sql

{% macro nullif_blank(expr) -%}
    nullif(trim({{ expr }}), '')
{%- endmacro %}

{% macro safe_int(expr) -%}
    safe_cast({{ expr }} as int64)
{%- endmacro %}

{% macro safe_float(expr) -%}
    safe_cast({{ expr }} as float64)
{%- endmacro %}

{% macro safe_date(expr) -%}
    safe_cast({{ expr }} as date)
{%- endmacro %}

{% macro safe_timestamp(expr) -%}
    safe_cast({{ expr }} as timestamp)
{%- endmacro %}

{% macro date_key(date_expr) -%}
    -- Returns YYYYMMDD as INT64, e.g., 20250131
    cast(format_date('%Y%m%d', {{ date_expr }}) as int64)
{%- endmacro %}

{% macro epoch_ms_to_timestamp(ms_expr) -%}
    -- Milliseconds since epoch to TIMESTAMP
    timestamp_millis({{ safe_int(ms_expr) }})
{%- endmacro %}

{% macro normalize_string(expr) -%}
    -- Lowercase + trim; add more cleanup as needed
    trim(lower({{ expr }}))
{%- endmacro %}

{% macro coalesce_zero(expr) -%}
    coalesce({{ expr }}, 0)
{%- endmacro %}

{% macro nullif_zero(expr) -%}
    nullif({{ expr }}, 0)
{%- endmacro %}

{% macro env_bool(var_name, default=false) -%}
    {{ return( (env_var(var_name, default|string) | lower) in ['1', 'true', 't', 'yes', 'y'] ) }}
{%- endmacro %}
