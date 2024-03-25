FROM alpine:3.15.0
WORKDIR /app 
RUN addgroup --system bingousers \
    mkdir -p /app/.postgresql \
    && wget "https://storage.yandexcloud.net/cloud-certs/CA.pem" \
    --output-document /app/.postgresql/root.crt \
    && adduser -S -s /bin/false -G bingousers bingoservice -D -H \
    && apk add --no-cache postgresql-client curl \
    && curl -O https://storage.yandexcloud.net/final-homework/bingo \
    && mkdir -p /opt/bongo/logs/3a956b711f/ && chown -R bingoservice:bingousers /opt/bongo \
    && chown -R bingo:bingo /app \
    && chmod 0600 /bin/.postgresql/root.crt
USER bingoservice
EXPOSE 27352
ENTRYPOINT ["/opt/bingo/bingo", "run_server"]