from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta

from airflow.operators.python import ExternalPythonOperator
import sys
import os

## Assurez-vous que le dossier contenant f.py est dans le PYTHONPATH d'Airflow
#sys.path.append(os.path.abspath("/opt/airflow/dags/ia_code"))
#from ia_predict_deliverer_ca_vol import predict_deliverer_performance  # Remplacez par le nom de votre fonction dans f.py

def predict_deliverer_performance():
    import joblib
    from sqlalchemy import create_engine,types
    import pandas as pd
    from sklearn.ensemble import GradientBoostingRegressor
    from sklearn.multioutput import MultiOutputRegressor
    from sklearn.model_selection import train_test_split

    # 1. Extraction des données préparées par dbt
    engine = create_engine('postgresql://postgres_user:postgres@postgres:5432/tyrok')
    #conn = psycopg2.connect("dbname=d user=postgres password=pass host=localhost")
    df = pd.read_sql("SELECT * FROM ia_schema.ml_deliverer_perf_by_month", con=engine)

    # 2. Définition des Features (X) et des Cibles (y)
    # On utilise les données passées pour prédire le mois actuel
    X = df[['last_month_deliveries', 'last_month_ca', 'rolling_avg_ca']]
    y = df[['total_deliveries', 'monthly_ca']] 

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    # 3. Modèle Multi-Sorties (On prédit CA + Volume d'un coup)
    model = MultiOutputRegressor(GradientBoostingRegressor(n_estimators=300))
    model.fit(X_train, y_train)

    # 4. Simulation de prédiction pour le "Mois Prochain"
    # On prend les dernières données réelles connues de chaque livreur
    latest_data = df.sort_values('sales_month').groupby('deliverer_id').tail(1)
    X_next_month = latest_data[['total_deliveries', 'monthly_ca', 'rolling_avg_ca']].copy() # Le mois actuel devient le "last_month" du futur
    X_next_month.rename(columns={'total_deliveries': 'last_month_deliveries', 'monthly_ca': 'last_month_ca', 'rolling_avg_ca': 'rolling_avg_ca'}, inplace=True)

    predictions = model.predict(X_next_month)

    # 5. Résultat final
    results = pd.DataFrame({
        'deliverer_id': latest_data['deliverer_id'],
        'predicted_next_month_deliveries': predictions[:, 0].round(0),
        'predicted_next_month_ca': predictions[:, 1].round(2)
    })

    print(results.head())

    ## Sauvegarde pour usage futur
    #joblib.dump(model, '/delivery_predictor.pkl')

    # Optionnel : Renvoyer vers Postgres pour affichage sur Map/Dashboard
    results.to_sql(
        name='pred_deliverer_next_month', 
        con=engine, 
        schema='ia_schema', 
        if_exists='replace', 
        index=False,
        dtype={
            'deliverer_id': types.Integer(),
            'predicted_next_month_deliveries': types.Integer(),
            'predicted_next_month_ca': types.Float()
        }
    )



# Chemin vers l'exécutable dbt dans l'env virtuel
DBT_BIN = "/opt/mes_env/.env/bin/dbt"

default_args = {
    'owner': 'L2_team',
    'depends_on_past': False,
    'start_date': datetime(2026, 1, 1),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    'dbt_postgres_pipeline',
    default_args=default_args,
    schedule_interval='*/5 * * * *', # Exécution toutes 5 minutes
    catchup=False
) as dag:

    # 1. On lance l'ingestion des tables raw ou bronze (Client, Product, Deliverer, Sales)
    run_base_models = BashOperator(
        task_id='dbt_run_base',
        bash_command=f"cd /usr/app && {DBT_BIN} run --select bronze -t dev-bronze"
    )

    # 2. On lance les silver (qui dépendent des bases)
    run_silver_models = BashOperator(
        task_id='dbt_run_silver',
        bash_command=f"cd /usr/app && {DBT_BIN} run --select silver -t dev-silver"
    )
    
    # 3-1. On lance les facts (qui dépendent des silver)
    run_fact_models = BashOperator(
        task_id='dbt_run_fact_gold',
        bash_command=f"cd /usr/app && {DBT_BIN} run --select gold -t dev-gold"
    )
    
    # 3-2. On lance les marts (qui dépendent des silver)
    run_marts_models = BashOperator(
        task_id='dbt_run_marts',
        bash_command=f"cd /usr/app && {DBT_BIN} run --select marts -t dev-gold"
    )
    
    # 4. Nettoyage
    run_clean = BashOperator(
        task_id='dbt_clean',
        bash_command=f"cd /usr/app && {DBT_BIN} clean"
    )
    
    # run ai prepare features task
    run_ml_features_models = BashOperator(
        task_id='dbt_run_ml_features',
        bash_command=f"cd /usr/app && {DBT_BIN} run --select ml_deliverer_perf_by_month -t dev-ia"
    )
    
    ## run AI Prediction Task
    #run_ml_predict = ExternalPythonOperator(
    #    task_id='run_ml_predict',
    #    python='/opt/mes_env/.env/bin/python',
    #    python_callable=predict_deliverer_performance
    #)
    
    # run AI Prediction Task
    run_ml_predict = ExternalPythonOperator(
        task_id='run_ml_predict',
        python='/opt/mes_env/.env/bin/python',
        python_callable=predict_deliverer_performance
    )
    
    # run ai adding columns to predict table
    run_ml_predict_models = BashOperator(
        task_id='run_ml_predict_models',
        bash_command=f"cd /usr/app && {DBT_BIN} run --select ia_pred_deliver_next_month -t dev-ia"
    )

    
    
    run_base_models >> run_silver_models >> [run_fact_models, run_marts_models]
    [run_fact_models, run_marts_models] >> run_clean
    [run_fact_models, run_marts_models] >> run_ml_features_models >> run_ml_predict >> run_ml_predict_models
    
    
    
    
    
    
