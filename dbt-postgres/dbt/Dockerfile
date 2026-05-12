FROM python:3.11-slim
WORKDIR /usr/app
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl libpq-dev python3-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Utiliser la variable officielle dbt pour forcer psycopg2 (source) au lieu de binary
ENV DBT_PSYCOPG2_NAME=psycopg2

# 3. Installer dbt-postgres (il installera psycopg2 automatiquement grâce à l'ENV ci-dessus)
RUN pip install --upgrade pip
RUN pip install --no-cache-dir "dbt-postgres>=1.7.19"

# Vérification (optionnel)
#RUN pip show psycopg2 && ! pip show psycopg2-binary
RUN pip show psycopg2-binary
