#!/bin/bash
PROM="${PROM:-localhost:9090}"
INTERVAL="${INTERVAL:-30}"

while true; do
  clear
  printf "═══ SITE STATUS — %s ═══\n\n" "$(date '+%H:%M:%S')"

  if ! curl -sf --max-time 5 "$PROM/-/healthy" > /dev/null; then
    printf "\033[31m⚠ Prometheus unreachable at %s\033[0m\n" "$PROM"
  else
    curl -s --max-time 5 "$PROM/api/v1/query?query=probe_success" \
    | jq -r '.data.result[]
        | "\(if .value[1]=="1" then "\u001b[32m● UP  \u001b[0m" else "\u001b[31m● DOWN\u001b[0m" end) \(.metric.instance)"' \
    | sort -r

    printf "\n── ACTIVE ALERTS ──\n"
    curl -s --max-time 5 "$PROM/api/v1/alerts" \
    | jq -r '.data.alerts[]? | "\(.state)  \(.labels.instance)"' | head -10
  fi

  printf "\nRefreshing every %ss — Ctrl+C to exit\n" "$INTERVAL"
  sleep "$INTERVAL"
done
EOF

