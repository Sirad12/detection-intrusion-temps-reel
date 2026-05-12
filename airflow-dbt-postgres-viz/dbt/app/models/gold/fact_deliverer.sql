-- merge: insert new records and update existing
-- delete+insert

{{ config(
    materialized='incremental',
    unique_key='id',
    incremental_strategy='merge',
    indexes=[
      {'columns': ['id'], 'type': 'hash'},
      {'columns': ['id','code'], 'unique': True}
    ]
) }}


WITH base_data AS (
    SELECT
        *
    FROM {{ source('boutique_a_silver', 'silver_deliverer') }}
)

SELECT
    *
FROM base_data

{% if is_incremental() %}
  -- Optionnel : si vous voulez limiter la lecture source (date ou id: unique_key)
  -- WHERE source_date > (SELECT max(updated_at) FROM {{ this }})
  WHERE id > (SELECT max(id) FROM {{ this }})
{% endif %}


