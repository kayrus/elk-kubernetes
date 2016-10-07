FROM alpine:3.4

RUN apk add --no-cache \
		curl \
                jq

ADD events.sh /

ENTRYPOINT [ "/events.sh" ]
CMD [ "sh" ]
