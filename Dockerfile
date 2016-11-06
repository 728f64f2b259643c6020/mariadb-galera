FROM mariadb:10.1

RUN set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
      curl \
    && rm -rf /tmp/* /var/cache/apk/* /var/lib/apt/lists/* \
    && git clone https://github.com/maxhq/zabbix-backup \
    && mv /zabbix-backup/zabbix-mysql-dump /zabbix-backup/zabbix-mariadb-dump

COPY conf.d/* /etc/mysql/conf.d/
COPY bin/galera-healthcheck /usr/local/bin/galera-healthcheck
COPY mysqld.sh /usr/local/bin/mysqld.sh
COPY bootstrap.sh /usr/local/bin/bootstrap.sh
COPY zabbix/ /usr/local/bin/

# Add VOLUME to allow backup of data
VOLUME ["/var/lib/mysql"]

# Set TERM env to avoid mysql client error message "TERM environment variable not set" when running from inside the container
ENV TERM xterm

EXPOSE 3306 4444 4567 4567/udp 4568

HEALTHCHECK CMD curl -f -o - http://127.0.0.1:8080/ || exit 1

ENTRYPOINT ["bootstrap.sh"]
ENTRYPOINT ["zabbix.sh"]
