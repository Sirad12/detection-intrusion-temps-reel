FROM python:3.12-slim
WORKDIR /app 
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py . 
EXPOSE 4000


CMD ["streamlit", "run", "app.py", "--server.port=4000", "--server.address=0.0.0.0"]