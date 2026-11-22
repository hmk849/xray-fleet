#!/bin/sh
# Generates xray + nginx configs from env vars at container start.
# nginx listens on $PORT (the platform-facing port): plain HTTP gets
# 200 (keeps Quave's liveness/readiness probes happy), WebSocket
# upgrades on $WS_PATH are proxied to xray on localhost.
set -e

: "${UUID:?env UUID is required}"
WS_PATH="${WS_PATH:-/xray}"
PORT="${PORT:-8080}"
XRAY_PORT=10000

mkdir -p /etc/xray
cat > /etc/xray/config.json <<EOF
{
  "log": { "loglevel": "warning" },
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": ${XRAY_PORT},
      "protocol": "vless",
      "settings": {
        "clients": [ { "id": "${UUID}" } ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": { "path": "${WS_PATH}" }
      }
    }
  ],
  "outbounds": [ { "protocol": "freedom" } ]
}
EOF

mkdir -p /etc/nginx/http.d
cat > /etc/nginx/http.d/default.conf <<EOF
server {
    listen ${PORT};
    server_name _;
    location = ${WS_PATH} {
        if (\$http_upgrade != "websocket") {
            return 200 "ok\n";
        }
        proxy_pass http://127.0.0.1:${XRAY_PORT};
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_read_timeout 86400s;
        proxy_send_timeout 86400s;
    }
    location / {
        return 200 "ok\n";
    }
}
EOF

nginx -t
nginx
exec /usr/local/bin/xray run -c /etc/xray/config.json
