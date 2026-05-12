-- COMPLEX QUERY 11
-- Carte de chaleur des ventes par zones géographiques (latitude et longitude arrondies) et catégorisation par valeur de vente

{{
    config(
        materialized='view',
        unique_key=['deliverer_id'],
        incremental_strategy='delete+insert',
        indexes=[
          {'columns': ['deliverer_id'], 'type': 'btree'},
          {'columns': ['deliverer_id'], 'unique': True}
        ]
    )
}}


WITH base_data AS (
    SELECT 
        p.deliverer_id AS deliverer_id,
        d.name AS deliverer_name,
        d.code AS deliverer_code,
        p.predicted_next_month_deliveries as predicted_next_month_deliveries,
        p.predicted_next_month_ca as predicted_next_month_ca
    FROM {{ source('boutique_a_ia', 'pred_deliverer_next_month') }} p
    JOIN {{ source('boutique_a_silver', 'silver_deliverer') }} d ON p.deliverer_id = d.id
)

SELECT 
    *
FROM base_data