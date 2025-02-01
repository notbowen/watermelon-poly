#!/bin/bash

# Update system and install dependencies (including OpenSSH server)
sudo apt-get update -y
sudo apt-get install -y nodejs npm apache2 git sqlite3 openssh-server

# Configure SSH: disable password and challenge–response authentication to allow only key-based logins
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/#ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
# Ensure public key authentication is enabled (usually the default)
sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Restart SSH to apply the new configuration
sudo systemctl restart ssh

# (Optional) Enable SSH service to start on boot
sudo systemctl enable ssh

# Clone repository
git clone https://github.com/notbowen/watermelon-poly.git
cd watermelon-poly

# Install Node dependencies
npm install

# Initialize database
sqlite3 watermelon.db < database.sql

# Configure Apache VirtualHost for watermelon.poly.edu
sudo bash -c 'cat > /etc/apache2/sites-available/watermelon.conf <<EOL
<VirtualHost *:80>
    ServerName watermelon.poly.edu
    DocumentRoot /var/www/html

    # Enable detailed logging of HTTP bodies
    DumpIOInput On
    DumpIOOutput On
    LogLevel dumpio:trace7

    ProxyPreserveHost On
    ProxyPass / http://localhost:3000/
    ProxyPassReverse / http://localhost:3000/

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOL'

# Enable Apache modules and configuration
sudo a2enmod proxy proxy_http dump_io
sudo a2dissite 000-default
sudo a2ensite watermelon
sudo systemctl restart apache2

# Install PM2, start server, and configure PM2 to auto-start on boot
sudo npm install -g pm2
pm2 start server.js
pm2 startup systemd -u $(whoami) --hp /home/$(whoami)
pm2 save

# Configure firewall to allow HTTP (port 80) and SSH (port 22) traffic
sudo ufw allow 80/tcp
sudo ufw allow 22/tcp
sudo ufw --force enable

echo "Setup complete!"
