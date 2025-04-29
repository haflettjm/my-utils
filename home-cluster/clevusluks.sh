#!/bin/bash
set -euo pipefail

echo "[*] Detecting root LUKS device..."
ROOT_DEVICE=$(findmnt -no SOURCE /)
LUKS_UUID=$(lsblk -no UUID "$ROOT_DEVICE")

CRYPTTAB="/etc/crypttab"

echo "[*] LUKS UUID detected: $LUKS_UUID"

echo "[*] Checking for existing Clevis binding..."
if sudo clevis luks list -d "$ROOT_DEVICE" | grep -q "tpm2"; then
    echo "[+] Clevis already bound to TPM2 on $ROOT_DEVICE."
else
    echo "[*] Binding Clevis to TPM2 on $ROOT_DEVICE..."
    sudo clevis luks bind -d "$ROOT_DEVICE" tpm2 '{}' -k
fi

echo "[*] Ensuring crypttab is correct..."
if grep -q "$LUKS_UUID" "$CRYPTTAB"; then
    echo "[*] crypttab entry found. No modifications needed."
else
    echo "[!] No matching crypttab entry. Please fix manually."
    exit 1
fi

echo "[*] Setting up early boot Clevis unlock for dracut..."
sudo tee /etc/dracut.conf.d/clevis-unlock.conf > /dev/null <<EOF
add_dracutmodules+=" clevis "
install_items+=" /usr/libexec/clevis-luks-askpass /usr/bin/clevis "
early_microcode=yes
force_drivers+=" tpm_crb tpm_tis_core "
EOF

echo "[*] Rebuilding initramfs with clevis unlock support..."
sudo dracut -fv --regenerate-all

echo "[+] Clevis TPM2 unlock setup complete. Please reboot to test."
