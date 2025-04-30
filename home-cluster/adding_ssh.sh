HOSTS=(
  "192.168.4.242"
  "192.168.4.99"
  "192.168.4.112"
  "192.168.4.98"
)
for HOST in "${HOSTS[@]}"; do
    #ssh-copy-id  -i ~/.ssh/id_ed25519.pub admin@"$HOST"
    echo "🔐 Enabling passwordless sudo on $host..."

    ssh -tt admin@"$HOST" << 'EOF'
        echo "admin ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/99-admin-nopasswd > /dev/null
        sudo chmod 440 /etc/sudoers.d/99-admin-nopasswd
        echo "✅ Passwordless sudo enabled."
EOF

    echo "Can connect to $HOST"
done
