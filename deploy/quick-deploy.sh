#!/bin/bash
# =============================================================
# CBM Transport — Quick Deploy (HTTP only)
# Run this on your Ubuntu Google Cloud server
# =============================================================

set -e

# 1. Install Nginx
sudo apt update
sudo apt install -y nginx

# 2. Copy site files to web root
sudo mkdir -p /var/www/cbm
sudo cp -r ~/cbm-site/* /var/www/cbm/
sudo chown -R www-data:www-data /var/www/cbm

# 3. Configure Nginx
sudo tee /etc/nginx/sites-available/cbm > /dev/null <<'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/cbm;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/cbm /etc/nginx/sites-enabled/cbm
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl restart nginx

echo ""
echo "Done! Visit http://$(curl -s ifconfig.me)"
