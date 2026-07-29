# =============================================================================
# jupyter_notebook_config.py  –  Jupyter Notebook configuration
# Lab environment: allow all IPs, no token authentication (closed network only)
# =============================================================================

c = get_config()  # noqa: F821

# ── Network ───────────────────────────────────────────────────────────────────
# Listen on all interfaces so the Vagrant host can reach it via forwarded port
c.NotebookApp.ip = "0.0.0.0"
c.NotebookApp.port = 8889
c.NotebookApp.open_browser = False

# ── Authentication ────────────────────────────────────────────────────────────
# Disable token and password for easy lab access (isolated private network only)
c.NotebookApp.token = ""
c.NotebookApp.password = ""
c.NotebookApp.allow_password_change = False

# ── Security (relaxed for isolated lab environment) ──────────────────────────
c.NotebookApp.allow_origin = "*"
c.NotebookApp.allow_remote_access = True
c.NotebookApp.disable_check_xsrf = True

# ── Working directory ─────────────────────────────────────────────────────────
c.NotebookApp.notebook_dir = "/home/vagrant/notebooks"

# ── Auto-save and reload ──────────────────────────────────────────────────────
c.ContentsManager.allow_hidden = True

# ── Logging ───────────────────────────────────────────────────────────────────
c.Application.log_level = "INFO"

# ── Kernel options ────────────────────────────────────────────────────────────
c.MappingKernelManager.cull_idle_timeout = 0  # Never kill idle kernels
