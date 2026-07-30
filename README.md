# SURI-CALDERA IDS Practice Lab

> **Adversary Emulation & Intrusion Detection – MITRE Caldera + Suricata**

A production-ready Vagrant-based lab environment for learning offensive and defensive cybersecurity using MITRE Caldera and Suricata IDS.

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Start](#quick-start)
3. [Lab Topology & VM Specifications](#lab-topology--vm-specifications)
4. [Access URLs & Credentials](#access-urls--credentials)
5. [Service Management](#service-management)
6. [Lab Structure](#lab-structure)
7. [Workflow for Students](#workflow-for-students)
8. [Troubleshooting](#troubleshooting)
9. [OVA Export](#ova-export)
10. [Expected Learning Outcomes](#expected-learning-outcomes)

---

## Prerequisites

Install the following tools on your host machine:

| Tool | Version | Download |
|------|---------|----------|
| VirtualBox | ≥ 7.0 | https://www.virtualbox.org/wiki/Downloads |
| Vagrant | ≥ 2.3 | https://developer.hashicorp.com/vagrant/downloads |
| Git | any | https://git-scm.com/downloads |

**Hardware requirements (host machine):**
- RAM: 8 GB minimum (6 GB reserved for the two VMs: 4 GB server + 2 GB agent)
- Disk: 35 GB free space (both VMs + OVA export headroom)
- CPU: 4 cores recommended (2 dedicated to each VM)

**Network requirement:** The `caldera-server` VM needs outbound internet access during provisioning and while running the notebooks — `suricata-update` downloads rule sets and the IDS notebook automatically downloads the PCAP files it analyzes from `malware-traffic-analysis.net`.

---

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/UPM-RSTI/Red_Blue_Team.git
cd Red_Blue_Team

# 2. Start both VMs (first time: ~15-20 minutes for provisioning)
vagrant up
#    (or bring them up one at a time: `vagrant up caldera-server` / `vagrant up caldera-agent`)

# 3. Open the lab in your browser
#    Caldera:  http://localhost:18888   (admin / admin)
#    Jupyter:  http://localhost:8889

# 4. SSH into a VM (optional) — name the machine, there are two now
vagrant ssh caldera-server
vagrant ssh caldera-agent

# 5. Shutdown when done
vagrant halt

# 6. Destroy the VMs (removes all data)
vagrant destroy
```

---

## Lab Topology & VM Specifications

The lab is a **two-VM topology**: a fully provisioned server running Caldera, Suricata and Jupyter, plus a plain, unprovisioned agent machine that acts as the Red Team's target — this is where you deploy the Caldera (Sandcat) agent by hand, following Section B.1 of the `CALDERA_RED_TEAM_PRACTICE_V2` notebook.

```
Host machine
 ├─ caldera-server  (192.168.56.10)  →  Caldera + Suricata + Jupyter, fully provisioned
 └─ caldera-agent   (192.168.56.11)  →  Bare Ubuntu box, target for the Sandcat agent
```

### `caldera-server`

| Parameter | Value |
|-----------|-------|
| Base OS   | Ubuntu 22.04 LTS (Jammy) |
| VM name   | SURI-CALDERA-IDS-LABV3 |
| vCPU      | 2 cores |
| RAM       | 4096 MB |
| Disk      | 20 GB |
| Network   | Private 192.168.56.10 + forwarded ports |

**Forwarded ports:**

| Service | Guest Port | Host Port |
|---------|-----------|-----------|
| Caldera Web UI | 8888 | **18888** |
| Jupyter Notebook | 8889 | 8889 |
| SSH | 22 | 2223 |
| Suricata API (optional) | 5000 | 5000 |

### `caldera-agent`

| Parameter | Value |
|-----------|-------|
| Base OS   | Ubuntu 22.04 LTS (Jammy), unprovisioned |
| VM name   | CALDERA-AGENT-NODE |
| vCPU      | 2 cores |
| RAM       | 2048 MB |
| Disk      | 15 GB |
| Network   | Private 192.168.56.11 + forwarded SSH (host **2224**) |

> ⚠️ **Note:** The Caldera Web UI host port is **18888**, not 8888 — the guest-side service still listens on 8888 (that's what `check_services.sh` checks *inside* the VM), but the Vagrantfile forwards it to host port 18888 to avoid clashing with other local services. Always browse to `http://localhost:18888` from your host.

---

## Access URLs & Credentials

| Service | URL | Username | Password |
|---------|-----|----------|----------|
| Caldera Web | http://localhost:18888 | `admin` | `admin` |
| Caldera REST API | http://localhost:18888/api/v2 | API Key (`KEY` header) | `REDADMIN123` (red) / `BLUEADMIN123` (blue) |
| Jupyter Notebook | http://localhost:8889 | — | (no password) |
| `caldera-server` SSH | `vagrant ssh caldera-server` or `ssh -p 2223 vagrant@127.0.0.1` | `vagrant` | `vagrant` |
| `caldera-agent` SSH | `vagrant ssh caldera-agent` or `ssh -p 2224 vagrant@127.0.0.1` | `vagrant` | `vagrant` |
| Student user (on `caldera-server`) | SSH | `student` | `student` |

> ⚠️ **Security note:** This lab uses simplified credentials on purpose. Never expose it to the internet. It is designed for isolated networks only.

---

## Service Management

Run these commands **inside the `caldera-server` VM** (`vagrant ssh caldera-server`):

```bash
# Check all services
sudo /opt/scripts/check_services.sh

# Start all services
sudo /opt/scripts/start_services.sh

# Caldera
sudo systemctl status  caldera
sudo systemctl start   caldera
sudo systemctl stop    caldera
sudo systemctl restart caldera
sudo journalctl -u caldera -f   # live logs

# Suricata
sudo systemctl status  suricata
sudo systemctl restart suricata
sudo journalctl -u suricata -f  # live logs
tail -f /var/log/suricata/eve.json    # EVE JSON stream
tail -f /var/log/suricata/fast.log   # fast alerts

# Jupyter
sudo systemctl status  jupyter
sudo systemctl restart jupyter
sudo journalctl -u jupyter -f
```

The `caldera-agent` VM has no services of its own — it only needs to reach `caldera-server` over the private network (`ping 192.168.56.10`) so a Sandcat agent deployed there can register.

---

## Lab Structure

```
Red_Blue_Team/
├── README.md                          # This file
├── Vagrantfile                        # Two-VM configuration (caldera-server + caldera-agent)
├── requirements.txt                   # Python dependencies
├── EXPORT_TO_OVA.md                  # OVA export instructions
├── vagrant/
│   ├── provision.sh                   # Main provisioning orchestrator (caldera-server only)
│   ├── install_caldera.sh            # Caldera installation
│   ├── install_suricata.sh           # Suricata installation
│   ├── install_jupyter.sh            # Jupyter installation
│   ├── config/
│   │   ├── suricata.yaml             # Pre-configured Suricata
│   │   ├── caldera_config.yml        # Pre-configured Caldera
│   │   └── jupyter_config.py         # Jupyter configuration
│   └── scripts/
│       ├── start_services.sh         # Start all services
│       └── check_services.sh         # Health check
└── notebooks/
    ├── CALDERA_RED_TEAM_PRACTICE_V2_EN.ipynb   # ⭐ Red Team lab (English) — Caldera only
    ├── CALDERA_RED_TEAM_PRACTICE_V2 (1).ipynb  #    Same lab, Spanish version
    ├── SURI_IDS_MASTER_V2_EN.ipynb             # ⭐ IDS lab (English) — offline PCAP analysis with Suricata
    ├── server_SURI_IDS_MASTER_V2.ipynb         #    Same lab, Spanish version
    ├── SURI_CALDERA_ADVERSARY_PRACTICE.ipynb   #    Legacy combined lab (Spanish) — Caldera + Suricata live
    └── SURI_IDS_MASTER-2.ipynb                 #    Legacy IDS lab (Spanish, V1) — superseded by *_V2_EN
```

**Which notebook should I use?** The two `*_V2` notebooks are the current, actively maintained practices and are available in both English (recommended) and Spanish — pick the language your students need. `SURI_CALDERA_ADVERSARY_PRACTICE.ipynb` and `SURI_IDS_MASTER-2.ipynb` are the earlier, Spanish-only combined lab kept for reference; new cohorts should use the `V2` split labs instead.

---

## Workflow for Students

### Option A: Vagrant (recommended)

```
vagrant up → open http://localhost:8889 → run notebook cells
```

### Option B: Imported OVA
https://drive.upm.es/s/FSsj2s4aHWX2R8W
```
Import OVA in VirtualBox → Start VM → open http://localhost:8889
```

### Deploying the Sandcat agent (Red Team lab only)

`CALDERA_RED_TEAM_PRACTICE_V2` needs at least one registered agent before Section B. Deploy it on the `caldera-agent` VM:

```bash
vagrant ssh caldera-agent

# Inside caldera-agent:
curl -s -X POST -H 'file:sandcat.go-linux' \
     -H 'platform:linux' \
     http://192.168.56.10:8888/file/download > /tmp/sandcat
chmod +x /tmp/sandcat
/tmp/sandcat -server http://192.168.56.10:8888 -group red -v
```

The agent registers itself with Caldera over the private network and shows up in the agent list the notebook queries in Section 0 / B.1.

### Notebook Sections

#### CALDERA_RED_TEAM_PRACTICE_V2_EN.ipynb — Red Team Lab (Caldera only)

| # | Section | Description |
|---|---------|-------------|
| 0 | Environment Validation | Check `caldera`/`jupyter` services and API connectivity |
| 1 | Conceptual Introduction | Caldera architecture, key concepts, ATT&CK mapping, Caldera vs Metasploit |
| A | Caldera Fundamentals | Explore abilities, predefined adversaries, planners |
| B | First Operation – Recon | Register agent, build a Discovery adversary, run and analyze an operation |
| C | Intermediate Operation – Multi-Tactic | Attack chain design across Discovery → Credential Access → Execution → Collection |
| D | Advanced Operation | Persistence, lateral movement, data exfiltration (with API verification of each step) |
| E | Analysis with Python/Pandas | Extract operation data, success-rate tables, 4-panel chart dashboard |

#### SURI_IDS_MASTER_V2_EN.ipynb — IDS Lab (offline PCAP analysis)

| # | Section | Description |
|---|---------|-------------|
| 1 | Environment Check & Installation | Auto-detects Colab/Vagrant/generic environment, verifies Suricata |
| 2 | `suricata.yaml` Review | HOME_NET/EXTERNAL_NET, rule paths, `fast.log`/`eve.json` outputs |
| 3 | `suricata-update` | Rule counts before/after, ET Open rule sources |
| 4 | PCAP 1 Analysis | *Webserver scans and probes* — auto-downloaded, analyzed offline with `-r` |
| 5 | PCAP 2 Analysis | *WannaCry/EternalBlue* — auto-downloaded, analyzed offline with `-r` |
| 6 | Comparative Analysis | Side-by-side charts, alert/protocol comparison between the two PCAPs |
| 7 | Technical Report Template | Guided questions for the student's written report |

> This notebook is self-contained and portable: it auto-detects whether it's running on Vagrant, Google Colab, or a generic machine, and downloads both PCAPs itself — no manual file placement needed (an internet connection is required).

#### Legacy notebooks (Spanish only)

<details>
<summary>SURI_CALDERA_ADVERSARY_PRACTICE.ipynb — combined Red+Blue lab (12 sections)</summary>

| # | Section | Description |
|---|---------|-------------|
| 1 | Environment Setup | Verify all services are running |
| 2 | Caldera Basics | Agents, adversaries, abilities |
| 3 | Suricata Fundamentals | Config, rules, log formats |
| 4 | First Operation – Recon | Discovery techniques |
| 5 | Real-Time Monitoring | Live Suricata stream |
| 6 | Multi-Technique Operation | Credential access + collection |
| 7 | Log Analysis with Python | pandas + matplotlib |
| 8 | Blue Team Perspective | Detection coverage analysis |
| 9 | Advanced Campaign | Persistence + lateral movement |
| 10 | Custom Rules | Writing Suricata rules |
| 11 | APT Case Study | Full campaign simulation |
| 12 | Export & Reporting | Generate JSON report |

</details>

<details>
<summary>SURI_IDS_MASTER-2.ipynb — offline PCAP analysis (V1, superseded by SURI_IDS_MASTER_V2)</summary>

| # | Section | Description |
|---|---------|-------------|
| 1 | Environment Validation | Dynamic path detection, Suricata install |
| 2 | suricata.yaml Review | HOME_NET/EXTERNAL_NET, rule paths, log outputs |
| 3 | suricata-update | Rule counts before/after, config validation |
| 4 | PCAP 1 Analysis | Webserver scans and probes — fast.log + eve.json |
| 5 | PCAP 2 Analysis | WannaCry/EternalBlue — fast.log + eve.json |
| 6 | Comparative Analysis | Side-by-side comparison, config proposals |
| 7 | Technical Report Template | Guided questions for student report |

</details>

---

## Troubleshooting

### VM won't start

```bash
vagrant up --debug 2>&1 | head -100
```

Check VirtualBox is installed and the nested virtualization is enabled if running inside another VM.

### Caldera not accessible

```bash
vagrant ssh caldera-server -c "sudo systemctl status caldera"
vagrant ssh caldera-server -c "sudo journalctl -u caldera --no-pager -n 50"
```

Remember the host-side URL is `http://localhost:18888`, not 8888.

### Suricata not detecting traffic

```bash
vagrant ssh caldera-server -c "sudo systemctl status suricata"
vagrant ssh caldera-server -c "sudo journalctl -u suricata --no-pager -n 50"
# Check interface
vagrant ssh caldera-server -c "ip route | grep default"
```

### Jupyter not loading

```bash
vagrant ssh caldera-server -c "sudo systemctl status jupyter"
# Restart
vagrant ssh caldera-server -c "sudo systemctl restart jupyter"
```

### Sandcat agent won't register

- Confirm `caldera-agent` can reach the server: `vagrant ssh caldera-agent -c "ping -c2 192.168.56.10"`
- Re-run the `curl`/`sandcat` deployment commands from [Deploying the Sandcat agent](#deploying-the-sandcat-agent-red-team-lab-only) — the agent talks to Caldera over the private network (`192.168.56.10:8888`), not the forwarded host port.

### Re-run provisioning

```bash
vagrant provision caldera-server
```

### Start from scratch

```bash
vagrant destroy -f && vagrant up
```

---

## OVA Export

See [EXPORT_TO_OVA.md](EXPORT_TO_OVA.md) for complete step-by-step instructions.

**Quick summary:**

1. Complete `vagrant up` and verify everything works
2. In VirtualBox Manager: select **SURI-CALDERA-IDS-LABV3** (the `caldera-server` VM) → File → Export Appliance
3. Choose OVF 2.0 format, output file `SURI-CALDERA-LAB.ova`
4. Share the `.ova` file with students
5. Students: File → Import Appliance → run notebook

> The `caldera-agent` VM is not part of the OVA — it's a disposable Sandcat target students can recreate locally with `vagrant up caldera-agent`, or any other Linux box on the same network, if they only need the OVA for the Blue Team / IDS notebook.

---

## Expected Learning Outcomes

After completing this lab, students will be able to:

**Red Team Emulation (CALDERA_RED_TEAM_PRACTICE_V2_EN.ipynb):**
- ✅ Understand the MITRE ATT&CK framework and Caldera's architecture (agents, abilities, adversaries, planners)
- ✅ Deploy a Sandcat agent and operate MITRE Caldera for adversary emulation
- ✅ Design multi-tactic attack chains (Discovery → Credential Access → Execution → Collection)
- ✅ Establish persistence, perform lateral movement, and simulate data exfiltration
- ✅ Analyze operation results with Python (pandas, matplotlib/seaborn)
- ✅ Understand the attacker/defender duality in cybersecurity

**Blue Team / IDS Analysis (SURI_IDS_MASTER_V2_EN.ipynb):**
- ✅ Interpret and modify `/etc/suricata/suricata.yaml` (HOME_NET, EXTERNAL_NET, rule paths)
- ✅ Update and validate Suricata rules with `suricata-update`
- ✅ Run Suricata in offline mode (`-r`) against real-world PCAP captures
- ✅ Extract and interpret alerts from `fast.log` and `eve.json`
- ✅ Compare threat profiles between web-scan traffic and ransomware (WannaCry/EternalBlue)
- ✅ Propose configuration optimizations to reduce false positives without losing coverage
- ✅ Write a structured technical security incident report

---

## License

This lab is intended for educational use only. MITRE Caldera and Suricata are open-source tools with their own respective licenses. Refer to their official repositories for license details.
