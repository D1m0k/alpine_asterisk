FROM alpine:3.16.2

LABEL maintainer="Dmitry Konovalov"

ENV LANG=ru_RU.UTF-8
ENV LC_ALL ru_RU.UTF-8

RUN set -e \
&& apk add --update --quiet \
         asterisk \
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
&& mkdir -p /var/spool/asterisk/fax \
&& chown -R asterisk: /var/spool/asterisk \
&& rm -rf /var/run/asterisk/* \
          /var/cache/apk/* \
          /tmp/* \
          /var/tmp/*

EXPOSE 5060-5061/udp 5060-5061/tcp
EXPOSE 10000-10050/UDP

ADD docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]