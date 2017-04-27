FROM alpine:3.5

ENV JAVA_HOME=/usr/lib/jvm/default-jvm/jre

# install envsubst
ENV \
    BUILD_DEPS="gettext"  \
    RUNTIME_DEPS="libintl"
RUN \
    apk add --update $RUNTIME_DEPS && \
    apk add --virtual build_deps $BUILD_DEPS &&  \
    cp /usr/bin/envsubst /usr/local/bin/envsubst && \
    apk del build_deps

# install java and bash
RUN apk upgrade --update-cache && \
    apk add openjdk8-jre bash && \
    rm -rf /tmp/* /var/cache/apk/*

# Install glibc to resolve sqlite's "__isnan: symbol not found"
ADD https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.25-r0/glibc-2.25-r0.apk /tmp
RUN apk add --allow-untrusted /tmp/glibc-2.25-r0.apk

############################################################# ELK Docker

EXPOSE 9000

ENV VERSION 0.6.5
ENV GOSU_VERSION 1.7

# Install Cerebro
RUN apk add --update curl ca-certificates sudo jq gnupg && \
  curl -Lso /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64" && \
  curl -Lso /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64.asc" && \
  export GNUPGHOME="$(mktemp -d)" && \
  gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
  gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu && \
  rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc && \
  chmod +x /usr/local/bin/gosu && \
  ( curl -Lsj https://github.com/lmenezes/cerebro/releases/download/v${VERSION}/cerebro-${VERSION}.tgz | \
  gunzip -c - | tar xf - ) && \
  mv /cerebro-$VERSION /cerebro && \
  apk del gnupg

COPY conf /cerebro/conf

COPY run.sh /

VOLUME /cerebro/logs

CMD ["/run.sh"]
