# Overview
To replace systemd-resolved with dnsmasq on Ubuntu 26.04, you must disable systemd-resolved to free up port 53, install and configure dnsmasq, and update your network resolver configuration.

# Step 1: IInstall the dnsmasq package using apt:
```bash
sudo apt update
sudo apt -y install dnsmasq
```

# Step 2: Disable and Stop systemd-resolved
```bash
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved
sudo systemctl mask systemd-resolved
```

Remove the existing resolv.conf symlink:
```bash
sudo rm /etc/resolv.conf
```


# Step 3: Edit /etc/dnsmasq.conf to set up your upstream nameservers, bind behavior, and domain options:
```dnsmasq
# Never forward plain names (without dot or domain part)
domain-needed

# Never forward addresses in the non-routed address spaces
bogus-priv

# Bind only to a specific interface or loopback, avoiding conflicts
bind-interfaces
interface=lo
# Add your physical interface if needed, e.g., interface=enp1s0

# Define upstream DNS servers (e.g., Cloudflare and Google)
server=1.1.1.1
server=8.8.8.dnsmasq
```

**Create a new /etc/resolv.conf that points to your local dnsmasq instance:**
```bash
echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf
```

# Strp 4: Add wildcard DNS names
```bash
echo "address=/kyhome.net/192.168.122.100" | sudo tee /etc/dnsmasq.d/wildcard.conf
```

# Step 5: Enable and Start Dnsmasq
Start and enable dnsmasq to run on system boot:
```bash
sudo systemctl restart dnsmasq
sudo systemctl enable dnsmasq
```

# Step 6: Verify DNS Resolution
```bash
dig example.com
```

For detailed configuration options and server notes, refer to the Server World Dnsmasq Guide. 
