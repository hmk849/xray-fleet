# Xray (VLESS + WebSocket) for PaaS (Quave, Komuta)
# Platform terminates TLS at the edge, so xray listens
# plain HTTP on $PORT and the client uses TLS to the platform domain.
FROM alpine:latest

RUN apk add --no-cache curl unzip ca-certificates \
    && mkdir -p /usr/local/bin /etc/xray \
    && curl -fsSL -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip \
    && unzip -o /tmp/xray.zip -d /usr/local/bin/ \
    && chmod +x /usr/local/bin/xray \
    && rm -f /tmp/xray.zip \
    && apk del curl unzip

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
