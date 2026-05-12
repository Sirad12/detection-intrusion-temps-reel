-- COMPLEX QUERY 10
-- top livreurs par zones geogrphiques ayant plus de 2 livraisons dans une zone
{{
    config(
        materialized='materialized_view',
        unique_key=['livreur', 'zone_lat', 'zone_long'],
        incremental_strategy='delete+insert',
        indexes=[
          {'columns': ['livreur', 'zone_lat', 'zone_long'], 'type': 'btree'},
          {'columns': ['livreur', 'zone_lat', 'zone_long'], 'unique': True}
        ]
    )
}}


WITH base_data AS (
    SELECT 
        d.name AS livreur,
        ROUND(s.latitude_delivery::numeric, 2) AS zone_lat,
        ROUND(s.longitude_delivery::numeric, 2) AS zone_long,
        COUNT(s.id) AS nb_livraisons_zone
    FROM {{ source('boutique_a_silver', 'silver_sales') }} s
    JOIN {{ source('boutique_a_silver', 'silver_deliverer') }} d ON s.deliverer_id = d.id
    GROUP BY d.name, zone_lat, zone_long
    HAVING COUNT(s.id) > 1
    ORDER BY nb_livraisons_zone DESC
)
SELECT
    *
FROM base_data 