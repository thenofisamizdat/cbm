#!/bin/bash
# =============================================================
# CBM Transport — Upload Site Files
# Run this from your LOCAL machine (Mac) to push files to server
#
# Prerequisites: gcloud CLI installed and authenticated
# Install: https://cloud.google.com/sdk/docs/install
#
# Usage: ./upload-site.sh <INSTANCE_NAME> <ZONE> [PROJECT]
# Example: ./upload-site.sh my-vm-instance us-central1-a my-project-id
# =============================================================

set -e

INSTANCE=${1:?"Usage: ./upload-site.sh <INSTANCE_NAME> <ZONE> [PROJECT]"}
ZONE=${2:?"Usage: ./upload-site.sh <INSTANCE_NAME> <ZONE> [PROJECT]"}
PROJECT=${3:-""}

SITE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_FLAG=""

if [ -n "$PROJECT" ]; then
    PROJECT_FLAG="--project=$PROJECT"
fi

echo "=== Uploading CBM Transport site ==="
echo "Source: $SITE_DIR"
echo "Target: $INSTANCE ($ZONE)"
echo ""

# Create a clean temp directory with only site files (no deploy folder)
TEMP_DIR=$(mktemp -d)
echo "[1/3] Preparing files..."
cp -r "$SITE_DIR/index.html" "$TEMP_DIR/"
cp -r "$SITE_DIR/css" "$TEMP_DIR/"
cp -r "$SITE_DIR/js" "$TEMP_DIR/"
cp -r "$SITE_DIR/images" "$TEMP_DIR/"
cp -r "$SITE_DIR/pages" "$TEMP_DIR/"

# Upload to server home directory first
echo "[2/3] Uploading to server..."
gcloud compute scp --recurse "$TEMP_DIR"/* "$INSTANCE":~/cbm-site/ --zone="$ZONE" $PROJECT_FLAG

# Move files into web root on the server
echo "[3/3] Moving files to /var/www/cbm/..."
gcloud compute ssh "$INSTANCE" --zone="$ZONE" $PROJECT_FLAG --command="sudo rsync -av --delete ~/cbm-site/ /var/www/cbm/ && sudo chown -R www-data:www-data /var/www/cbm"

# Clean up
rm -rf "$TEMP_DIR"

echo ""
echo "=== Upload Complete ==="
echo "Visit: http://$(gcloud compute instances describe $INSTANCE --zone=$ZONE $PROJECT_FLAG --format='get(networkInterfaces[0].accessConfigs[0].natIP)' 2>/dev/null || echo 'YOUR_SERVER_IP')"
echo ""
