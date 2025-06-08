# --- Etapa 1: Backend ---
FROM python:3.11-slim AS backend

WORKDIR /app
# Copia y instala dependencias de Python
COPY backend/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY backend/ ./backend/

# --- Etapa 2: Frontend ---
FROM node:20 AS frontend

WORKDIR /app
# Copia y construye React/Vite
COPY frontend/ ./
RUN npm install
RUN npm run build

# --- Etapa final: combina backend + frontend build ---
FROM python:3.11-slim

WORKDIR /app
# Copia Python + código backend
COPY --from=backend /usr/local/lib/python3.11 /usr/local/lib/python3.11
COPY --from=backend /usr/local/bin     /usr/local/bin
COPY backend/ ./backend/

# Copia build estático de React
COPY --from=frontend /app/dist ./frontend/dist

EXPOSE 5000
CMD ["python", "backend/app/main.py"]
