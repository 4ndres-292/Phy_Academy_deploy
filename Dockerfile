# --- Etapa 1: Backend deps ---
FROM python:3.11-slim AS backend

WORKDIR /app
COPY backend/requirements.txt .
RUN python -m pip install --no-cache-dir -r requirements.txt

COPY backend /app/backend
COPY backend/migrations /app/migrations


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

ENV PORT=8080
EXPOSE 8080

# 1) Copia las librerías instaladas
COPY --from=backend /usr/local/lib/python3.11 /usr/local/lib/python3.11
COPY --from=backend /usr/local/bin /usr/local/bin

# 2) Copia el código de tu app
COPY --from=backend /app/backend ./backend

# 3) Importa la carpeta de migraciones y el alembic.ini
COPY --from=backend /app/migrations ./migrations

# 4) Copia el build del frontend
COPY --from=frontend /app/dist ./frontend/dist

# 5) Define variable para Flask CLI
ENV FLASK_APP=backend.app.main:app

# 6) Ejecuta las migraciones y luego arranca Gunicorn
CMD flask db upgrade && gunicorn --bind 0.0.0.0:${PORT} backend.app.main:app
