# mointer

Lightweight uptime & SSL monitoring for a handful of websites, with instant Telegram alerts — no SaaS, no agents, just Docker Compose.

**Stack:** Prometheus · Blackbox Exporter · Alertmanager · Grafana

## What it does

- Probes each site over HTTP(S) every 60s (up/down + response)
- Warns 21 days before an SSL certificate expires
- Sends a Telegram message the moment a site goes down (and when it recovers)
- Groups alerts per client/company so you're not spammed one-message-per-site
- Ships a live terminal dashboard (`dash.sh`) if you don't want to open Grafana

## Quick start

```bash
git clone https://github.com/YousefGo/mointer.git
cd mointer

cp alertmanager/alertmanager.yml.example alertmanager/alertmanager.yml
cp prometheus/targets/clients.json.example prometheus/targets/clients.json
```

Edit those two files:
- `alertmanager/alertmanager.yml` → your Telegram `bot_token` and `chat_id`
- `prometheus/targets/clients.json` → the URLs you want to watch

```bash
docker compose up -d
```

| Service      | URL                     |
|--------------|--------------------------|
| Prometheus   | http://localhost:9090   |
| Alertmanager | http://localhost:9093   |
| Grafana      | http://localhost:3000   |

Or skip the UI and watch it live in your terminal:

```bash
./dash.sh
```

## Getting a Telegram bot token & chat ID

1. Message [@BotFather](https://t.me/BotFather) → `/newbot` → copy the token
2. Message your new bot anything (e.g. `/start`)
3. Get your chat ID: `curl https://api.telegram.org/bot<TOKEN>/getUpdates`

## Handling sites behind bot protection

Some sites (Cloudflare, etc.) return `403` to automated probes even though they're perfectly up for real visitors. Give that target its own `module` in `clients.json`:

```json
{ "targets": ["https://protected-site.com/"], "labels": { "company": "acme", "module": "http_2xx_or_403" } }
```

`http_2xx_or_403` is defined in `blackbox/blackbox.yml` and treats `403` as healthy for that target only.

## Project layout

```
prometheus/     scrape config + alert rules
blackbox/       probe modules (what counts as "up")
alertmanager/   routing + Telegram receiver
grafana/        Prometheus datasource provisioning
dash.sh         terminal status dashboard
```

## License

MIT
