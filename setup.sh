#!/bin/bash

# Update system and install dependencies
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y nodejs npm apache2 git sqlite3

# Clone repository
git clone https://github.com/notbowen/watermelon-poly.git
cd watermelon-poly

# Install Node dependencies
npm install

# Initialize database
sqlite3 watermelon.db < database.sql

# Configure Apache
sudo bash -c 'cat > /etc/apache2/sites-available/watermelon.conf <<EOL
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot /var/www/html

    ProxyPreserveHost On
    ProxyPass / http://localhost:3000/
    ProxyPassReverse / http://localhost:3000/

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOL'

# Enable Apache modules and config
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2dissite 000-default
sudo a2ensite watermelon
sudo systemctl restart apache2

# Install PM2 and start server
sudo npm install -g pm2
pm2 start server.js
pm2 startup systemd
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u $USER --hp /home/$USER
pm2 save

# Configure firewall
sudo ufw allow 80/tcp
sudo ufw --force enable

echo "Setup complete! Access the server at http://$(curl -s ifconfig.me)"
