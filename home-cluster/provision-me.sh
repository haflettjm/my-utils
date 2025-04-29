#!/bin/bash
## Supports (Fedora && Redhat)

set -e  # Exit immediately if a command exits with a non-zero status.

# Variables
USER_NAME="admin"  # (main non-root user)

echo "🔧 Updating system..."
dnf update -y

echo "🔧 Installing base tools..."
dnf install -y vim curl wget git net-tools htop iptables socat chrony bash-completion
echo 'export EDITOR=vim' >> ~/.bashrc

echo "🔧 Installing Ansible..."
# Enable Ansible repo
dnf install -y ansible-core

echo "🔧 Installing KVM and virtualization tools..."
dnf install -y qemu-kvm libvirt virt-install bridge-utils libvirt-daemon-config-network virt-manager virt-top cockpit-machines

echo "🔧 Starting and enabling libvirtd..."
systemctl enable --now libvirtd
systemctl enable --now virtlogd

echo "🔧 Adding user to libvirt and kvm groups..."
usermod -aG libvirt,kvm $USER_NAME

echo "🔧 Setting up SSH server for remote Ansible management..."
systemctl enable --now sshd

echo "🔧 Disabling swap (required for Kubernetes later)..."
swapoff -a
sed -i '/swap/d' /etc/fstab

echo "🔧 Enabling IP forwarding..."
cat <<EOF > /etc/sysctl.d/99-sysctl.conf
net.ipv4.ip_forward = 1
EOF
sysctl --system

echo "🔧 Enabling time synchronization..."
systemctl enable --now chronyd

echo "✅ Fedora machine is now ready with:"
echo "- Ansible installed"
echo "- Hypervisor (KVM) ready"
echo "- SSH ready"
echo "- Swap disabled"
echo "- IP forwarding enabled"

echo "🔔 Reboot is recommended to apply all group changes (especially libvirt/kvm groups)"
