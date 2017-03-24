FROM mhart/alpine-node:6

############################################################# Kibana Docker

EXPOSE 5601

ENV KIBANA_VERSION 4.6.4
ENV SENTINL_VERSION 4.6.4

# Install Kibana

RUN apk add --update curl ca-certificates sudo && \

  ( curl -Lskj https://download.elastic.co/kibana/kibana/kibana-${KIBANA_VERSION}-linux-x86_64.tar.gz | \
  gunzip -c - | tar xf - ) && \
  mv /kibana-${KIBANA_VERSION}-linux-x86_64 /kibana-linux-x86_64 && \
  rm -rf /kibana-linux-x86_64/node && \
  apk del curl

# Install sentinl
RUN npm install --save later mustache emailjs node-slack node-horseman sum-time
RUN /kibana-linux-x86_64/bin/kibana plugin --install sentinl -u https://github.com/sirensolutions/sentinl/archive/tag-${SENTINL_VERSION}.tar.gz

RUN /kibana-linux-x86_64/bin/kibana plugin --install heatmap -u https://github.com/stormpython/heatmap/archive/1.0.0.zip
RUN /kibana-linux-x86_64/bin/kibana plugin --install vectormap -u https://github.com/stormpython/vectormap/archive/master.zip

RUN rm -rf /kibana-linux-x86_64/config && ln -s /etc/kibana /kibana-linux-x86_64/config

# Copy run script
COPY run.sh /

CMD ["/run.sh"]
