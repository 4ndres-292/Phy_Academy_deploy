# --- Etapa 1: Backend deps ---
FROM python:3.11-slim AS backend

WORKDIR /app
COPY backend/requirements.txt .
RUN python -m pip install --no-cache-dir -r requirements.txt

COPY backend/ ./backend/

# Define la variable FLASK_APP con la ruta a tu aplicación flask.
# Ajusta según tu estructura real, aquí asumo que tienes backend/app/main.py y app está definido allí.
ENV FLASK_APP=backend.app.main:app

# Define también el entorno para que flask use el modo de producción
ENV FLASK_ENV=production

# Ejecuta la migración
RUN flask db init
RUN flask db -m "primera migracion"
RUN flask db upgrade

# --- Etapa 2: Frontend build ---
FROM node:20 AS frontend

WORKDIR /app
COPY frontend/package*.json ./
RUN npm install
COPY frontend/ ./
RUN npm run build

# --- Etapa final ---
FROM python:3.11-slim

WORKDIR /app

# Variables y puerto
ENV PORT=8080
EXPOSE 8080

# Copia deps y código backend
COPY --from=backend /usr/local/lib/python3.11 /usr/local/lib/python3.11
COPY --from=backend /usr/local/bin /usr/local/bin
COPY --from=backend /app/backend ./backend

# Copia build del frontend (la carpeta dist)
COPY --from=frontend /app/dist ./frontend/dist

# Comando para arrancar el servidor
CMD ["sh", "-c", "exec gunicorn --bind 0.0.0.0:${PORT} backend.app.main:app"]
