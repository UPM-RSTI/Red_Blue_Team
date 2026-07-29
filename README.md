# SURI-CALDERA IDS Practice Lab

> **Adversary Emulation & Intrusion Detection – MITRE Caldera + Suricata**

A production-ready Vagrant-based lab environment for learning offensive and defensive cybersecurity using MITRE Caldera and Suricata IDS.

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Start](#quick-start)
3. [VM Specifications](#vm-specifications)
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
- RAM: 8 GB minimum (4 GB reserved for the VM)
- Disk: 25 GB free space
- CPU: 4 cores recommended (2 dedicated to the VM)

---

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/xavierlarrivaUPM/SURI-CALDERA-IDS-PRACTICE.git
cd SURI-CALDERA-IDS-PRACTICE

# 2. Start the VM (first time: ~15-20 minutes for provisioning)
vagrant up

# 3. Open the lab in your browser
#    Caldera:  http://localhost:8888   (admin / admin)
#    Jupyter:  http://localhost:8889

# 4. SSH into the VM (optional)
vagrant ssh

# 5. Shutdown when done
vagrant halt

# 6. Destroy the VM (removes all data)
vagrant destroy
```

---

## VM Specifications

| Parameter | Value |
|-----------|-------|
| Base OS   | Ubuntu 22.04 LTS (Jammy) |
| vCPU      | 2 cores |
| RAM       | 4096 MB |
| Disk      | 20 GB |
| Network   | Private 192.168.56.10 + forwarded ports |

**Forwarded Ports:**

| Service | Guest Port | Host Port |
|---------|-----------|-----------|
| Caldera Web UI | 8888 | 8888 |
| Jupyter Notebook | 8889 | 8889 |
| SSH | 22 | 2222 |
| Suricata API (optional) | 5000 | 5000 |

---

## Access URLs & Credentials

| Service | URL | Username | Password |
|---------|-----|----------|----------|
| Caldera Web | http://localhost:8888 | `admin` | `admin` |
| Caldera REST API | http://localhost:8888/api/v2 | API Key | `REDADMIN123` |
| Jupyter Notebook | http://localhost:8889 | — | (no password) |
| VM SSH | `vagrant ssh` | `vagrant` | `vagrant` |
| Student user | SSH | `student` | `student` |

> ⚠️ **Security note:** This lab uses simplified credentials on purpose. Never expose it to the internet. It is designed for isolated networks only.

---

## Service Management

Run these commands **inside the VM** (`vagrant ssh`):

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

---

## Lab Structure

```
SURI-CALDERA-IDS-PRACTICE/
├── README.md                          # This file
├── Vagrantfile                        # VM configuration
├── requirements.txt                   # Python dependencies
├── EXPORT_TO_OVA.md                  # OVA export instructions
├── vagrant/
│   ├── provision.sh                   # Main provisioning orchestrator
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
    ├── SURI_CALDERA_ADVERSARY_PRACTICE.ipynb   # Adversary emulation lab (Caldera + Suricata live)
    └── SURI_IDS_MASTER-2.ipynb                 # IDS offline PCAP analysis lab (Suricata + fast.log/eve.json)
```

---

## Workflow for Students

### Option A: Vagrant (recommended)

```
vagrant up → open http://localhost:8889 → run notebook cells
```

### Option B: Imported OVA

```
Import OVA in VirtualBox → Start VM → open http://localhost:8889
```

### Notebook Sections

#### SURI_CALDERA_ADVERSARY_PRACTICE.ipynb — Adversary Emulation Lab

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

#### SURI_IDS_MASTER-2.ipynb — Offline PCAP Analysis Lab

| # | Section | Description |
|---|---------|-------------|
| 1 | Environment Validation | Dynamic path detection, Suricata install |
| 2 | suricata.yaml Review | HOME_NET/EXTERNAL_NET, rule paths, log outputs |
| 3 | suricata-update | Rule counts before/after, config validation |
| 4 | PCAP 1 Analysis | Webserver scans and probes — fast.log + eve.json |
| 5 | PCAP 2 Analysis | WannaCry/EternalBlue — fast.log + eve.json |
| 6 | Comparative Analysis | Side-by-side comparison, config proposals |
| 7 | Technical Report Template | Guided questions for student report |

---

## Troubleshooting

### VM won't start

```bash
vagrant up --debug 2>&1 | head -100
```

Check VirtualBox is installed and the nested virtualization is enabled if running inside another VM.

### Caldera not accessible

```bash
vagrant ssh -c "sudo systemctl status caldera"
vagrant ssh -c "sudo journalctl -u caldera --no-pager -n 50"
```

### Suricata not detecting traffic

```bash
vagrant ssh -c "sudo systemctl status suricata"
vagrant ssh -c "sudo journalctl -u suricata --no-pager -n 50"
# Check interface
vagrant ssh -c "ip route | grep default"
```

### Jupyter not loading

```bash
vagrant ssh -c "sudo systemctl status jupyter"
# Restart
vagrant ssh -c "sudo systemctl restart jupyter"
```

### Re-run provisioning

```bash
vagrant provision
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
2. In VirtualBox Manager: select **SURI-CALDERA-IDS-LAB** → File → Export Appliance
3. Choose OVF 2.0 format, output file `SURI-CALDERA-LAB.ova`
4. Share the `.ova` file with students
5. Students: File → Import Appliance → run notebook

---

## Expected Learning Outcomes

After completing this lab, students will be able to:

**Adversary Emulation (SURI_CALDERA_ADVERSARY_PRACTICE.ipynb):**
- ✅ Understand the MITRE ATT&CK framework and how it maps to real attacks
- ✅ Deploy and operate MITRE Caldera for adversary emulation
- ✅ Configure and use Suricata as a network IDS
- ✅ Create custom Suricata detection rules
- ✅ Analyze `eve.json` logs with Python (pandas, matplotlib)
- ✅ Correlate attack techniques with IDS alerts
- ✅ Measure detection coverage and identify gaps
- ✅ Generate security incident reports
- ✅ Understand the attacker/defender duality in cybersecurity

**Offline PCAP Analysis (SURI_IDS_MASTER-2.ipynb):**
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