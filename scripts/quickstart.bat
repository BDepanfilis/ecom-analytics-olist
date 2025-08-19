@echo off
setlocal
REM Compile-only 
set ALLOW_BIGQUERY_RUNS=FALSE
dbt deps
dbt compile --selector ci --no-partial-parse --fail-fast
echo Done (compile-only).
