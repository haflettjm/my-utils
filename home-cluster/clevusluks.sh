#!/bin/bash
set -euo pipefail

echo "[*] Installing Clevis and TPM2 tools..."
sudo dnf install -y clevis clevis-luks clevis-systemd clevis-dracut clevis-udisks2 clevis-pin-tpm2 tpm2-tools

echo "[*] Locating encrypted root device..."

# Step 1: Get the device mapped to /
ROOT_MAPPER=$(findmnt -n -o SOURCE /)
echo "[*] Root mapper: $ROOT_MAPPER"

# Step 2: Use lsblk to walk up to the crypt parent
ROOT_LUKS_DEVICE=$(lsblk -no NAME,TYPE -r | awk -v target="${ROOT_MAPPER##*/}" '
{
  device=$1; type=$2
  if (type == "lvm") {
    lvms[device] = 1
  }
  parents[device] = last
  last = device
}
END {
  for (dev in parents) {
    if (lvms[target] && parents[dev] == target && type == "crypt") {
      print "/dev/" dev
      exit
    }
  }
}
')

# BETTER: recursively trace up to TYPE=crypt parent
ROOT_LUKS_DEVICE=$(lsblk -pno NAME,TYPE "$ROOT_MAPPER" | awk '$2=="crypt" {print $1; exit}')

if [ -z "$ROOT_LUKS_DEVICE" ]; then
  echo "[!] Could not locate underlying LUKS device. Exiting."
  exit 1
fi

echo "[*] Underlying LUKS device: $ROOT_LUKS_DEVICE"

# Step 3: Proceed with clevis bind
LUKS_UUID=$(lsblk -no UUID "$ROOT_LUKS_DEVICE")
CRYPTTAB="/etc/crypttab"

echo "[*] LUKS UUID: $LUKS_UUID"

echo "[*] Checking for existing Clevis binding..."
if sudo clevis luks list -d "$ROOT_LUKS_DEVICE" | grep -q "tpm2"; then
    echo "[+] Clevis already bound to TPM2 on $ROOT_LUKS_DEVICE."
else
    echo "[*] Binding Clevis to TPM2 on $ROOT_LUKS_DEVICE..."
    sudo clevis luks bind -d "$ROOT_LUKS_DEVICE" tpm2 '{}' -k
fi

echo "[*] Checking /etc/crypttab..."
if grep -q "$LUKS_UUID" "$CRYPTTAB"; then
    echo "[*] crypttab entry exists."
else
    echo "[!] No matching crypttab entry found."
    exit 1
fi

echo "[*] Writing dracut Clevis config..."
sudo tee /etc/dracut.conf.d/clevis-unlock.conf > /dev/null <<EOF
add_dracutmodules+=" clevis "
install_items+=" /usr/libexec/clevis-luks-askpass /usr/bin/clevis "
early_microcode=yes
force_drivers+=" tpm_crb tpm_tis_core "
EOF

echo "[*] Rebuilding initramfs..."
sudo dracut -fv --regenerate-all

echo "[✅] Clevis TPM2 binding complete. Please reboot to test."
