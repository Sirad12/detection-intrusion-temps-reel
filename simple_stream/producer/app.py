import streamlit as st
from kafka import KafkaProducer
import json
import datetime
import hashlib 

# ── Configuration de la page ──────────────────────────────────────────────
st.set_page_config(
    page_title="Portail de Connexion",
    page_icon="🔐",
    layout="centered"
)

st.title("🔐 Portail de Connexion")
st.caption("Producer — Les tentatives sont envoyées dans Kafka")
st.divider()

# ── Connexion à Kafka 
@st.cache_resource #indique a streamlit de creer le producer une seule fois au demarrage et de le reutiliser 
def get_producer():
    return KafkaProducer(
        bootstrap_servers=["redpanda-0:9092"], #l'adresse du broker kafka
        value_serializer=lambda msg: json.dumps(msg).encode("utf-8") #pour encoder les messages en JSON avant de les envoyer à Kafka
    )

#on cree le prducer kafka
producer = get_producer()
TOPIC = "ids-connexions" #le nom de mon topic kafka

# ── Formulaire de connexion 
st.subheader("Tentative normale")

#on cree trois champs de saisie
email = st.text_input("Email", placeholder="utilisateur@example.sn")
mdp   = st.text_input("Mot de passe", type="password", placeholder="••••••••")
ip    = st.text_input("Adresse IP (simulée)", value="196.1.100.5")


if st.button("→ Envoyer dans Kafka", type="primary", use_container_width=True):
    #Si le mdp ou l'email est vide un message d'erreur est affiche
    if not email or not mdp:
        st.error("Remplis email et mot de passe !")
    else:
        #Hachage du mdp avant l'envoi
        mdp_hache = hashlib.sha256(mdp.encode()).hexdigest()  

        message = {
            "email":  email,
            "token":   mdp_hache,
            "ip":    ip,
            "type":  "normal",
            "heure":   datetime.datetime.now().strftime("%H:%M:%S"),
            "date":   datetime.datetime.now().strftime("%d/%m/%Y"),
            "timestamp": datetime.datetime.now().timestamp(), 
        }
        #on envoie le message dans kafka
        future = producer.send(TOPIC, value=message)
        #on force l'envoie immediat sans ca kafka va attendre d'avoir beaucoup de messages pour les envoyer en lot
        producer.flush()
        #temps d'attente max=10s
        record = future.get(timeout=10)
        st.success(f"✅ Message envoyé ! Topic: {TOPIC} | Offset: {record.offset}")

st.divider() #une ligne de separation

# ── Simulation d'attaque Force Brute ─────────────────────────────────────
st.subheader("💀 Simuler une attaque Force Brute")
st.caption("Même email, beaucoup de tentatives → déclenche une alerte côté Consumer")

#les champs pour configurer l'attaque
email_brute = st.text_input("Email ciblé", value="admin@gov.sn")
ip_brute = st.text_input("IP de l'attaquant", value="41.82.1.12")
nb = st.slider("Nombre de tentatives", min_value=10, max_value=100, value=20)

if st.button("💀 Lancer l'attaque", type="secondary", use_container_width=True):
    #la liste de mdp courants que l'attaquant va use
    mots_de_passe = ["123456", "password", "admin", "qwerty", "dakar2024", "pass123", "root", "azerty"]
    barre = st.progress(0, text="Envoi en cours...")

    #on simule plusieurs tentatives de connexion
    for i in range(nb):
        test_mdp = mots_de_passe[i % len(mots_de_passe)] #pour faire tourner les mdp
        #on hache aussi chaque tentative de l'attaquant
        test_mdp_hache = hashlib.sha256(test_mdp.encode()).hexdigest()

        message = {
            "email": email_brute,
            "token": test_mdp_hache,
            "ip": ip_brute,
            "type": "force_brute",
            "tentative": i + 1,
            "heure":datetime.datetime.now().strftime("%H:%M:%S"),
            "date": datetime.datetime.now().strftime("%d/%m/%Y"),
            "timestamp": datetime.datetime.now().timestamp(),
        }
        producer.send(TOPIC, value=message)
        barre.progress((i + 1) / nb, text=f"Tentative {i+1}/{nb}")

    producer.flush()
    st.error(f"💀 {nb} tentatives envoyées pour {email_brute} depuis {ip_brute}")