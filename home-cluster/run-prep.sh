#!/bin/bash

# Define your hypervisors
HOSTS=(
  "192.168.4.10"
  "192.168.4.11"
  "192.168.4.12"
  "192.168.4.13"
)

# Path to your local vm-prep script
SCRIPT_PATH="./vm-prep.sh"

# Remote path to copy the script to
REMOTE_PATH="/home/admin/vm-prep.sh"

# Loop through each host
for HOST in "${HOSTS[@]}"; do
  echo "📤 Copying vm-prep.sh to $HOST..."
  scp "$SCRIPT_PATH" admin@"$HOST":"$REMOTE_PATH"

  echo "🚀 Running vm-prep.sh on $HOST..."
  ssh admin@"$HOST" "chmod +x $REMOTE_PATH && sudo bash $REMOTE_PATH"

  echo "✅ Finished on $HOST."
done
