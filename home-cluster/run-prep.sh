#!/bin/bash

# Define your hypervisors
HOSTS=(
  "192.168.4.242"
  # "192.168.4.99"
  "192.168.4.112"
  "192.168.4.98"
)

# Path to your local vm-prep script
SCRIPT_PATH="vm-prep.sh"

SCRIPT_PATH2="clevusluks.sh"

# Remote path to copy the script to
REMOTE_PATH="/home/admin"

# Loop through each host
for HOST in "${HOSTS[@]}"; do
  echo "📤 Copying vm-prep.sh to $HOST..."
  scp "./$SCRIPT_PATH" admin@"$HOST":./"$REMOTE_PATH"/$SCRIPT_PATH

  scp "./$SCRIPT_PATH2" admin@"$HOST":./"$REMOTE_PATH"/"$SCRIPT_PATH2"
  scp "$SCRIPT_PATH" admin@"$HOST":"$REMOTE_PATH"
  echo "🚀 Running vm-prep.sh on $HOST..."
  ssh admin@"$HOST" "chmod +x $REMOTE_PATH/$SCRIPT_PATH && sudo bash $REMOTE_PATH/$SCRIPT_PATH2"
  ssh admin@"$HOST" "chmod +x $REMOTE_PATH/$SCRIPT_PATH2 && sudo bash $REMOTE_PATH/$SCRIPT_PATH2"
  ssh admin@"$HOST" "sudo reboot"
  echo "✅ Finished on $HOST."
done
