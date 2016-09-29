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

# Copy run script
COPY run.sh /

CMD ["/run.sh"]
