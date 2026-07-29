#!/usr/bin/env bash
# =============================================================================
# start_services.sh  –  Start all lab services
# =============================================================================
set -euo pipefail

SERVICES=(caldera suricata jupyter)

echo "Starting SURI-CALDERA lab services..."
for svc in "${SERVICES[@]}"; do
  echo -n "  Starting ${svc}... "
  if systemctl start "$svc" 2>/dev/null; then
    echo "OK"
  else
    echo "FAILED (check: journalctl -u ${svc})"
  fi
done

echo ""
echo "Service status:"
for svc in "${SERVICES[@]}"; do
  STATUS=$(systemctl is-active "$svc" 2>/dev/null || echo "unknown")
  printf "  %-12s %s\n" "${svc}" "${STATUS}"
done

echo ""
echo "Access URLs:"
echo "  Caldera  → http://localhost:8888  (admin / admin)"
echo "  Jupyter  → http://localhost:8889"
