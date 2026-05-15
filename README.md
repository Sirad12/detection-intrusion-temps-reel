# 🛡️ Système de Détection d'Intrusion en Temps Réel

![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white)
![Kafka](https://img.shields.io/badge/Apache_Kafka-231F20?style=flat&logo=apachekafka&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white)
![Streamlit](https://img.shields.io/badge/Streamlit-FF4B4B?style=flat&logo=streamlit&logoColor=white)

> Système de surveillance réseau en temps réel capable de détecter des comportements suspects et de générer des alertes automatiques — visualisation live via un dashboard interactif.

---

## 🏗️ Architecture

```
Réseau ──► producer/app.py ──► Kafka ──► consumer/app.py ──► alertes automatiques
                                               └──► Dashboard Streamlit (temps réel)
```

---

## ✨ Fonctionnalités

- 🔍 Surveillance réseau en temps réel
- 🚨 Détection d'activités suspectes
- 📊 Dashboard interactif avec Streamlit
- 🐳 Entièrement conteneurisé avec Docker
- ⚡ Streaming via Apache Kafka

---

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

---

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

---

## 👩🏾‍💻 Auteure

**Ndeye Sira Dia** — Étudiante en Licence Informatique option Big Data  
Dakar Institute of Technology · Dakar, Sénégal

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0A66C2?style=flat&logo=linkedin&logoColor=white)](https://linkedin.com/in/sira-dia)
[![GitHub](https://img.shields.io/badge/GitHub-181717?style=flat&logo=github&logoColor=white)](https://github.com/Sirad12)

---

⭐ *"Les données racontent une histoire — mon rôle est de l'écouter."*
