#!/bin/sh
# Script de demarrage du container
# Lit releases.txt et exporte les valeurs comme variables d'environnement
# avant de lancer l'application Flask

export ODOO_URL=$(awk '/ODOO_URL/ {sub(/^.* /, ""); print}' releases.txt)
export PGADMIN_URL=$(awk '/PGADMIN_URL/ {sub(/^.* /, ""); print}' releases.txt)

exec python app.py

