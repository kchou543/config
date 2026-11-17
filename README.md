# Deploy K3S on Alpine

## Step 1: Install Alpine from ISO

- Download the standard or virtual x86_64 ISO file.
- Write the ISO to a USB flash drive (using a tool like Rufus) or mount it to a virtual machine (VMware, QEMU, or VirtualBox).
- Boot your machine from the ISO (make sure Secure Boot is disabled in your BIOS if needed).
- At the login prompt, log in as root with no password.

## Step 2: Run the Setup Script

- Type the following command to start the interactive installer:

  **bash**
  ```
  setup-alpine
  ```
Use code with caution.
- Follow the prompts to configure your system:
	- Keymap & Variant: Select your keyboard layout (e.g., us).
	- Hostname: Enter a name for your machine (e.g., alpine-host).
	- Network: Choose your network interface (e.g., eth0) and select DHCP or configure a static IP.
	- Root Password: Enter and confirm a strong password for the root user.
	- Timezone: Select your local timezone (e.g., Asia/Singapore or UTC).
	- Proxy / NTP: Choose your HTTP proxy (usually none) and NTP client (e.g., chrony or busybox).
	- APK Mirror: Type f to automatically detect and select the fastest package mirror.
	- SSH Server: Choose your preferred SSH server (e.g., openssh).
	- Disk Installation: Select your target storage drive (e.g., sda or vda) and choose sys for a traditional full disk installation (or data/lvm if you have specific needs).
	- Confirm the prompt to erase the disk and write the system.

- For cloned VM
    - Change hostname
      ```
      $ vi /etc/hostname 
      $ vi /etc/hhosts 
      $ hostname -F /etc/hostname
      ```
    - Change ip address
      ```
      $ vi /etc/network/interface  
      $ /etc/init.d/networking restart 
      ```
    - Renew ssh host keys
      ```
      $ cd /etc/ssh 
      $ rm ssh_host_* 
      $ ssh-keygen -A 
      ```

## Step 3: Install Chrony
  ```
  $ apk add chrony
  $ vi /etc/chrony/chrony.conf 
    #pool pool.ntp.org iburst
    server 192.168.122.1 iburst
  $ rc-update add chronyd default
  $ rc-service chronyd start
  $ rc-service chronyd status
  ```

  **verify**
  ```
  chronyc sources -v
  chronyc tracking
  ```
  
## Step 4: Install k3S 

**update-extlinux**
```
$ apk add --no-cache curl
$ echo "cgroup2 /sys/fs/cgroup cgroup2 rw,nosuid,nodev,noexec,relatime,nsdelegate 0 0" >> /etc/fstab

$ cat > /etc/cgconfig.conf <<EOF
mount {
  cpuacct = /cgroup/cpuacct;
  memory = /cgroup/memory;
  devices = /cgroup/devices;
  freezer = /cgroup/freezer;
  net_cls = /cgroup/net_cls;
  blkio = /cgroup/blkio;
  cpuset = /cgroup/cpuset;
  cpu = /cgroup/cpu;
}
EOF

$ sed -i 's/default_kernel_opts="pax_nouderef quiet rootfstype=ext4"/default_kernel_opts="pax_nouderef quiet rootfstype=ext4 cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory"/g' /etc/update-extlinux.conf

$ update-extlinux
$ reboot
```

**cni-plugins**
```
$ apk add --no-cache cni-plugins --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community
$ export PATH=$PATH:/usr/share/cni-plugins/bin
$ echo -e '#!/bin/sh\nexport PATH=$PATH:/usr/share/cni-plugins/bin' > /etc/profile.d/cni.sh
$ apk add iptables
```

**install k3s**
```
$ curl -sfL https://get.k3s.io | sh -
```

**install k3s on agent/worker node**
```
curl -sfL https://get.k3s.io | K3S_URL=https://192.168.122.51:6443 K3S_TOKEN=K10514e27dc751663b798dd9ef0adcb26f68766bebcb2dc1b2af9a669b0595b4373::server:ea26f9838b3a4c3f1089497005ca2a2b sh -
```

## Step 5: NFS  
install nfs on ubuntu 
export the folder
**install nfs client on k3s server and agent node**
```
apk update
apk add nfs-utils
rc-update add nfsmount
rc-service nfsmount start
```
**install helm**  
ref: https://helm.sh/docs/intro/install/
```
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm repo update 
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --create-namespace \
    --namespace nfs-provisioner \
    --set nfs.server=192.168.122.1 \
    --set nfs.path=/data/persist \
    --set storageClass.name=nfs-client \
    --set storageClass.defaultClass=true
```
**disable local-path**
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'