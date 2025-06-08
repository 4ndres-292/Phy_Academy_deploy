# --- Etapa 1: Backend deps ---
FROM python:3.11-slim AS backend

WORKDIR /app
COPY backend/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY backend/ ./backend/

# --- Etapa 2: Frontend build ---
FROM node:20 AS frontend

WORKDIR /app
COPY frontend/package.json frontend/package-lock.json* ./
RUN npm install
COPY frontend/ ./
RUN npm run build

# --- Etapa final ---
FROM python:3.11-slim

WORKDIR /app
# Copia deps y código backend
COPY --from=backend /usr/local/lib/python3.11 /usr/local/lib/python3.11
COPY --from=backend /usr/local/bin /usr/local/bin
COPY backend/ ./backend/

# Copia la carpeta dist del frontend al lugar donde Flask la sirve
COPY --from=frontend /app/dist ./frontend/dist

# (al final de tu Dockerfile)
EXPOSE 8080

# Usa un shell para expandir la variable $PORT que define Railway
CMD ["sh", "-c", "gunicorn --bind 0.0.0.0:${PORT:-8080} backend.app.main:app"]
