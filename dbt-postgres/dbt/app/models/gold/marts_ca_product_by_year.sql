{{
    config(
        materialized='materialized_view',
        unique_key=['product_id', 'annee'],
        incremental_strategy='delete+insert',
        indexes=[
          {'columns': ['product_code', 'annee'], 'type': 'btree'},
          {'columns': ['product_code', 'annee'], 'unique': True}
        ]
    )
}}

WITH base_data AS (
    SELECT
        s.product_id as product_id,
        p.code as product_code,
        p.name as product_name,
        p.pu_price as pu_price,
    	EXTRACT(YEAR FROM s.create_at) as annee,
    	sum(s.total) as chiffre_affaires 
    FROM 
    	{{ source('boutique_a_silver', 'silver_sales') }} s
    JOIN {{ source('boutique_a_silver', 'silver_product') }} p ON p.id = s.product_id
    GROUP BY 1,2,3,4,5
    ORDER BY 6 desc
)

SELECT
    *
FROM base_data