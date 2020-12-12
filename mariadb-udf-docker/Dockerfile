FROM mariadb:latest

ENV MYSQL_DATABASE='dummy'
ENV MYSQL_USER='admin'
ENV MYSQL_PASSWORD='abc123'
ENV MYSQL_ROOT_PASSWORD='aabbcc112233'
ENV MYSQL_ROOT_HOST='%'

COPY ./init.sql /docker-entrypoint-initdb.d/init.sql
COPY ./mariadb.service /etc/systemd/system/mariadb.service
COPY ./bitap.so /usr/lib/mysql/plugin/bitap.so