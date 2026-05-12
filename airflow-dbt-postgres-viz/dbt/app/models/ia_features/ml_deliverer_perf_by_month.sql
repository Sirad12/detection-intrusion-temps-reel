{{
    config(
        materialized='materialized_view',
        unique_key=['deliverer_name', 'sales_month'],
        incremental_strategy='delete+insert',
        indexes=[
          {'columns': ['deliverer_name', 'sales_month'], 'type': 'btree'},
          {'columns': ['deliverer_name', 'sales_month'], 'unique': True}
        ]
    )
}}

WITH monthly_stats AS (
    SELECT 
        s.deliverer_id,
        d.name AS deliverer_name,
        DATE_TRUNC('month', s.create_at) AS sales_month,
        COUNT(s.id) AS total_deliveries,
        SUM(s.total) AS monthly_ca,
        AVG(s.total) AS avg_ticket
    FROM {{ source('boutique_a_silver', 'silver_sales') }} s
    JOIN {{ source('boutique_a_silver', 'silver_deliverer') }} d ON s.deliverer_id = d.id
    WHERE s.status = TRUE
    GROUP BY 1, 2, 3
),
features AS (
    SELECT 
        deliverer_id,
        deliverer_name,
        sales_month,
        total_deliveries,
        monthly_ca,
        -- Lag features : On donne à l'IA les perfs du mois précédent (M-1)
        LAG(total_deliveries) OVER(PARTITION BY deliverer_id ORDER BY sales_month) AS last_month_deliveries,
        LAG(monthly_ca) OVER(PARTITION BY deliverer_id ORDER BY sales_month) AS last_month_ca,
        -- Moyenne glissante sur 3 mois pour capter la tendance
        AVG(monthly_ca) OVER(PARTITION BY deliverer_id ORDER BY sales_month ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING) AS rolling_avg_ca
    FROM monthly_stats
)
SELECT * FROM features WHERE last_month_ca IS NOT NULL
