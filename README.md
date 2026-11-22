# xray-fleet

Xray (VLESS + WebSocket) container image for free-tier PaaS deploys
(Quave Hobby, Komuta free plan).

The platform terminates TLS at the edge, so xray listens plain HTTP on
`$PORT` and the client connects with TLS to the platform domain.

## Env vars

- `UUID` (required): VLESS user id
- `WS_PATH` (optional, default `/xray`): WebSocket path
- `PORT` (optional, default `8080`): set by the platform

## Client

`vless://<UUID>@<platform-domain>:443?encryption=none&security=tls&type=ws&path=/xray`
