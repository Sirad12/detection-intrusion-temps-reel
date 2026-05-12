-- merge: insert new records and update existing
-- delete+insert

{{ config(
    materialized='incremental',
    unique_key='id',
    incremental_strategy='merge',
    indexes=[
      {'columns': ['id'], 'type': 'hash'},
      {'columns': ['id','bill_code'], 'unique': True}
    ]
) }}


WITH base_data AS (
    SELECT
        *,
        EXTRACT(EPOCH FROM (ingested_at - create_at)) AS delta_ingestion_secondes
    FROM {{ source('boutique_a_raw', 'raw_sales') }}
)

SELECT
    *
FROM base_data

{% if is_incremental() %}
  -- Optionnel : si vous voulez limiter la lecture source (date ou id: unique_key)
  -- WHERE source_date > (SELECT max(updated_at) FROM {{ this }})
  WHERE id > (SELECT max(id) FROM {{ this }})
{% endif %}


