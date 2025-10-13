FROM postgres:15

# Copier les scripts SQL dans le dossier d'initialisation
COPY ./*.sql /docker-entrypoint-initdb.d/

EXPOSE 5432
