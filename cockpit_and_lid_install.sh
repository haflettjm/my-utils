#!/bin/bash

# Install Cockpit
sudo dnf install -y cockpit

# Enable and start Cockpit
sudo systemctl enable --now cockpit.socket

# Open firewall port (optional)
sudo firewall-cmd --add-service=cockpit --permanent
sudo firewall-cmd --reload

echo "Cockpit is running. Access it at https://localhost:9090"
CONFIG_FILE="/etc/systemd/logind.conf"

# Backup the config file
sudo cp $CONFIG_FILE ${CONFIG_FILE}.bak

# Change or add these values
sudo sed -i 's/^#*\(HandleLidSwitch\s*=\s*\).*/\1ignore/' $CONFIG_FILE
sudo sed -i 's/^#*\(HandleLidSwitchDocked\s*=\s*\).*/\1ignore/' $CONFIG_FILE

# If not present, append the settings
grep -q "^HandleLidSwitch=" $CONFIG_FILE || echo "HandleLidSwitch=ignore" | sudo tee -a $CONFIG_FILE
grep -q "^HandleLidSwitchDocked=" $CONFIG_FILE || echo "HandleLidSwitchDocked=ignore" | sudo tee -a $CONFIG_FILE

# Restart systemd-logind to apply changes
sudo systemctl restart systemd-logind

echo "Lid close behavior set to 'ignore'. Laptop will not suspend when closed."

