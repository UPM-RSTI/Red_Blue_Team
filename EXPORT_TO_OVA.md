# Exporting the Lab to OVA Format

This guide explains how to export the configured VM to an OVA file for distribution
and how recipients can import and run it without needing to provision anything.

---

## For Teachers / Lab Administrators

### Prerequisites

- VirtualBox ≥ 7.0 installed
- Lab VM fully provisioned (`vagrant up` completed successfully)
- ~15 GB free disk space for the export

---

### Step 1: Verify the Lab is Working

```bash
# Inside the repository directory on your host:
vagrant ssh -c "sudo /opt/scripts/check_services.sh"
```

All services (caldera, suricata, jupyter) should show **active**.

---

### Step 2: Clean Up Before Export (Optional but Recommended)

SSH into the VM and remove unnecessary files to reduce OVA size:

```bash
vagrant ssh

# Inside the VM:
sudo apt-get clean
sudo apt-get autoremove -y
sudo rm -rf /tmp/*
sudo rm -rf /var/log/*.gz /var/log/*.1
sudo truncate -s 0 /var/log/suricata/eve.json
sudo truncate -s 0 /var/log/suricata/fast.log
sudo dd if=/dev/zero of=/EMPTY bs=1M 2>/dev/null || true
sudo rm -f /EMPTY
sudo sync

# Exit the VM
exit
```

---

### Step 3: Halt the VM

```bash
# On your host machine (in the repo directory):
vagrant halt
```

**Important:** The VM must be powered off (not suspended) before exporting.

---

### Step 4: Export from VirtualBox

#### Option A: Using the VirtualBox GUI

1. Open **VirtualBox Manager**
2. Find the VM named **SURI-CALDERA-IDS-LAB**
3. Go to **File → Export Appliance...** (or right-click → Export)
4. Select the VM and click **Next**
5. Configure the export:
   - **Format:** OVF 2.0
   - **File:** `SURI-CALDERA-LAB.ova` (choose a location with enough free space)
   - **MAC Address Policy:** Strip all network adapter MAC addresses (recommended)
6. Click **Next**, review the appliance settings
7. Click **Export** and wait (~5-15 minutes depending on disk speed)

#### Option B: Using the VBoxManage CLI

```bash
# Find the VM UUID
VBoxManage list vms | grep SURI-CALDERA

# Export to OVA (replace VM_UUID with the actual UUID or name)
VBoxManage export "SURI-CALDERA-IDS-LAB" \
  --output "SURI-CALDERA-LAB.ova" \
  --ovf20 \
  --manifest \
  --vsys 0 \
    --product "SURI-CALDERA IDS Practice Lab" \
    --producturl "https://github.com/xavierlarrivaUPM/SURI-CALDERA-IDS-PRACTICE" \
    --vendor "UPM" \
    --version "1.0" \
    --description "MITRE Caldera + Suricata IDS Practice Lab"
```

---

### Step 5: Distribute the OVA File

The resulting `SURI-CALDERA-LAB.ova` file (approximately 8-12 GB) can be shared via:

- USB drive
- Network file share / LAN
- Cloud storage (Google Drive, OneDrive, etc.)
- Institutional platforms (Moodle, etc.)

---

## For Students / Recipients

### Prerequisites

- VirtualBox ≥ 7.0 installed: https://www.virtualbox.org/wiki/Downloads
- ~15 GB free disk space

### Step 1: Import the OVA

#### Option A: VirtualBox GUI

1. Open **VirtualBox Manager**
2. Go to **File → Import Appliance...**
3. Browse to the `SURI-CALDERA-LAB.ova` file
4. Click **Next**
5. Review the appliance settings:
   - Name: `SURI-CALDERA-IDS-LAB`
   - RAM: 4096 MB (adjust if your host has less than 8 GB total)
   - CPU: 2 cores
6. Click **Import** and wait (~3-5 minutes)

#### Option B: VBoxManage CLI

```bash
VBoxManage import SURI-CALDERA-LAB.ova \
  --vsys 0 --vmname "SURI-CALDERA-IDS-LAB" \
  --vsys 0 --memory 4096 \
  --vsys 0 --cpus 2
```

---

### Step 2: Configure Port Forwarding (if not pre-configured in OVA)

If the forwarded ports are missing after import:

```bash
VBoxManage modifyvm "SURI-CALDERA-IDS-LAB" \
  --nat-pf1 "caldera,tcp,,8888,,8888" \
  --nat-pf1 "jupyter,tcp,,8889,,8889" \
  --nat-pf1 "ssh,tcp,,2222,,22"
```

---

### Step 3: Start the VM

#### Option A: VirtualBox GUI
- Select **SURI-CALDERA-IDS-LAB** → click **Start** (Headless start recommended)

#### Option B: CLI
```bash
VBoxManage startvm "SURI-CALDERA-IDS-LAB" --type headless
```

Wait ~60 seconds for all services to start.

---

### Step 4: Open the Lab

| Service | URL | Login |
|---------|-----|-------|
| Caldera | http://localhost:8888 | admin / admin |
| Jupyter | http://localhost:8889 | (no password) |

In Jupyter, open `SURI_CALDERA_ADVERSARY_PRACTICE.ipynb` and start the lab!

---

### Step 5: SSH Access (optional)

```bash
ssh -p 2222 vagrant@localhost
# password: vagrant
```

---

### Step 6: Shutdown

#### Option A: From inside the VM
```bash
sudo shutdown -h now
```

#### Option B: VBoxManage
```bash
VBoxManage controlvm "SURI-CALDERA-IDS-LAB" acpipowerbutton
```

---

## Disk Space Requirements

| Item | Size |
|------|------|
| OVA file (compressed) | ~8-12 GB |
| Imported VM disk | ~15-18 GB |
| Running VM RAM | 4 GB |
| Recommended free host disk | 25 GB |

---

## Performance Recommendations

- **RAM**: If your host has 16+ GB, increase VM RAM to 6-8 GB for better performance
- **CPU**: Allocate 4 vCPUs if your host has 8+ cores
- **Storage**: Use an SSD host disk for significantly faster provisioning and operation
- **Display**: Use headless mode to save host GPU resources

To change RAM/CPU after import in VirtualBox GUI:
Settings → System → Motherboard (RAM) / Processor (CPU)

---

## Troubleshooting Import Issues

### "Cannot import appliance" error
- Make sure VirtualBox is up to date (≥ 7.0)
- Try importing with `--vsys 0 --ignore-legacy-settings`

### VM starts but services are not running
```bash
ssh -p 2222 vagrant@localhost
sudo /opt/scripts/start_services.sh
sudo /opt/scripts/check_services.sh
```

### Port 8888 or 8889 already in use on host
Change the host-side port in VirtualBox → Settings → Network → Port Forwarding:
- e.g. change host port `8888` → `18888`
- Then access Caldera at `http://localhost:18888`
