# Image de base (demandee dans les consignes)
FROM python:3.6-alpine

# Repertoire de travail dans le container
WORKDIR /opt

# Copie du code de l'application
COPY . /opt

# Installation de Flask (framework python), necessaire a app.py
RUN pip install flask

# Rend le script de demarrage executable
RUN chmod +x entrypoint.sh

# Port utilise par l'application (defini dans app.py)
EXPOSE 8080

# Lancement : le script entrypoint.sh lit releases.txt
# et exporte ODOO_URL / PGADMIN_URL avant de demarrer app.py
ENTRYPOINT ["./entrypoint.sh"]
