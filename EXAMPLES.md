# 📚 Backup Script Examples

This document provides comprehensive examples of using the bash backup script in various scenarios.

## 📋 Table of Contents

- [Basic Usage](#basic-usage)
- [File Backups](#file-backups)
- [Directory Backups](#directory-backups)
- [System Administration](#system-administration)
- [Automation Examples](#automation-examples)
- [Advanced Scenarios](#advanced-scenarios)
- [Platform-Specific Examples](#platform-specific-examples)
- [Troubleshooting Examples](#troubleshooting-examples)

## Basic Usage

### Simple File Backup
```bash
# Backup a single document
./backup.sh ~/important-document.pdf ~/Backups

# Result: ~/Backups/important-document_2024-01-15_14-30-25.tar.gz
```

### Simple Directory Backup
```bash
# Backup your entire Documents folder
./backup.sh ~/Documents ~/Backups

# Result: ~/Backups/Documents_2024-01-15_14-30-25.tar.gz
```

## File Backups

### Document Backups
```bash
# Backup presentation files
./backup.sh ~/presentation.pptx ~/Work-Backups

# Backup important spreadsheet
./backup.sh ~/budget-2024.xlsx ~/Financial-Backups

# Backup code file
./backup.sh ~/project/main.py ~/Code-Backups
```

### Configuration File Backups
```bash
# Backup SSH config
./backup.sh ~/.ssh/config ~/Config-Backups

# Backup bash profile
./backup.sh ~/.bashrc ~/Config-Backups

# Backup Git config
./backup.sh ~/.gitconfig ~/Config-Backups
```

### Large File Backups
```bash
# Backup video file
./backup.sh ~/Videos/important-recording.mp4 ~/Media-Backups

# Backup database dump
./backup.sh ~/database-backup.sql ~/DB-Backups

# Backup disk image
./backup.sh ~/system-image.iso ~/Image-Backups
```

## Directory Backups

### Personal Data
```bash
# Backup all documents
./backup.sh ~/Documents ~/Daily-Backups

# Backup photos
./backup.sh ~/Pictures ~/Photo-Backups

# Backup music collection
./backup.sh ~/Music ~/Media-Backups

# Backup downloads
./backup.sh ~/Downloads ~/Downloads-Archive
```

### Development Projects
```bash
# Backup current project
./backup.sh ~/Projects/my-app ~/Project-Backups

# Backup all projects
./backup.sh ~/Projects ~/Complete-Project-Backups

# Backup specific repository
./backup.sh ~/Projects/important-repo ~/Repository-Backups
```

### Work Directories
```bash
# Backup work folder
./backup.sh ~/Work ~/Work-Backups

# Backup client projects
./backup.sh ~/Clients/client-name ~/Client-Backups

# Backup reports and presentations
./backup.sh ~/Reports ~/Report-Archives
```

## System Administration

### Configuration Backups (Linux)
```bash
# Backup system configuration
sudo ./backup.sh /etc ~/System-Backups/configs

# Backup web server configs
sudo ./backup.sh /etc/nginx ~/Web-Server-Backups

# Backup database configs
sudo ./backup.sh /etc/mysql ~/Database-Backups

# Backup cron jobs
sudo ./backup.sh /var/spool/cron ~/Cron-Backups
```

### Log File Backups
```bash
# Backup system logs
sudo ./backup.sh /var/log ~/Log-Backups

# Backup application logs
./backup.sh ~/app/logs ~/App-Log-Backups

# Backup web server logs
sudo ./backup.sh /var/log/nginx ~/Web-Log-Backups
```

### Home Directory Backups
```bash
# Backup entire home directory
./backup.sh ~/ ~/Full-Home-Backups

# Backup user profile
./backup.sh ~/.profile ~/Profile-Backups

# Backup application settings
./backup.sh ~/.config ~/Config-Backups
```

## Automation Examples

### Daily Backups (Cron)
```bash
# Edit crontab
crontab -e

# Add daily document backup at 2 AM
0 2 * * * /home/user/scripts/backup.sh /home/user/Documents /home/user/Daily-Backups

# Add daily project backup at 3 AM
0 3 * * * /home/user/scripts/backup.sh /home/user/Projects /home/user/Project-Backups
```

### Weekly Backups (Cron)
```bash
# Weekly full home backup every Sunday at 1 AM
0 1 * * 0 /home/user/scripts/backup.sh /home/user /home/user/Weekly-Backups

# Weekly system config backup every Sunday at 2 AM
0 2 * * 0 /home/user/scripts/backup.sh /etc /home/user/System-Backups
```

### Monthly Backups (Cron)
```bash
# Monthly archive on the 1st at midnight
0 0 1 * * /home/user/scripts/backup.sh /home/user/Important /home/user/Monthly-Archives

# Quarterly backup every 3 months on the 1st
0 0 1 */3 * /home/user/scripts/backup.sh /home/user/Projects /home/user/Quarterly-Backups
```

### Batch Backup Script
```bash
#!/bin/bash
# batch_backup.sh - Backup multiple directories

BACKUP_BASE="/home/user/Backups"
TIMESTAMP=$(date +"%Y-%m-%d")
BACKUP_DIR="$BACKUP_BASE/$TIMESTAMP"

# Create timestamped backup directory
mkdir -p "$BACKUP_DIR"

# Backup multiple sources
./backup.sh ~/Documents "$BACKUP_DIR"
./backup.sh ~/Pictures "$BACKUP_DIR"
./backup.sh ~/Projects "$BACKUP_DIR"
./backup.sh ~/.config "$BACKUP_DIR"

echo "All backups completed in $BACKUP_DIR"
```

## Advanced Scenarios

### Network Storage Backup
```bash
# Mount network drive first
sudo mount -t cifs //server/backup /mnt/network-backup

# Backup to network location
./backup.sh ~/Important-Data /mnt/network-backup

# Unmount when done
sudo umount /mnt/network-backup
```

### Encrypted Backup (with GPG)
```bash
# Create backup first
./backup.sh ~/Sensitive-Data ~/Backups

# Encrypt the backup
gpg --cipher-algo AES256 --compress-algo 1 --symmetric \
    ~/Backups/Sensitive-Data_2024-01-15_14-30-25.tar.gz

# Remove unencrypted backup
rm ~/Backups/Sensitive-Data_2024-01-15_14-30-25.tar.gz
```

### Backup with Compression Options
```bash
# Modify backup.sh to use different compression
# Change this line in backup.sh:
# tar -czf "$BACKUP_DIR/$ARCHIVE_NAME" ...
# To:
# tar --use-compress-program="gzip -9" -cf "$BACKUP_DIR/$ARCHIVE_NAME" ...

# For even better compression (slower):
# tar --use-compress-program="xz -9" -cf "$BACKUP_DIR/$ARCHIVE_NAME" ...
```

### Remote Backup via SSH
```bash
# Create backup locally first
./backup.sh ~/Data ~/Temp-Backups

# Copy to remote server
scp ~/Temp-Backups/Data_*.tar.gz user@remote-server:/backups/

# Clean up local temp backup
rm ~/Temp-Backups/Data_*.tar.gz
```

### Backup with Size Limits
```bash
# Check directory size before backup
dir_size=$(du -sh ~/Large-Directory | cut -f1)
echo "Directory size: $dir_size"

# Only backup if under certain size
if [[ $(du -s ~/Large-Directory | cut -f1) -lt 1000000 ]]; then
    ./backup.sh ~/Large-Directory ~/Backups
else
    echo "Directory too large for backup"
fi
```

## Platform-Specific Examples

### Windows (Git Bash)
```bash
# Backup Windows Documents folder
./backup.sh "/c/Users/username/Documents" "/c/Backups"

# Backup Desktop
./backup.sh "/c/Users/username/Desktop" "/c/Backups"

# Backup from WSL to Windows
./backup.sh "/home/username/projects" "/mnt/c/Backups"

# Using Windows paths in Git Bash
./backup.sh "C:\Users\username\Important" "D:\Backups"
```

### macOS
```bash
# Backup Applications folder
./backup.sh /Applications ~/Backups

# Backup Library preferences
./backup.sh ~/Library/Preferences ~/Config-Backups

# Backup from external drive
./backup.sh /Volumes/External/Data ~/Backups
```

### Linux Variants
```bash
# Ubuntu/Debian specific
sudo ./backup.sh /etc/apt ~/System-Backups
./backup.sh ~/.local/share ~/App-Data-Backups

# CentOS/RHEL specific
sudo ./backup.sh /etc/yum.repos.d ~/System-Backups
sudo ./backup.sh /etc/systemd ~/Service-Backups

# Arch Linux specific
sudo ./backup.sh /etc/pacman.d ~/System-Backups
./backup.sh ~/.config/awesome ~/Desktop-Backups
```

## Troubleshooting Examples

### Permission Issues
```bash
# Check permissions before backup
ls -la ~/source-directory

# Run with sudo for system files
sudo ./backup.sh /protected/directory ~/Backups

# Change ownership of backup directory
sudo chown $USER:$USER ~/Backups
```

### Space Issues
```bash
# Check available space
df -h ~/Backups

# Estimate backup size first
du -sh ~/source-directory

# Clean old backups (older than 30 days)
find ~/Backups -name "*.tar.gz" -mtime +30 -delete
```

### Path Issues
```bash
# Use absolute paths
./backup.sh "$HOME/Documents" "$HOME/Backups"

# Handle spaces in paths
./backup.sh "$HOME/My Documents" "$HOME/My Backups"

# Escape special characters
./backup.sh "$HOME/folder with (special) chars" ~/Backups
```

### Debug Mode
```bash
# Enable debug output
set -x
./backup.sh ~/Documents ~/Backups
set +x

# Check what's happening step by step
bash -x ./backup.sh ~/Documents ~/Backups
```

### Verify Backups
```bash
# List contents of backup
tar -tzf ~/Backups/Documents_2024-01-15_14-30-25.tar.gz

# Extract to temporary location for verification
mkdir ~/temp-verify
tar -xzf ~/Backups/Documents_2024-01-15_14-30-25.tar.gz -C ~/temp-verify

# Compare original and extracted
diff -r ~/Documents ~/temp-verify/Documents

# Clean up
rm -rf ~/temp-verify
```

## Best Practices Examples

### Organized Backup Structure
```bash
# Create dated backup directories
BACKUP_BASE="/home/user/Backups"
DATE=$(date +"%Y-%m-%d")
mkdir -p "$BACKUP_BASE/daily/$DATE"
mkdir -p "$BACKUP_BASE/weekly"
mkdir -p "$BACKUP_BASE/monthly"

# Daily backups
./backup.sh ~/Documents "$BACKUP_BASE/daily/$DATE"

# Weekly backups (Sundays)
if [[ $(date +%u) -eq 7 ]]; then
    ./backup.sh ~/Projects "$BACKUP_BASE/weekly"
fi

# Monthly backups (1st of month)
if [[ $(date +%d) -eq 01 ]]; then
    ./backup.sh ~/ "$BACKUP_BASE/monthly"
fi
```

### Backup Rotation
```bash
# Keep only last 7 daily backups
find ~/Backups/daily -type d -mtime +7 -exec rm -rf {} +

# Keep only last 4 weekly backups
find ~/Backups/weekly -name "*.tar.gz" -mtime +28 -delete

# Keep only last 12 monthly backups
find ~/Backups/monthly -name "*.tar.gz" -mtime +365 -delete
```

### Backup Verification Script
```bash
#!/bin/bash
# verify_backup.sh

BACKUP_FILE="$1"
ORIGINAL_DIR="$2"

if [[ ! -f "$BACKUP_FILE" ]]; then
    echo "Backup file not found: $BACKUP_FILE"
    exit 1
fi

# Test if backup can be extracted
if tar -tzf "$BACKUP_FILE" > /dev/null 2>&1; then
    echo "✅ Backup file is valid"
else
    echo "❌ Backup file is corrupted"
    exit 1
fi

echo "Backup verification completed successfully"
```

These examples should cover most common use cases and scenarios for the backup script. For specific needs not covered here, you can combine these patterns or modify the script accordingly.