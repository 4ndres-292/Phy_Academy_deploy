# --- Etapa 1: Backend deps ---
FROM python:3.11-slim AS backend

WORKDIR /app

# Instala herramientas necesarias para compilar dependencias
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    libffi-dev \
    libssl-dev \
    python3-dev \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copia e instala las dependencias de Python
COPY backend/requirements.txt .
RUN python -m pip install --upgrade pip
RUN python -m pip install --no-cache-dir -r requirements.txt

# Copia el código backend y las migraciones
COPY backend /app/backend
COPY backend/migrations /app/migrations
COPY backend/alembic.ini /app/alembic.ini



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

# Copia las librerías de Python
COPY --from=backend /usr/local/lib/python3.11 /usr/local/lib/python3.11
COPY --from=backend /usr/local/bin /usr/local/bin

# Copia el código de backend y las migraciones
COPY --from=backend /app/backend ./backend
COPY --from=backend /app/migrations ./migrations
COPY --from=backend /app/alembic.ini ./alembic.ini

# Copia el frontend ya compilado
COPY --from=frontend /app/dist ./frontend/dist

# Variable obligatoria para flask db
ENV FLASK_APP=backend.app.main:app

# El contenedor necesita esta variable para conectarse a tu base
# En Railway o producción asegúrate que DATABASE_URL esté definida
# ENV DATABASE_URL=postgresql://postgres:AgEdzTQqJaixxALdrxxulmgQTWUKzGNl@postgres-uety.railway.internal:5432/railway

# Comando final: aplicar migraciones y arrancar Gunicorn

CMD flask db upgrade && gunicorn --bind 0.0.0.0:${PORT} backend.app.main:app
