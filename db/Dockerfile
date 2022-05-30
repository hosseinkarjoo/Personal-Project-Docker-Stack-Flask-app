FROM mysql


COPY ./create-local-db.sql /tmp
EXPOSE 3306
CMD [ "mysqld", "--init-file=/tmp/create-local-db.sql" ]
