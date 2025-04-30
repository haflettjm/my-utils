#!/bin/bash

# Define your hypervisors
HOSTS=(
  "192.168.4.242"
  # "192.168.4.99"
  # "192.168.4.112"
  # "192.168.4.98"
)

# Local paths to your scripts
SCRIPT1="vm-prep.sh"
SCRIPT2="clevusluks.sh"

# Remote directory to copy the scripts to
REMOTE_PATH="~/admin"

# Loop through each host
for HOST in "${HOSTS[@]}"; do
  echo "📤 Copying scripts to $HOST..."

  scp "./$SCRIPT1" "./$SCRIPT2" admin@"$HOST":"$REMOTE_PATH"/

  echo "🚀 Running scripts on $HOST..."

  ssh -tt admin@"$HOST" "
    chmod +x $REMOTE_PATH/$SCRIPT1 $REMOTE_PATH/$SCRIPT2 &&
    sudo bash $REMOTE_PATH/$SCRIPT1 &&
    sudo bash $REMOTE_PATH/$SCRIPT2 &&
    sudo reboot
  "

  echo "✅ Finished on $HOST."
done
