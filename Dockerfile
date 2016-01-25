FROM debian:wheezy

ENV RUN_USER            mongodb
ENV RUN_USER_UID        3027
ENV RUN_GROUP           mongodb
ENV RUN_GROUP_GID       3027

RUN \
    groupadd --gid ${RUN_GROUP_GID} -r ${RUN_GROUP} && \
    useradd -r --uid ${RUN_USER_UID} -g ${RUN_GROUP} ${RUN_USER}

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates curl \
        numactl \
    && rm -rf /var/lib/apt/lists/*

# grab gosu for easy step-down from root
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu

# gpg: key 7F0CEB10: public key "Richard Kreuter <richard@10gen.com>" imported
RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 492EAFE8CD016A07919F1D2B9ECBEC467F0CEB10

RUN echo "deb http://repo.mongodb.org/apt/debian wheezy/mongodb-org/3.2 main" > /etc/apt/sources.list.d/mongodb-org-3.2.list

RUN set -x \
    && apt-get update \
    && apt-get install --force-yes -y mongodb-org \
    && rm -rf /var/lib/apt/lists/*

RUN chown -R ${RUN_USER}:${RUN_GROUP} /var/lib/mongodb

VOLUME /var/lib/mongodb

COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 27017

CMD ["mongod", "--config", "/etc/mongod.conf"]
