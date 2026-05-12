{{
    config(
        materialized='materialized_view',
        unique_key=['annee', 'mois'],
        incremental_strategy='delete+insert',
        indexes=[
          {'columns': ['annee', 'mois'], 'type': 'btree'},
          {'columns': ['annee', 'mois', 'mois_clair'], 'unique': True}
        ]
    )
}}


WITH base_data AS (
    SELECT 
    	EXTRACT(YEAR FROM create_at) as annee,
    	EXTRACT(MONTH FROM create_at) as mois,
    	TO_CHAR(create_at, 'Month') AS mois_clair,
    	sum(total) as chiffre_affaires 
    FROM {{ source('boutique_a_silver', 'silver_sales') }}
    GROUP BY annee,mois,mois_clair
    ORDER BY mois
)
SELECT
    *
FROM base_data