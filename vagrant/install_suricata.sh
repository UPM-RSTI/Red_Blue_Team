#!/usr/bin/env bash
# =============================================================================
# install_suricata.sh  –  Install Suricata (latest stable) + ET Open rules
# =============================================================================
set -euo pipefail

SURICATA_LOG_DIR="/var/log/suricata"
SURICATA_RULES_DIR="/var/lib/suricata/rules"
SURICATA_RUN_DIR="/var/run/suricata"

echo ">>> Installing Suricata..."

# ── Add Suricata PPA (OISF maintained – latest stable) ────────────────────────
add-apt-repository -y ppa:oisf/suricata-stable
apt-get update -y
apt-get install -y suricata

# ── Create required directories ───────────────────────────────────────────────
mkdir -p "$SURICATA_LOG_DIR"
mkdir -p "$SURICATA_RULES_DIR"
mkdir -p "$SURICATA_RUN_DIR"
chown -R suricata:suricata "$SURICATA_LOG_DIR" "$SURICATA_RULES_DIR" "$SURICATA_RUN_DIR" 2>/dev/null || \
  chown -R root:root "$SURICATA_LOG_DIR" "$SURICATA_RULES_DIR" "$SURICATA_RUN_DIR"
chmod 755 "$SURICATA_LOG_DIR" "$SURICATA_RULES_DIR"

# ── Copy pre-configured suricata.yaml ─────────────────────────────────────────
cp /tmp/config/suricata.yaml /etc/suricata/suricata.yaml
chmod 640 /etc/suricata/suricata.yaml

# ── Determine default network interface for Suricata ─────────────────────────
DEFAULT_IFACE=$(ip route | awk '/default/ {print $5; exit}')
if [ -z "$DEFAULT_IFACE" ]; then
  DEFAULT_IFACE="eth0"
fi
echo ">>> Using network interface: ${DEFAULT_IFACE}"
sed -i "s/^  - interface: .*/  - interface: ${DEFAULT_IFACE}/" /etc/suricata/suricata.yaml

# ── Update Suricata rules (ET Open) ───────────────────────────────────────────
echo ">>> Updating Suricata rules (ET Open)..."
suricata-update update-sources || true
suricata-update enable-source et/open || true
suricata-update || true

# ── Test Suricata configuration ───────────────────────────────────────────────
echo ">>> Testing Suricata configuration..."
suricata -T -c /etc/suricata/suricata.yaml -v || true

# ── Create / override systemd service ────────────────────────────────────────
mkdir -p /etc/systemd/system/suricata.service.d
cat > /etc/systemd/system/suricata.service.d/override.conf <<EOF
[Service]
ExecStart=
ExecStart=/usr/bin/suricata -c /etc/suricata/suricata.yaml -i ${DEFAULT_IFACE} --pidfile /var/run/suricata/suricata.pid
Restart=on-failure
RestartSec=5
EOF

systemctl daemon-reload
systemctl enable suricata
systemctl restart suricata || true

sleep 3
systemctl status suricata --no-pager || true
echo ">>> Suricata installation complete."
