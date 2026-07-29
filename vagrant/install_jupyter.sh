#!/usr/bin/env bash
# =============================================================================
# install_jupyter.sh  –  Install Jupyter Notebook + data-science stack
# =============================================================================
set -euo pipefail

JUPYTER_USER="vagrant"
JUPYTER_HOME="/home/vagrant"
VENV_DIR="${JUPYTER_HOME}/jupyter-env"
NOTEBOOKS_DIR="${JUPYTER_HOME}/notebooks"
JUPYTER_PORT=8889
JUPYTER_CONFIG_DIR="${JUPYTER_HOME}/.jupyter"

echo ">>> Installing Jupyter Notebook..."

# ── Python venv ───────────────────────────────────────────────────────────────
python3 -m venv "$VENV_DIR"
source "${VENV_DIR}/bin/activate"

pip install --upgrade pip wheel setuptools

# ── Install Jupyter + data-science stack ─────────────────────────────────────
pip install \
  jupyter \
  notebook \
  jupyterlab \
  pandas \
  matplotlib \
  seaborn \
  numpy \
  requests \
  ipywidgets \
  tqdm

deactivate

chown -R "${JUPYTER_USER}:${JUPYTER_USER}" "$VENV_DIR"

# ── Notebooks directory ───────────────────────────────────────────────────────
mkdir -p "$NOTEBOOKS_DIR"
cp /tmp/notebooks/*.ipynb "$NOTEBOOKS_DIR/" 2>/dev/null || true
chown -R "${JUPYTER_USER}:${JUPYTER_USER}" "$NOTEBOOKS_DIR"

# ── Jupyter configuration ─────────────────────────────────────────────────────
mkdir -p "$JUPYTER_CONFIG_DIR"
cp /tmp/config/jupyter_config.py "${JUPYTER_CONFIG_DIR}/jupyter_notebook_config.py"
chown -R "${JUPYTER_USER}:${JUPYTER_USER}" "$JUPYTER_CONFIG_DIR"

# ── Create systemd service ────────────────────────────────────────────────────
cat > /etc/systemd/system/jupyter.service <<EOF
[Unit]
Description=Jupyter Notebook Server
After=network.target

[Service]
Type=simple
User=${JUPYTER_USER}
WorkingDirectory=${NOTEBOOKS_DIR}
ExecStart=${VENV_DIR}/bin/jupyter notebook \
    --config=${JUPYTER_CONFIG_DIR}/jupyter_notebook_config.py \
    --notebook-dir=${NOTEBOOKS_DIR} \
    --no-browser
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal
SyslogIdentifier=jupyter
Environment="PATH=${VENV_DIR}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable jupyter
systemctl start jupyter

sleep 3
systemctl status jupyter --no-pager || true
echo ">>> Jupyter installation complete. Access at http://localhost:${JUPYTER_PORT}"
