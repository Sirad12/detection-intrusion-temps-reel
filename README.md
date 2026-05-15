# 🔐 Système de détection d'intrusion en temps réel

## 📌 Description
Système de surveillance réseau en temps réel permettant de détecter 
les activités suspectes et de générer des alertes automatiques.

## 🛠️ Technologies utilisées
- **Python** — Langage principal
- **Streamlit** — Interface du dashboard
- **Kafka** — Streaming de données en temps réel
- **Docker** — Conteneurisation

## 🚀 Démarrage rapide

```bash
# 1. Cloner le repo
git clone https://github.com/Sirad12/detection-intrusion-temps-reel.git
cd detection-intrusion-temps-reel/simple_stream

# 2. Lancer tous les services
docker compose up --build -d

# 3. Accéder au dashboard
# Dashboard → http://localhost:8501
```

## 📁 Structure du projet

```
detection-intrusion-temps-reel/
└── simple_stream/
    ├── consumer/
    │   ├── app.py              # Détection d'anomalies + Dashboard Streamlit
    │   ├── Dockerfile
    │   └── requirements.txt
    ├── producer/
    │   ├── app.py              # Génération du trafic réseau → Kafka
    │   ├── Dockerfile
    │   └── requirements.txt
    ├── compose.yml             # Orchestration des services
    ├── compose.override.yml    # Configuration override
    └── config.yml              # Configuration générale
```

## ✨ Fonctionnalités
- Surveillance réseau en temps réel
- Détection d'activités suspectes
- Dashboard interactif
- Génération d'alertes automatiques

## 👩🏾‍💻 Auteure
**Ndeye Sira Dia** — Étudiante en Licence Informatique option Big Data  
Dakar Institute of Technology  

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0A66C2?style=flat&logo=linkedin&logoColor=white)](https://linkedin.com/in/sira-dia)
[![GitHub](https://img.shields.io/badge/GitHub-181717?style=flat&logo=github&logoColor=white)](https://github.com/Sirad12)

