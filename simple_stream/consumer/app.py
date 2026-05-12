import streamlit as st
from kafka import KafkaConsumer #pour lire les messages depuis Kafka
import json
import time
import pandas as pd
from collections import defaultdict #pour compter les tentatives par email
import threading #pour la lecture en arrière-plan 

# ── Configuration de la page 
st.set_page_config(
    page_title="IDS Dashboard",
    page_icon="🛡️",
    layout="wide"
)

st.title("Détection d'Intrusion en Temps Réel")
st.caption("Consumer — Lit depuis Kafka et détecte les attaques")
st.divider()

TOPIC          = "ids-connexions"
SEUIL_BRUTE    = 5   # X tentatives sur le même email → alerte Force Brute
FENETRE_TEMPS  = 30  # secondes # pour compter les tentatives (ex: 5 tentatives en 30s = alerte)

# ── Stockage partagé (session state) 
# On utilise `st.session_state` pour stocker les événements reçus, les alertes détectées, et les tentatives par email.
# Cela permet de conserver ces données même après un rafraîchissement de la page, et de les partager entre les différentes fonctions de l'application.

if "events"  not in st.session_state: st.session_state.events  = [] #liste de tous les messages reçus depuis Kafka
if "alertes" not in st.session_state: st.session_state.alertes = [] #liste des alertes détectées (ex: force brute ou normal)
if "running" not in st.session_state: st.session_state.running = False #indique si la lecture Kafka est en cours 
if "tentatives_par_email" not in st.session_state: #dictionnaire pour compter les tentatives par email, avec une liste de timestamps pour chaque email
    st.session_state.tentatives_par_email = defaultdict(list)
if "tentatives_par_ip" not in st.session_state:
    st.session_state.tentatives_par_ip = defaultdict(list)

# ── Fonction de détection 
def detecter(event):
    #on recupere l'email et l'heure actuelle
    email = event.get("email", "")
    ip =event.get("ip", "")
    now   = time.time() 

    # Nettoyer les anciennes tentatives 
    st.session_state.tentatives_par_email[email] = [
        t for t in st.session_state.tentatives_par_email[email]
        if now - t < FENETRE_TEMPS
    ]
    #Ajouter la tentative actuelle
    st.session_state.tentatives_par_email[email].append(now)

    #Compte le nbre de tentatives recentes pour cet email
    nb_email = len(st.session_state.tentatives_par_email[email])

    # Si le nombre de tentatives dépasse le seuil, on génère une alerte
    if nb_email >= SEUIL_BRUTE:
        return {
            "🚨 Type":   "FORCE BRUTE",
            "Email":     email,
            "IP":        event.get("ip", ""),
            "Détail":    f"{nb_email} tentatives en {FENETRE_TEMPS}s",
            "Heure":     event.get("heure", ""),
        }
    

    #Partie adresse ip
    st.session_state.tentatives_par_ip[ip] = [
        t for t in st.session_state.tentatives_par_ip[ip]
        if now - t < FENETRE_TEMPS
    ]
    st.session_state.tentatives_par_ip[ip].append(now)

    nb_ip = len(st.session_state.tentatives_par_ip[ip])

    if nb_ip >= SEUIL_BRUTE:
        return {
            "🚨 Type": "FORCE BRUTE (IP)",
            "Email": email,
            "IP": ip,
            "Détail": f"{nb_ip} tentatives IP en {FENETRE_TEMPS}s",
            "Heure": event.get("heure", "")
        }
    
    return None


# ── Lecture Kafka ─────────────────────────────────────────────────────────
def lire_kafka(nb_messages):
    consumer = KafkaConsumer(
        TOPIC,
        bootstrap_servers=["redpanda-0:9092"], #adresse du broker Kafka où consumer se connecte
        auto_offset_reset="earliest", #commence à lire depuis le début du topic
        group_id="ids-streamlit-group",  #identifiant du groupe de consommateurs (permet de partager la lecture entre plusieurs instances si besoin)
        value_deserializer=lambda d: json.loads(d.decode("utf-8")), #décoder les messages JSON reçus de Kafka
        consumer_timeout_ms=3000   # S'arrête après 3s sans message
    )

    count = 0
    # On lit les messages un par un, on les stocke dans `st.session_state.events`, et on applique la fonction de détection à chaque message pour générer des alertes si nécessaire.
    for msg in consumer:
        event = msg.value
        event["offset"] = msg.offset
        st.session_state.events.append(event)

        #Verifie si l'event declenche une alerte
        alerte = detecter(event)
        if alerte:
            st.session_state.alertes.append(alerte)
        
        count += 1
        if count >= nb_messages:
            break

    consumer.close()


# ── Interface ─────────────────────────────────────────────────────────────

# Boutons de contrôle
col1, col2, col3 = st.columns(3)

with col1:
    if st.button("🔄 Rafraîchir", use_container_width=True, type="primary"):
        lire_kafka(200) #lit jusqu'à 200 messages à la fois pour éviter de surcharger l'interface
        st.rerun()

with col2:
    st.caption(f"Auto-refresh : utilise le bouton ou recharge la page")

with col3:
    if st.button("🗑️ Vider tout", use_container_width=True):
        st.session_state.events  = []
        st.session_state.alertes = []
        st.session_state.tentatives_par_email = defaultdict(list)
        st.rerun()

st.divider()

# ── Compteurs ─────────────────────────────────────────────────────────────
events  = st.session_state.events
alertes = st.session_state.alertes

total    = len(events)
normaux  = sum(1 for e in events if e.get("type") == "normal")
brute    = sum(1 for e in events if e.get("type") == "force_brute")
nb_alrt  = len(alertes)

c1, c2, c3, c4 = st.columns(4)
c1.metric("📡 Total reçus",       total) 
c2.metric("✅ Connexions normales", normaux)
c3.metric("💀 Force Brute",        brute)
c4.metric("🚨 Alertes",            nb_alrt)

st.divider()

# ── Alertes ───────────────────────────────────────────────────────────────
st.subheader("🚨 Alertes détectées")

if not alertes:
    st.info("Aucune alerte pour l'instant — le système surveille...")
else:
    #Affiche les 10 dernieres alertes
    for a in reversed(alertes[-10:]):
        st.error(
            f"**{a['🚨 Type']}** | Email: `{a['Email']}` | IP: `{a['IP']}` | {a['Détail']} | {a['Heure']}"
        )

st.divider()

# ── Flux des événements ───────────────────────────────────────────────────
st.subheader("📋 Flux des connexions reçues")

if not events:
    st.info("En attente de messages... Clique sur 🔄 Rafraîchir")
else:
    # Construire un DataFrame simple
    rows = []
    # On affiche les 50 derniers événements, du plus récent au plus ancien
    for e in reversed(events[-50:]):
        rows.append({
            "Offset":    e.get("offset", ""),
            "Type":      e.get("type", ""), 
            "Email":     e.get("email", ""),
            "IP":        e.get("ip", ""),
            "Heure":     e.get("heure", ""),
            "Date":      e.get("date", ""),
        })

    df = pd.DataFrame(rows)
    st.dataframe(df, use_container_width=True, hide_index=True)