#!/bin/sh
# Generates xray config from env vars at container start.
set -e

: "${UUID:?env UUID is required}"
WS_PATH="${WS_PATH:-/xray}"
PORT="${PORT:-8080}"

mkdir -p /etc/xray
cat > /etc/xray/config.json <<EOF
{
  "log": { "loglevel": "warning" },
  "inbounds": [
    {
      "port": ${PORT},
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

exec /usr/local/bin/xray run -c /etc/xray/config.json
