FROM alpine:latest

LABEL maintainer="Dmitry Konovalov"

ENV LANG=ru_RU.UTF-8
ENV LC_ALL ru_RU.UTF-8
RUN echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
     && set -e \
     && apk add --update --quiet \
     nano \
     mariadb-connector-odbc \
     unixodbc \
     mc \
     php7 \
     php7-fpm \
     php7-opcache \
     php7-curl \
     php7-gd \
     php7-mysqli \
     php7-zlib \
     asterisk \
     asterisk-curl \
     asterisk-dev \
     asterisk-doc \
     asterisk-odbc \
     asterisk-sample-config >/dev/null \
     && asterisk -U asterisk &>/dev/null \
     && sleep 5s \
     && [ "$(asterisk -rx "core show channeltypes" | grep PJSIP)" != "" ] && : \
     || rm -rf /usr/lib/asterisk/modules/*pj* \
     && pkill -9 ast \
     && sleep 1s \
     && truncate -s 0 \
     /var/log/asterisk/messages \
     /var/log/asterisk/queue_log || : \
     && echo '#tryinclude "sip/*.conf"' >> /etc/asterisk/sip.conf \
     && echo '#tryinclude "dialplan/*.conf"' >> /etc/asterisk/extensions.conf \
     && echo '#include "ael/*.conf"' >> /etc/asterisk/extensions.ael \
     && echo $'[MariaDB]\n\
     Description=ODBC for MariaDB\n\
     Driver=/usr/lib/mariadb/libmaodbc.so\n\
     Setup=/usr/lib64/libodbcmyS.so\n\
     UsageCount=1\n' > /etc/odbcinst.ini \
     && echo $'[asterisk-connector]\n\
     Description = MySQL connection to asterisk database\n\
     Driver = MariaDB\n\
     Database = asterisk\n\
     Server = localhost\n\
     Port = 3306\n' > /etc/odbc.ini \
     && mkdir -p /var/spool/asterisk/fax \
     && chown -R asterisk: /var/spool/asterisk \
     && rm -rf /var/run/asterisk/* \
     /var/cache/apk/* \
     /tmp/* \
     /var/tmp/*

EXPOSE 5060-5061/udp 5060-5061/tcp
EXPOSE 10000-10050/UDP
VOLUME /var/lib/asterisk /etc/asterisk /var/spool/asterisk /var/log/asterisk
ADD docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

