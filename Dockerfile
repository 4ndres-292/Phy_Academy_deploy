# --- Etapa 1: Backend deps ---
FROM python:3.11-slim AS backend

WORKDIR /app
COPY backend/requirements.txt ./
RUN python -m pip install --no-cache-dir -r requirements.txt

COPY backend/ ./backend/

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
COPY backend/ ./backend/

# Copia build de frontend al lugar donde Flask lo busca
COPY --from=frontend /app/dist ./frontend/dist

# Usa shell para expandir $PORT
CMD ["sh", "-c", "exec gunicorn --bind 0.0.0.0:${PORT} backend.app.main:app"]
