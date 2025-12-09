#!/bin/bash

# 💾 Backup Script - Backup data penting sebelum update

BACKUP_DIR="/home/ubuntu/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/fire-detection-backup-$TIMESTAMP.tar.gz"

echo "============================================"
echo "💾 Backup Fire Detection System"
echo "============================================"
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Create backup directory
mkdir -p $BACKUP_DIR

echo -e "${YELLOW}📦 Creating backup...${NC}"

# Backup data files
cd ~/sudahtapibelum
tar -czf $BACKUP_FILE \
    proxy-server/data \
    python_scripts/detected_fires \
    python_scripts/.env \
    proxy-server/.env \
    2>/dev/null

echo -e "${GREEN}✅ Backup created: $BACKUP_FILE${NC}"

# Keep only last 7 backups
echo -e "${YELLOW}🧹 Cleaning old backups...${NC}"
cd $BACKUP_DIR
ls -t fire-detection-backup-*.tar.gz | tail -n +8 | xargs -r rm

echo ""
echo -e "${GREEN}✅ Backup complete!${NC}"
echo ""
echo "Backup location: $BACKUP_FILE"
echo ""
