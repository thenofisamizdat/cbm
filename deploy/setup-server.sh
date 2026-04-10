#!/bin/bash
# =============================================================
# CBM Transport — Server Setup Script
# Run this on your Ubuntu Google Cloud server
# =============================================================

set -e

echo "=== CBM Transport Server Setup ==="
echo ""

# 1. Update system
echo "[1/5] Updating system packages..."
sudo apt update && sudo apt upgrade -y

# 2. Install Nginx
echo "[2/5] Installing Nginx..."
sudo apt install -y nginx

# 3. Create web directory and set permissions
echo "[3/5] Creating web directory..."
sudo mkdir -p /var/www/cbm
sudo chown -R $USER:$USER /var/www/cbm
sudo chmod -R 755 /var/www/cbm

# 4. Copy Nginx config
echo "[4/5] Configuring Nginx..."
sudo cp nginx-cbm.conf /etc/nginx/sites-available/cbm
sudo ln -sf /etc/nginx/sites-available/cbm /etc/nginx/sites-enabled/cbm

# Remove default site to avoid conflicts
sudo rm -f /etc/nginx/sites-enabled/default

# Test Nginx config
sudo nginx -t

# 5. Start/restart Nginx
echo "[5/5] Starting Nginx..."
sudo systemctl enable nginx
sudo systemctl restart nginx

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "  1. Upload your site files to /var/www/cbm/"
echo "  2. Visit http://YOUR_SERVER_IP to verify"
echo "  3. (Optional) Set up SSL with: sudo apt install certbot python3-certbot-nginx && sudo certbot --nginx"
echo ""
