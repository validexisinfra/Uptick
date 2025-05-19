# Uptick
Uptick Network builds business-grade NFT infrastructure, offering a marketplace and diverse ecosystem applications to support the NFT economy.

# 🌟 Uptick Setup & Upgrade Scripts

A collection of automated scripts for setting up and upgrading Uptick nodes on **Mainnet (`uptick_117-1`)**.

---

### ⚙️ Validator Node Setup  
Install a Uptick validator node with custom ports, snapshot download, and systemd service configuration.

~~~bash
source <(curl -s https://raw.githubusercontent.com/validexisinfra/Uptick/main/installmain.sh)
~~~
---

### 🔄 Validator Node Upgrade 
Upgrade your Uptick node binary and safely restart the systemd service.

~~~bash
source <(curl -s https://raw.githubusercontent.com/validexisinfra/Uptick/main/upgrademain.sh)
~~~

---

### 🧰 Useful Commands

| Task            | Command                                 |
|-----------------|------------------------------------------|
| View logs       | `journalctl -u uptickd -f -o cat`        |
| Check status    | `systemctl status uptickd`              |
| Restart service | `systemctl restart uptickd`             |
