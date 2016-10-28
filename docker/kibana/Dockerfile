FROM mhart/alpine-node:5

############################################################# Kibana Docker

EXPOSE 5601

ENV KIBANA_VERSION 4.6.1

# Install Kibana

RUN apk add --update curl ca-certificates sudo && \

  ( curl -Lskj https://download.elastic.co/kibana/kibana/kibana-${KIBANA_VERSION}-linux-x86_64.tar.gz | \
  gunzip -c - | tar xf - ) && \
  mv /kibana-${KIBANA_VERSION}-linux-x86_64 /kibana-linux-x86_64 && \
  rm -rf /kibana-linux-x86_64/node && \
  apk del curl

# Install Kaae

RUN /kibana-linux-x86_64/bin/kibana plugin --install kaae -u https://github.com/elasticfence/kaae/releases/download/snapshot/kaae-latest.tar.gz

RUN ln -s /etc/kaae/kaae.json /etc/kaae.json

# Copy run script
COPY run.sh /

CMD ["/run.sh"]
