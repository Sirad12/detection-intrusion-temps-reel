#!/bin/bash

set -e # Arrête le script en cas d'erreur

echo "----------------------------------------------------"
echo "🚀 INITIALISATION DU SCRIPT DE CREATION DES BDS"
echo "----------------------------------------------------"

# 0. SUPPRESSION DES BASES DE DONNÉES (SQL)
echo "⏳ 0. SUPPRESSION DES BASES DE DONNÉES (SQL)..."

# Boutique A : Postgres
echo "⏳ Suppression Boutique A ..."
psql -h postgres -U postgres_user -d postgres_db < /sql/delete_db_source.sql

## Boutique B : Postgres
#echo "⏳ Suppression Boutique B ..."
#psql -h postgres -U postgres_user -d postgres_db < /sql/delete_db_source.sql

# tyrok : Postgres
echo "⏳ Suppression tyrok destination ..."
psql -h postgres -U postgres_user -d postgres_db < /sql/delete_db_tyrok.sql


# 1. INITIALISATION DES BASES DE DONNÉES (SQL)
echo "⏳ 1. CREATION DES BASES DE DONNÉES (SQL)..."

# Boutique A : Postgres
echo "⏳ creation bd [tyrok] Boutique A ..."
psql -h postgres -U postgres_user -d postgres_db < /sql/create_db_source.sql

# Tyrok : Postgres
echo "⏳ creation bd [tyrok] Tyrok ..."
psql -h postgres -U postgres_user -d postgres_db < /sql/create_db_tyrok.sql


# 2. INITIALISATION DES TABLES DE DONNÉES SOURCES (SQL)
echo "⏳ 2. INITIALISATION DES TABLES DE DONNÉES SOURCES (SQL)..."

# Boutique A : Postgres
echo "⏳ creation [deliverer] Boutique A ..."
psql -h postgres -U postgres_user -d tyrok < /sql/create_deliverer.sql

echo "⏳ creation [client] Boutique A ..."
psql -h postgres -U postgres_user -d tyrok < /sql/create_client.sql

echo "⏳ creation [product] Boutique A ..."
psql -h postgres -U postgres_user -d tyrok < /sql/create_product.sql

echo "⏳ creation [sales] Boutique A ..."
psql -h postgres -U postgres_user -d tyrok < /sql/create_sales.sql


# 3. ADDING SOME DATA SOURCES (SQL)
echo "⏳ 3. ADDING SOME DATA SOURCES (SQL)..."
psql -h postgres -U postgres_user -d tyrok < /sql/seeds_client_product_deliverer_1.sql
psql -h postgres -U postgres_user -d tyrok < /sql/seeds_sales_2.sql
psql -h postgres -U postgres_user -d tyrok < /sql/seeds_sales_3.sql
psql -h postgres -U postgres_user -d tyrok < /sql/seeds_sales_4.sql


echo -e "\n🔥 DONE!!!"

