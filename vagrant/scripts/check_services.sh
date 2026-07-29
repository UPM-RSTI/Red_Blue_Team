#!/usr/bin/env bash
# =============================================================================
# check_services.sh  –  Health check for all lab services
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASS=0
FAIL=0

check_service() {
  local name="$1"
  local status
  status=$(systemctl is-active "$name" 2>/dev/null || echo "unknown")
  if [ "$status" = "active" ]; then
    echo -e "  [${GREEN}OK${NC}]   ${name} is running"
    ((PASS++))
  else
    echo -e "  [${RED}FAIL${NC}] ${name} is ${status}"
    ((FAIL++))
  fi
}

check_port() {
  local name="$1"
  local port="$2"
  if ss -tlnp 2>/dev/null | grep -q ":${port}" || \
     curl -fsSL --max-time 3 "http://127.0.0.1:${port}" &>/dev/null; then
    echo -e "  [${GREEN}OK${NC}]   ${name} is accessible on port ${port}"
    ((PASS++))
  else
    echo -e "  [${YELLOW}WARN${NC}] ${name} not yet accessible on port ${port} (may still be starting)"
  fi
}

echo "============================================================"
echo " SURI-CALDERA IDS Lab – Health Check"
echo " $(date)"
echo "============================================================"
echo ""
echo "── Systemd Services ──"
check_service caldera
check_service suricata
check_service jupyter

echo ""
echo "── Network Ports ──"
check_port "Caldera" 8888
check_port "Jupyter" 8889

echo ""
echo "── Suricata Logs ──"
if [ -f /var/log/suricata/eve.json ]; then
  ALERT_COUNT=$(grep -c '"event_type":"alert"' /var/log/suricata/eve.json 2>/dev/null || echo 0)
  echo -e "  [${GREEN}OK${NC}]   eve.json exists (${ALERT_COUNT} alerts)"
else
  echo -e "  [${YELLOW}WARN${NC}] eve.json not yet created"
fi

if [ -f /var/log/suricata/fast.log ]; then
  echo -e "  [${GREEN}OK${NC}]   fast.log exists"
else
  echo -e "  [${YELLOW}WARN${NC}] fast.log not yet created"
fi

echo ""
echo "── Caldera Rules (Suricata) ──"
RULES_COUNT=$(find /var/lib/suricata/rules -name "*.rules" -exec grep -h "^alert" {} + 2>/dev/null | wc -l || echo 0)
echo -e "  Rules loaded: ${RULES_COUNT}"

echo ""
echo "============================================================"
echo " Summary: ${PASS} passed, ${FAIL} failed"
echo "============================================================"
echo ""
echo "  Caldera  → http://localhost:8888  (admin / admin)"
echo "  Jupyter  → http://localhost:8889"
echo ""

[ "$FAIL" -eq 0 ]
