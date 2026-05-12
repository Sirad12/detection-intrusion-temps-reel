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
        id::INTEGER as id,
        client_id::INTEGER as client_id,
        product_id::INTEGER as product_id,
        deliverer_id::INTEGER as deliverer_id,
        bill_code::VARCHAR(50) as bill_code,
        qte::INTEGER as qte,
        total::DECIMAL(10, 2) as total,
        create_at::TIMESTAMP(6) as create_at,
        longitude_delivery::DECIMAL(10, 6) as longitude_delivery,
        latitude_delivery::DECIMAL(10, 6) as latitude_delivery,
        COALESCE(status, TRUE)::BOOLEAN as status,
        CAST(current_timestamp AS TIMESTAMP(6)) as ingested_at,
        'boutique_a' as source
    FROM {{ source('boutique_a_source', 'sales') }}
)

SELECT
    *
    -- Extraction des composants temporels
    -- EXTRACT(YEAR FROM ingested_at) as ingested_year,
    -- EXTRACT(MONTH FROM ingested_at) as ingested_month,
    -- EXTRACT(DAY FROM ingested_at)   as ingested_day,
    -- EXTRACT(HOUR FROM ingested_at)  as ingested_hour,
    -- EXTRACT(MINUTE FROM ingested_at) as ingested_minute
FROM base_data

{% if is_incremental() %}
  -- Optionnel : si vous voulez limiter la lecture source (date ou id: unique_key)
  -- WHERE source_date > (SELECT max(updated_at) FROM {{ this }})
  WHERE id > (SELECT max(id) FROM {{ this }})
{% endif %}


