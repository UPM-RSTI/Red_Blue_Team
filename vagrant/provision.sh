#!/usr/bin/env bash
# =============================================================================
# provision.sh  –  Main provisioning script for SURI-CALDERA IDS Lab
# Runs as root inside the Vagrant VM (ubuntu/jammy64 – Ubuntu 22.04 LTS)
# =============================================================================
set -euo pipefail

LOGFILE="/var/log/provision.log"
exec > >(tee -a "$LOGFILE") 2>&1

echo "============================================================"
echo " SURI-CALDERA IDS Lab – Provisioning started"
echo " $(date)"
echo "============================================================"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAGRANT_DIR="/vagrant/vagrant"

# ── 1. System update & base dependencies ──────────────────────────────────────
echo "[1/6] Updating system packages..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get upgrade -y
apt-get install -y \
  curl wget git build-essential \
  python3 python3-pip python3-dev python3-venv \
  software-properties-common apt-transport-https \
  ca-certificates gnupg lsb-release unzip zip \
  net-tools iproute2 tcpdump nmap \
  vim nano htop tree jq \
  libssl-dev libffi-dev \
  ufw

echo "[1/6] Base dependencies installed."

# ── 2. Install Caldera ────────────────────────────────────────────────────────
echo "[2/6] Installing MITRE Caldera..."
bash "${VAGRANT_DIR}/install_caldera.sh"
echo "[2/6] Caldera installed."

# ── 3. Install Suricata ───────────────────────────────────────────────────────
echo "[3/6] Installing Suricata..."
bash "${VAGRANT_DIR}/install_suricata.sh"
echo "[3/6] Suricata installed."

# ── 4. Install Jupyter ────────────────────────────────────────────────────────
echo "[4/6] Installing Jupyter..."
bash "${VAGRANT_DIR}/install_jupyter.sh"
echo "[4/6] Jupyter installed."

# ── 5. Security & access ──────────────────────────────────────────────────────
echo "[5/6] Configuring security and access..."

# Create student user if it doesn't exist
if ! id "student" &>/dev/null; then
  useradd -m -s /bin/bash -G sudo student
  echo "student:student" | chpasswd
  echo "student ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/student
  chmod 440 /etc/sudoers.d/student
fi

# Copy utility scripts
mkdir -p /opt/scripts
cp /tmp/scripts/start_services.sh  /opt/scripts/
cp /tmp/scripts/check_services.sh  /opt/scripts/
chmod +x /opt/scripts/*.sh

# Firewall rules
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp    # SSH
ufw allow 8888/tcp  # Caldera
ufw allow 8889/tcp  # Jupyter
ufw allow 5000/tcp  # Optional Suricata API
ufw --force enable

echo "[5/6] Security and access configured."

# ── 6. Health checks ──────────────────────────────────────────────────────────
echo "[6/6] Running health checks..."
sleep 5
bash /opt/scripts/check_services.sh || true

echo "============================================================"
echo " Provisioning complete! $(date)"
echo "============================================================"
echo ""
echo "  Caldera  → http://localhost:8888  (admin / admin)"
echo "  Jupyter  → http://localhost:8889"
echo "  SSH      → vagrant ssh"
echo ""
