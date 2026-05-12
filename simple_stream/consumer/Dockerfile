#L'image de python
FROM python:3.12-slim 

#Le répertoire de travail dans le conteneur
WORKDIR /app

COPY requirements.txt .

#On installe les dépendances nécessaires pour faire tourner l'application Streamlit et Kafka Consumer
RUN pip install --no-cache-dir -r requirements.txt
#On copie le code de l'application dans le conteneur
COPY app.py .
#On expose le port 4004 pour accéder à l'application Streamlit depuis l'extérieur du conteneur
EXPOSE 4004
#On définit la commande pour lancer l'application Streamlit, en spécifiant le port et l'adresse d'écoute
CMD ["streamlit", "run", "app.py", "--server.port=4004", "--server.address=0.0.0.0"]