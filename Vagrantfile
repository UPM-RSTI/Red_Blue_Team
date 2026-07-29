# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Base box: Ubuntu 22.04 LTS (Jammy Jellyfish)
  config.vm.box = "ubuntu/jammy64"
  config.vm.box_version = ">= 0"

  # ── MÁQUINA 1: Servidor Caldera + Suricata ──────────────────────────────────
  config.vm.define "caldera-server" do |server|
    server.vm.hostname = "suri-caldera-lab"

    # Network
    server.vm.network "private_network", ip: "192.168.56.10"

    # Forwarded ports
    server.vm.network "forwarded_port", guest: 8888, host: 18888
    server.vm.network "forwarded_port", guest: 8889, host: 8889
    server.vm.network "forwarded_port", guest: 22,   host: 2223, id: "ssh"
    server.vm.network "forwarded_port", guest: 5000, host: 5000

    # Shared folder
    server.vm.synced_folder ".", "/vagrant", type: "rsync"

    # VirtualBox provider
    server.vm.provider "virtualbox" do |vb|
      vb.name   = "SURI-CALDERA-IDS-LABV3"
      vb.memory = 4096
      vb.cpus   = 2
      vb.gui    = false

      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      vb.customize ["modifyvm", :id, "--ioapic", "on"]
      vb.customize ["modifyvm", :id, "--vram", "16"]
    end

    # VMware Desktop provider
    server.vm.provider "vmware_desktop" do |vmware|
      vmware.vmx["memsize"] = "4096"
      vmware.vmx["numvcpus"] = "2"
    end

    # Disk resize
    if Vagrant.has_plugin?("vagrant-disksize")
      server.disksize.size = "20GB"
    end

    # Provisioning
    server.vm.provision "file",
      source:      "vagrant/config",
      destination: "/tmp/config"

    server.vm.provision "file",
      source:      "vagrant/scripts",
      destination: "/tmp/scripts"

    server.vm.provision "file",
      source:      "notebooks",
      destination: "/tmp/notebooks"

    server.vm.provision "shell",
      path:       "vagrant/provision.sh",
      privileged: true

    server.vm.post_up_message = <<~MSG
      ╔══════════════════════════════════════════════════════════════╗
      ║          SURI-CALDERA IDS PRACTICE LAB - READY!             ║
      ╠══════════════════════════════════════════════════════════════╣
      ║  Caldera  → http://localhost:18888                          ║
      ║             user: admin  /  password: admin                 ║
      ║  Jupyter  → http://localhost:8889                           ║
      ║  SSH      → vagrant ssh caldera-server                      ║
      ║           (or ssh -p 2223 vagrant@127.0.0.1)               ║
      ╠══════════════════════════════════════════════════════════════╣
      ║  Service commands (inside VM):                              ║
      ║    sudo systemctl status  caldera                           ║
      ║    sudo systemctl status  suricata                          ║
      ║    sudo systemctl status  jupyter                           ║
      ╠══════════════════════════════════════════════════════════════╣
      ║  Health check:  sudo /opt/scripts/check_services.sh         ║
      ╚══════════════════════════════════════════════════════════════╝
    MSG
  end

  # ── MÁQUINA 2: Agente Caldera ───────────────────────────────────────────────
  config.vm.define "caldera-agent" do |agent|
    agent.vm.box = "ubuntu/jammy64"
    agent.vm.box_version = ">= 0"

    agent.vm.hostname = "caldera-agent"

    # Network
    agent.vm.network "private_network", ip: "192.168.56.11"

    # SSH port forwarding (host 2224 -> guest 22)
    agent.vm.network "forwarded_port", guest: 22, host: 2224, id: "ssh"

    # Shared folder
    agent.vm.synced_folder ".", "/vagrant", type: "rsync"

    # VirtualBox provider
    agent.vm.provider "virtualbox" do |vb|
      vb.name   = "CALDERA-AGENT-NODE"
      vb.memory = 2048
      vb.cpus   = 2
      vb.gui    = false

      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      vb.customize ["modifyvm", :id, "--ioapic", "on"]
      vb.customize ["modifyvm", :id, "--vram", "16"]
    end

    # VMware Desktop provider
    agent.vm.provider "vmware_desktop" do |vmware|
      vmware.vmx["memsize"] = "2048"
      vmware.vmx["numvcpus"] = "2"
    end

    # Disk resize
    if Vagrant.has_plugin?("vagrant-disksize")
      agent.disksize.size = "15GB"
    end

    agent.vm.post_up_message = <<~MSG
      ╔══════════════════════════════════════════════════════════════╗
      ║            CALDERA AGENT NODE - READY!                      ║
      ╠══════════════════════════════════════════════════════════════╣
      ║  IP Address   → 192.168.56.11                               ║
      ║  Hostname     → caldera-agent                               ║
      ║  SSH          → vagrant ssh caldera-agent                   ║
      ║               (or ssh -p 2224 vagrant@127.0.0.1)            ║
      ╠══════════════════════════════════════════════════════════════╣
      ║  Network communication with caldera-server:                 ║
      ║    ping 192.168.56.10  (or ping suri-caldera-lab)           ║
      ╚══════════════════════════════════════════════════════════════╝
    MSG
  end
end
