# my Dockerfile
FROM apache/airflow:2.11.2-python3.10


USER root

# 1. Installation de git & curl
RUN apt-get update && \
    apt-get install -y --no-install-recommends git curl && \
    apt-get autoremove -yqq --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Création du dossier et gestion des permissions pour l'utilisateur airflow
RUN mkdir -p /opt/mes_env && chown -R airflow: /opt/mes_env

USER airflow

WORKDIR /usr/app
COPY requirements.txt .
RUN pip install --upgrade pip
#RUN pip install --no-cache-dir -r requirements.txt

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
# 2. Utiliser la variable officielle dbt pour forcer psycopg2 (source) au lieu de binary
ENV DBT_PSYCOPG2_NAME=psycopg2

## Création de l'env virtuel et installation de dbt-postgres
#RUN python -m venv /opt/mes_env/.env && \
#    /opt/mes_env/.env/bin/pip install --upgrade pip && \
#    /opt/mes_env/.env/bin/pip install --no-cache-dir "dbt-postgres>=1.7.19"

# Création de l'env virtuel et installation de dbt-postgres + requirements.txt
RUN python -m venv /opt/mes_env/.env && \
    /opt/mes_env/.env/bin/pip install --upgrade pip && \
    /opt/mes_env/.env/bin/pip install --no-cache-dir "dbt-postgres>=1.7.19" && \
    /opt/mes_env/.env/bin/pip install --no-cache-dir -r requirements.txt

# Vérification (optionnel)
RUN /opt/mes_env/.env/bin/pip show psycopg2-binary