# Utilitza una imatge base d'Ubuntu
FROM ubuntu:24.04

# Actualitza els paquets i instal·la les dependències
RUN apt-get update && apt-get install -y \
	python3 \
	python3-pip \
	python3-venv \
	gunicorn \
	openssh-server \
	&& rm -rf /var/lib/apt/lists/*

# Crea el directori de l'aplicació
WORKDIR /app

# Crea i activa un entorn virtual
RUN python3 -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH"

# Copia el fitxer de requeriments i instal·la les dependències
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copia l'aplicació Flask al directori de treball
COPY . /app

# Exposa el port 8000 per a Gunicorn i el port 22 per a SSH
EXPOSE 8000 22

# Configura el servidor SSH
RUN mkdir /var/run/sshd
RUN echo 'root:password' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Comanda per iniciar Gunicorn i el servidor SSH
CMD service ssh start && gunicorn --bind 0.0.0.0:8000 wsgi:app
