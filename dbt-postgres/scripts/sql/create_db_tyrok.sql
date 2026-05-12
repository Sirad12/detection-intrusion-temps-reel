-- 1. Création de la base de données
-- Note : À exécuter en étant connecté à la base par défaut 'postgres'
CREATE DATABASE tyrok;

-- 2. Connexion à la nouvelle base de données
\c tyrok

-- 3. Création d'un schéma personnalisé
-- Il est recommandé de ne pas utiliser le schéma 'public' par défaut
CREATE SCHEMA IF NOT EXISTS bronze_schema;
CREATE SCHEMA IF NOT EXISTS silver_schema;
CREATE SCHEMA IF NOT EXISTS gold_schema;
CREATE SCHEMA IF NOT EXISTS operations;


-- 3. droits
-- Optional: Restore default permissions
GRANT ALL ON SCHEMA operations TO postgres_user;
GRANT ALL ON SCHEMA operations TO public;

GRANT ALL ON SCHEMA bronze_schema TO postgres_user;
GRANT ALL ON SCHEMA bronze_schema TO public;

GRANT ALL ON SCHEMA silver_schema TO postgres_user;
GRANT ALL ON SCHEMA silver_schema TO public;

GRANT ALL ON SCHEMA gold_schema TO postgres_user;
GRANT ALL ON SCHEMA gold_schema TO public;