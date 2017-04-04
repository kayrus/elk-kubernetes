FROM mhart/alpine-node:6

############################################################# Kibana Docker

EXPOSE 5601

ENV KIBANA_VERSION 5.2.2
ENV GOSU_VERSION 1.7
# Install Kibana

RUN apk add --update curl ca-certificates bash gnupg && \
  curl -Lso /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64" && \
  curl -Lso /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64.asc" && \
  export GNUPGHOME="$(mktemp -d)" && \
  gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
  gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu && \
  rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc && \
  chmod +x /usr/local/bin/gosu && \
  ( curl -Lskj https://artifacts.elastic.co/downloads/kibana/kibana-${KIBANA_VERSION}-linux-x86_64.tar.gz | \
  gunzip -c - | tar xf - ) && \
  mv /kibana-${KIBANA_VERSION}-linux-x86_64 /kibana && \
  rm -rf /kibana/node && \
  apk del curl

# Install X-Pack

RUN /kibana/bin/kibana-plugin install x-pack

# Copy run script
COPY run.sh /

CMD ["/run.sh"]
