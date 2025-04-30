#! /bin/bash

FEDORA_VERSION="42"
IM_DIR="$HOME/vm-images/"
BASE_URL="https://download.fedoraproject.org/pub/fedora/linux/releases/${FEDORA_VERSION}/Cloud/x86_64/images"
IM_NAME="Fedora-Cloud-Base-${FEDORA_VERSION}-1.5.x86_64.qcow2"
dnf update -y

mkdir -p "$IM_DIR"

# Check if image already exists
if [ -f "${IMAGE_DIR}/${IMAGE_NAME}" ]; then
    echo "✅ Image already exists at ${IMAGE_DIR}/${IMAGE_NAME}. Skipping download."
else
    echo "⬇️ Downloading Fedora Cloud image..."
    curl -L -o "${IM_DIR}/${IM_NAME}" "${BASE_URL}/${IM_NAME}"
    echo "✅ Download complete: ${IM_DIR}/${IM_NAME}"
fi

set -e  # Fail immediately if any command fails

# Services should already be started at this point
echo "⏳ Waiting 5 seconds for libvirt services to stabilize..."
sleep 5

# Check if virsh can list VMs
if ! virsh list --all >/dev/null 2>&1; then
    echo "❌ ERROR: virsh command failed. libvirt may not be running properly."
    exit 1
fi

# Check if virsh list returned output
VIRSH_OUTPUT=$(virsh list --all)
if [ -z "$VIRSH_OUTPUT" ]; then
    echo "❌ ERROR: virsh list returned no output. libvirt daemon may not be active."
    exit 1
else
    echo "✅ virsh list is working."
fi

# Check if default network is active
if ! virsh net-list | grep -q default; then
    echo "❌ ERROR: 'default' network not active. Please check libvirt networking."
    exit 1
else
    echo "✅ 'default' network is active."
fi
