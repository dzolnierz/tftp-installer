#!/bin/sh

# Customize APT
cat <<-EOF | tee /etc/apt/apt.conf.d/05recommended
APT::Install-Recommends "false";
APT::Install-Suggests "false";
EOF

# Create wheel group
groupadd -g 11 wheel

# Install needed packages
export DEBIAN_FRONTEND=noninteractive
apt-get install -q -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" openssh-server sudo lsb-release

# Customize configs
sed -i -e 's/^\(PermitRootLogin \).*/\1no/g' /etc/ssh/sshd_config

cat <<-EOF | tee /etc/sudoers.d/wheel
# Allow members of group wheel to execute any command
%wheel ALL=(ALL:ALL) NOPASSWD: ALL
EOF

chmod a-rwx,u+r,g+r /etc/sudoers.d/wheel

# Tune system
cat <<-EOF | tee /etc/sysctl.d/10-disable-ipv6.conf
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 0
EOF

# Enable hotplug
cat <<-EOF | tee /etc/udev/rules.d/80-hotplug-cpu-mem.rules
SUBSYSTEM=="cpu", ACTION=="add", TEST=="online", ATTR{online}=="0", ATTR{online}="1"
SUBSYSTEM=="memory", ACTION=="add", TEST=="state", ATTR{state}=="offline", ATTR{state}="online"
EOF

cat <<-EOF | tee /etc/modules-load.d/hotplug.conf 
acpiphp
pci_hotplug
EOF

# Create users
