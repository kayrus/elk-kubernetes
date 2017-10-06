FROM alpine:3.4

RUN apk --update add python py-pip && \
    pip install elasticsearch-curator==5.2.0

COPY curator-cron /usr/local/bin
