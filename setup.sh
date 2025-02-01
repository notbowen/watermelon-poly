#!/bin/bash

# Update system and install dependencies
sudo apt-get update -y
sudo apt-get install -y nodejs npm apache2 git sqlite3

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

# Configure firewall to allow HTTP traffic
sudo ufw allow 80/tcp
sudo ufw --force enable

echo "Setup complete!"
