#! /bin/bash

FEDORA_VERSION="42"
IM_DIR="$HOME/vm-images/"
BASE_URL="https://download.fedoraproject.org/pub/fedora/linux/releases/${FEDORA_VERSION}/Cloud/x86_64/images"
dnf update -y
# Download Server Image
curl
# Do whatever needed done for ansible
