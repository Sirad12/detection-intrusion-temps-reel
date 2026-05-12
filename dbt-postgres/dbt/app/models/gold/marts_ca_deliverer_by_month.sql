{{
    config(
        materialized='materialized_view',
        unique_key=['livreur', 'mois'],
        incremental_strategy='delete+insert',
        indexes=[
          {'columns': ['livreur', 'mois'], 'type': 'btree'},
          {'columns': ['livreur', 'mois'], 'unique': True}
        ]
    )
}}

WITH base_data AS (
    SELECT 
        TO_CHAR(DATE_TRUNC('month', s.create_at), 'Mon YYYY') AS mois,
        d.name AS livreur,
        COUNT(s.id) AS nb_livraisons,
        SUM(s.total) AS total_livre,
        ROUND(
            (SUM(s.total) / SUM(SUM(s.total)) OVER (PARTITION BY DATE_TRUNC('month', s.create_at))) * 100, 
            2
        ) AS pourcentage_du_mois
    FROM {{ source('boutique_a_silver', 'silver_sales') }} s
    JOIN {{ source('boutique_a_silver', 'silver_deliverer') }} d ON s.deliverer_id = d.id
    GROUP BY DATE_TRUNC('month', s.create_at), d.id, d.name
    ORDER BY DATE_TRUNC('month', s.create_at) DESC, total_livre DESC
)
SELECT
    *
FROM base_data