-- COMPLEX QUERY 11
-- Carte de chaleur des ventes par zones géographiques (latitude et longitude arrondies) et catégorisation par valeur de vente

{{
    config(
        materialized='materialized_view',
        unique_key=['deliverer_name', 'sale_id'],
        incremental_strategy='delete+insert',
        indexes=[
          {'columns': ['deliverer_name', 'sale_id'], 'type': 'btree'},
          {'columns': ['deliverer_name', 'sale_id'], 'unique': True}
        ]
    )
}}


WITH base_data AS (
    SELECT 
        s.id AS sale_id,
        s.bill_code,
        s.total AS sale_amount,
        s.qte,
        s.create_at,
        d.name AS deliverer_name,
        d.code AS deliverer_code,
        -- Nettoyage des coordonnées
        s.latitude_delivery,
        s.longitude_delivery
    FROM {{ source('boutique_a_silver', 'silver_sales') }} s
    JOIN {{ source('boutique_a_silver', 'silver_deliverer') }} d ON s.deliverer_id = d.id
    WHERE s.status = TRUE 
      AND s.latitude_delivery IS NOT NULL 
      AND s.longitude_delivery IS NOT NULL
      AND s.latitude_delivery <> 0 -- Évite les erreurs de saisie à 0,0
)

SELECT 
    *,    
    -- Catégorisation pour la symbologie sur la carte
    CASE 
        WHEN sale_amount > 1000 THEN 'High Value'
        WHEN sale_amount > 500 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS sales_category
FROM base_data