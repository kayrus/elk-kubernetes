FROM alpine:3.4

RUN apk --update add python py-pip && \
    pip install elasticsearch-curator==4.2.3.post1

COPY curator-cron /usr/local/bin
