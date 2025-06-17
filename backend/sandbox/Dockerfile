FROM python:3.10-slim

# Crear usuario no root
RUN useradd -ms /bin/bash sandboxuser

# Establecer directorio de trabajo
WORKDIR /home/sandboxuser

# Copiar el archivo main.py desde la carpeta correcta
COPY ./container/main.py ./main.py

# Dar permisos de ejecución
RUN chmod +x main.py

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Cambiar al usuario seguro
USER sandboxuser

# Documentar puerto
EXPOSE 3000

# Comando que inicia el servidor Flask
#CMD [ "python", "main.py" ]
CMD ["sh", "-c", "python main.py"]