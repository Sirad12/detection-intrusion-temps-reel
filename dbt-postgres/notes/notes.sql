-- SIMPLE QUERY

select count(*) from operations.client;
select * from operations.client limit 2;

select count(*) from operations.deliverer;
select * from operations.deliverer limit 2;

select count(*) from operations.sales;
select * from operations.sales limit 2;
select * from operations.sales where deliverer_id=8 order by create_at desc limit 1;

-- COMPLEX QUERY 1

SELECT 
	EXTRACT(YEAR FROM create_at) as annee,
	EXTRACT(MONTH FROM create_at) as mois,
	TO_CHAR(create_at, 'Month') AS mois_clair,
	sum(total) as chiffre_affaires 
FROM 
	operations.sales 
GROUP BY annee,mois,mois_clair
ORDER BY mois;

-- COMPLEX QUERY 2

SELECT
    s.client_id,
    c.code as client_code,
    c.name as client_name,
    c.gender as client_gender,
	EXTRACT(YEAR FROM s.create_at) as annee,
	sum(s.total) as chiffre_affaires 
FROM 
	operations.sales s
JOIN operations.client c ON c.id = s.client_id
GROUP BY 1,2,3,4,5
ORDER BY 6 desc;

-- COMPLEX QUERY 3

SELECT
    s.product_id,
    p.code as product_code,
    p.name as product_name,
    p.pu_price as pu_price,
	EXTRACT(YEAR FROM s.create_at) as annee,
	sum(s.total) as chiffre_affaires 
FROM 
	operations.sales s
JOIN operations.product p ON p.id = s.product_id
GROUP BY 1,2,3,4,5
ORDER BY 6 desc;

-- SOME BASICS SQL (NULLIF)
-- NULLIF: 
--  https://neon.com/postgresql/postgresql-tutorial/postgresql-nullif
--  The NULLIF function returns a null value if arg_1 equals to arg_2, otherwise, it returns arg_1.

select NULLIF(-1,1); -- return -1 (-1 diff 1)
select NULLIF(1,1); -- return null (1 equal 1)

-- SOME BASICS SQL (LAG)
-- LAG:
--  https://neon.com/postgresql/postgresql-window-function/postgresql-lag-function
--  access data of the previous row from the current row.
-- val1 progress de x% pour donner val2 => x = ((val2 / val1) - 1) * 100

WITH historique_ventes AS (
    SELECT
        EXTRACT(MONTH FROM create_at) as mois,
    	TO_CHAR(create_at, 'Month') AS mois_clair,
        sum(total) as chiffre_affaires
    FROM
        operations.sales
    GROUP BY 1,2
    ORDER BY mois
)
SELECT
    mois, 
    mois_clair,
    chiffre_affaires,
    LAG(chiffre_affaires) OVER (ORDER BY mois) AS CA_annee_prec
FROM historique_ventes
ORDER BY mois;

-- COMPLEX QUERY 4
-- Comparaison de croissance (MoM - Month over Month)
-- Cette requête compare le chiffre d'affaires du mois actuel avec celui du mois précédent pour chaque client, en utilisant LAG().

SELECT 
    c.name AS client_nom,
    TO_CHAR(DATE_TRUNC('month', s.create_at), 'Mon YYYY') AS mois,
    SUM(s.total) AS CA_actuel,
    LAG(SUM(s.total)) OVER (PARTITION BY c.id ORDER BY DATE_TRUNC('month', s.create_at)) AS CA_mois_precedent,
    ROUND(
        ((SUM(s.total) / NULLIF(LAG(SUM(s.total)) OVER (PARTITION BY c.id ORDER BY DATE_TRUNC('month', s.create_at)), 0)) - 1) * 100, 
        2
    ) AS pourcentage_croissance
FROM operations.sales s
JOIN operations.client c ON s.client_id = c.id
GROUP BY c.id, c.name, DATE_TRUNC('month', s.create_at)
ORDER BY c.name, DATE_TRUNC('month', s.create_at);

-- COMPLEX QUERY 5
-- Comparaison de croissance (MoM - Month over Month)
-- Cette requête compare le chiffre d'affaires du mois actuel avec celui du mois précédent pour chaque produit, en utilisant LAG().

SELECT 
    p.name AS product_nom,
    TO_CHAR(DATE_TRUNC('month', s.create_at), 'Mon YYYY') AS mois,
    SUM(s.total) AS CA_actuel,
    LAG(SUM(s.total)) OVER (PARTITION BY p.id ORDER BY DATE_TRUNC('month', s.create_at)) AS CA_mois_precedent,
    ROUND(
        ((SUM(s.total) / NULLIF(LAG(SUM(s.total)) OVER (PARTITION BY p.id ORDER BY DATE_TRUNC('month', s.create_at)), 0)) - 1) * 100, 
        2
    ) AS pourcentage_croissance
FROM operations.sales s
JOIN operations.product p ON s.product_id = p.id
GROUP BY p.id, p.name, DATE_TRUNC('month', s.create_at)
ORDER BY p.name, DATE_TRUNC('month', s.create_at);

-- COMPLEX QUERY 6
-- Classement des livreurs apres premiers mois d'activité
SELECT 
    d.name AS livreur,
    TO_CHAR(d.create_at, 'DD/MM/YYYY') AS inscrit_le,
    COUNT(s.id) AS commandes_premier_mois,
    SUM(s.total) AS CA_genere
FROM operations.deliverer d
JOIN operations.sales s ON s.deliverer_id = d.id
WHERE s.create_at <= d.create_at + INTERVAL '1 month'
GROUP BY d.id, d.name, d.create_at
ORDER BY commandes_premier_mois DESC;

-- COMPLEX QUERY 7
-- Performance mensuelle de chaque livreur et part de marché mensuelle (comparée au CA total du mois)
SELECT 
    TO_CHAR(DATE_TRUNC('month', s.create_at), 'Mon YYYY') AS mois,
    d.name AS livreur,
    COUNT(s.id) AS nb_livraisons,
    SUM(s.total) AS total_livre,
    ROUND(
        (SUM(s.total) / SUM(SUM(s.total)) OVER (PARTITION BY DATE_TRUNC('month', s.create_at))) * 100, 
        2
    ) AS pourcentage_du_mois
FROM operations.sales s
JOIN operations.deliverer d ON s.deliverer_id = d.id
GROUP BY DATE_TRUNC('month', s.create_at), d.id, d.name
ORDER BY DATE_TRUNC('month', s.create_at) DESC, total_livre DESC;

-- COMPLEX QUERY 8
-- Periodes creuses (jours de semaines et tranches hosraires les plsu denses pour les livreurs)
-- DATE_PART('dow', s.create_at) :
--  0 (dimanche) à 6 (samedi) [extract a subfield from a date or time value.]
--  https://neon.com/postgresql/postgresql-date-functions/postgresql-date_part
-- use HEATMAP
SELECT 
    d.name AS livreur,
    TO_CHAR(s.create_at, 'Day') AS jour_semaine,
    DATE_PART('hour', s.create_at) AS heure,
    COUNT(s.id) AS nb_commandes
FROM operations.sales s
JOIN operations.deliverer d ON s.deliverer_id = d.id
WHERE s.create_at > CURRENT_DATE - INTERVAL '3 months'
GROUP BY d.name, jour_semaine, heure, DATE_PART('dow', s.create_at)
ORDER BY d.name, DATE_PART('dow', s.create_at), heure;

-- COMPLEX QUERY 9
-- livreurs inactifs plus de 30 jours (changer à 5 pour observer)
SELECT 
    d.name,
    d.code,
    MAX(s.create_at) AS derniere_livraison,
    CURRENT_DATE - MAX(s.create_at)::date AS jours_inactivite
FROM operations.deliverer d
LEFT JOIN operations.sales s ON d.id = s.deliverer_id
GROUP BY d.id, d.name, d.code
HAVING MAX(s.create_at) < CURRENT_DATE - INTERVAL '30 days' 
   OR MAX(s.create_at) IS NULL
ORDER BY jours_inactivite DESC NULLS FIRST;


-- COMPLEX QUERY 10
-- top livreurs par zones geogrphiques ayant plus de 10 livraisons dans une zone
SELECT 
    d.name AS livreur,
    ROUND(s.latitude_delivery::numeric, 2) AS zone_lat,
    ROUND(s.longitude_delivery::numeric, 2) AS zone_long,
    COUNT(s.id) AS nb_livraisons_zone
FROM operations.sales s
JOIN operations.deliverer d ON s.deliverer_id = d.id
GROUP BY d.name, zone_lat, zone_long
HAVING COUNT(s.id) > 10
ORDER BY nb_livraisons_zone DESC;






