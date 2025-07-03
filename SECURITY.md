# 🔒 Security Guide

This document outlines security best practices when using the bash backup script, especially important since backups often contain sensitive data.

## 📋 Table of Contents

- [Security Principles](#security-principles)
- [File Permissions](#file-permissions)
- [Encryption](#encryption)
- [Secure Storage](#secure-storage)
- [Network Security](#network-security)
- [Access Control](#access-control)
- [Audit and Monitoring](#audit-and-monitoring)
- [Incident Response](#incident-response)
- [Security Checklist](#security-checklist)

## 🛡️ Security Principles

### Defense in Depth
Implement multiple layers of security:
- Secure the source data
- Encrypt backups at rest
- Secure transmission channels
- Control access to backup storage
- Monitor backup activities

### Least Privilege
- Run scripts with minimum required permissions
- Limit access to backup directories
- Use dedicated backup users when possible

### Regular Security Reviews
- Audit backup permissions regularly
- Review and rotate encryption keys
- Monitor backup access logs
- Update security practices as needed

## 📁 File Permissions

### Script Permissions
```bash
# Make script executable by owner only
chmod 700 backup.sh

# Or allow group execution if needed
chmod 750 backup.sh

# Verify permissions
ls -la backup.sh
# Should show: -rwx------ or -rwxr-x---
```

### Backup Directory Permissions
```bash
# Create secure backup directory
mkdir -p ~/Backups
chmod 700 ~/Backups

# For shared systems, use more restrictive permissions
sudo mkdir -p /secure/backups
sudo chmod 700 /secure/backups
sudo chown backupuser:backupgroup /secure/backups
```

### Log File Security
```bash
# Secure log files
chmod 600 ~/Backups/backup.log

# Prevent unauthorized access to logs
sudo chown root:root /var/log/backup.log
sudo chmod 640 /var/log/backup.log
```

## 🔐 Encryption

### GPG Encryption

#### Setup GPG Key
```bash
# Generate a new GPG key for backups
gpg --full-generate-key

# Export public key for backup
gpg --export --armor your-email@domain.com > backup-public-key.asc

# Export private key securely (store separately)
gpg --export-secret-keys --armor your-email@domain.com > backup-private-key.asc
```

#### Encrypt Backups
```bash
# Create backup first
./backup.sh ~/Documents ~/Backups

# Encrypt the backup
cd ~/Backups
gpg --cipher-algo AES256 --compress-algo 1 --symmetric \
    Documents_2024-01-15_14-30-25.tar.gz

# Or encrypt with public key
gpg --encrypt --recipient your-email@domain.com \
    Documents_2024-01-15_14-30-25.tar.gz

# Remove unencrypted backup
rm Documents_2024-01-15_14-30-25.tar.gz
```

#### Decrypt Backups
```bash
# Decrypt symmetrically encrypted backup
gpg --decrypt Documents_2024-01-15_14-30-25.tar.gz.gpg > restored-backup.tar.gz

# Decrypt public key encrypted backup
gpg --decrypt Documents_2024-01-15_14-30-25.tar.gz.gpg > restored-backup.tar.gz
```

### Enhanced Backup Script with Encryption
```bash
#!/bin/bash
# secure_backup.sh

SOURCE="$1"
BACKUP_DIR="$2"
ENCRYPT="${3:-yes}"  # Default to encryption
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_NAME=$(basename "$SOURCE")
ARCHIVE_NAME="${BACKUP_NAME}_${TIMESTAMP}.tar.gz"

# Create backup
tar -czf "$BACKUP_DIR/$ARCHIVE_NAME" -C "$(dirname "$SOURCE")" "$(basename "$SOURCE")"

# Encrypt if requested
if [[ "$ENCRYPT" == "yes" ]]; then
    gpg --cipher-algo AES256 --compress-algo 1 --symmetric "$BACKUP_DIR/$ARCHIVE_NAME"
    rm "$BACKUP_DIR/$ARCHIVE_NAME"  # Remove unencrypted version
    echo "Encrypted backup created: $BACKUP_DIR/$ARCHIVE_NAME.gpg"
else
    echo "Unencrypted backup created: $BACKUP_DIR/$ARCHIVE_NAME"
fi
```

## 💾 Secure Storage

### Local Storage Security
```bash
# Use encrypted filesystems
sudo cryptsetup luksFormat /dev/sdX
sudo cryptsetup luksOpen /dev/sdX backup_volume
sudo mkfs.ext4 /dev/mapper/backup_volume

# Mount encrypted volume
sudo mkdir /mnt/secure_backups
sudo mount /dev/mapper/backup_volume /mnt/secure_backups
```

### Network Attached Storage (NAS)
- Use encrypted protocols (SFTP, SCP, encrypted NFS)
- Enable two-factor authentication
- Regular security updates
- Network segmentation

### Cloud Storage Security
```bash
# Use cloud provider encryption tools
# AWS S3 example with encryption
aws s3 cp backup.tar.gz.gpg s3://bucket/backups/ \
    --server-side-encryption AES256

# Google Cloud Storage with encryption
gsutil cp -Z backup.tar.gz.gpg gs://bucket/backups/

# Azure with encryption
az storage blob upload --file backup.tar.gz.gpg \
    --container-name backups --encryption-scope scope-name
```

## 🌐 Network Security

### Secure Transfer Protocols

#### SFTP/SCP
```bash
# Transfer via SFTP
sftp user@backup-server:/backups/ <<< "put backup.tar.gz.gpg"

# Transfer via SCP with compression
scp -C backup.tar.gz.gpg user@backup-server:/backups/

# Use SSH keys instead of passwords
ssh-keygen -t ed25519 -f ~/.ssh/backup_key
ssh-copy-id -i ~/.ssh/backup_key user@backup-server
```

#### VPN for Remote Backups
```bash
# Connect to VPN before backup transfer
sudo openvpn --config backup-vpn.ovpn &
VPN_PID=$!

# Perform backup transfer
scp backup.tar.gz.gpg user@internal-backup-server:/backups/

# Disconnect VPN
sudo kill $VPN_PID
```

### Network Monitoring
```bash
# Monitor network connections during backup
netstat -an | grep :22  # SSH connections
ss -tuln | grep :22     # Alternative monitoring

# Log network transfers
logger "Backup transfer started to $(destination)"
# ... transfer code ...
logger "Backup transfer completed"
```

## 🔑 Access Control

### User Management
```bash
# Create dedicated backup user
sudo useradd -r -m -s /bin/bash backupuser
sudo usermod -aG backup backupuser

# Set up sudo permissions for backup operations
echo "backupuser ALL=(root) NOPASSWD: /usr/local/bin/backup.sh" | \
    sudo tee /etc/sudoers.d/backup
```

### SSH Key Management
```bash
# Generate dedicated backup SSH key
ssh-keygen -t ed25519 -f ~/.ssh/backup_rsa -C "backup-operations"

# Restrict key usage
echo 'command="/usr/local/bin/backup-only.sh",no-port-forwarding,no-X11-forwarding,no-agent-forwarding' \
    ~/.ssh/backup_rsa.pub >> ~/.ssh/authorized_keys
```

### File Access Control Lists (ACLs)
```bash
# Set ACLs for backup directories
setfacl -m u:backupuser:rwx /backup/directory
setfacl -m g:backup:r-x /backup/directory
setfacl -d -m u:backupuser:rwx /backup/directory  # Default for new files
```

## 📊 Audit and Monitoring

### Logging Best Practices
```bash
# Enhanced logging function
log_secure() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Log to file and syslog
    echo "[$timestamp] [$level] $message" >> /var/log/backup-security.log
    logger -t backup-script "[$level] $message"
}

# Usage in backup script
log_secure "INFO" "Backup started for $SOURCE"
log_secure "WARNING" "Large file detected: $large_file"
log_secure "ERROR" "Backup failed: $error_message"
```

### Integrity Monitoring
```bash
# Create checksums for backup verification
sha256sum backup.tar.gz.gpg > backup.tar.gz.gpg.sha256

# Verify integrity
sha256sum -c backup.tar.gz.gpg.sha256

# Store checksums securely
gpg --sign backup.tar.gz.gpg.sha256
```

### Automated Security Checks
```bash
#!/bin/bash
# security_check.sh

BACKUP_DIR="$1"

# Check permissions
echo "Checking backup directory permissions..."
if [[ $(stat -c "%a" "$BACKUP_DIR") != "700" ]]; then
    echo "WARNING: Backup directory permissions are too permissive"
fi

# Check for unencrypted backups
echo "Checking for unencrypted backups..."
if find "$BACKUP_DIR" -name "*.tar.gz" -not -name "*.gpg" | grep -q .; then
    echo "WARNING: Unencrypted backups found"
fi

# Check disk space
echo "Checking disk space..."
if [[ $(df "$BACKUP_DIR" | awk 'NR==2 {print $5}' | sed 's/%//') -gt 90 ]]; then
    echo "WARNING: Backup disk space over 90% full"
fi
```

## 🚨 Incident Response

### Security Incident Checklist

1. **Immediate Response**
   - Isolate affected systems
   - Preserve evidence
   - Document the incident
   - Notify stakeholders

2. **Assessment**
   - Determine scope of compromise
   - Identify affected backups
   - Check backup integrity
   - Review access logs

3. **Recovery**
   - Restore from clean backups
   - Re-encrypt affected data
   - Update access credentials
   - Patch vulnerabilities

4. **Post-Incident**
   - Conduct security review
   - Update procedures
   - Train personnel
   - Implement improvements

### Emergency Backup Recovery
```bash
#!/bin/bash
# emergency_restore.sh

BACKUP_FILE="$1"
RESTORE_DIR="$2"
VERIFY_ONLY="${3:-no}"

# Verify backup integrity first
if ! gpg --verify "$BACKUP_FILE.sig" "$BACKUP_FILE"; then
    echo "ERROR: Backup signature verification failed"
    exit 1
fi

# Decrypt backup
gpg --decrypt "$BACKUP_FILE" > temp_backup.tar.gz

if [[ "$VERIFY_ONLY" == "yes" ]]; then
    # Only verify, don't restore
    tar -tzf temp_backup.tar.gz > /dev/null
    echo "Backup verification successful"
else
    # Perform restoration
    tar -xzf temp_backup.tar.gz -C "$RESTORE_DIR"
    echo "Emergency restoration completed"
fi

# Clean up
rm temp_backup.tar.gz
```

## ✅ Security Checklist

### Pre-Deployment
- [ ] Script permissions set to 700
- [ ] Backup directory permissions set to 700
- [ ] GPG keys generated and stored securely
- [ ] SSH keys configured for remote backups
- [ ] Network security measures in place
- [ ] Logging and monitoring configured

### Regular Maintenance
- [ ] Review and rotate encryption keys quarterly
- [ ] Audit backup access permissions monthly
- [ ] Test backup restoration procedures monthly
- [ ] Review security logs weekly
- [ ] Update backup software and dependencies
- [ ] Verify backup integrity checks

### Incident Preparedness
- [ ] Incident response plan documented
- [ ] Emergency contacts identified
- [ ] Backup recovery procedures tested
- [ ] Alternative backup locations configured
- [ ] Security awareness training completed

### Compliance
- [ ] Data retention policies followed
- [ ] Regulatory requirements met
- [ ] Privacy laws compliance verified
- [ ] Audit trails maintained
- [ ] Documentation kept current

## 📞 Reporting Security Issues

If you discover a security vulnerability in this backup script:

1. **DO NOT** create a public issue
2. Email security details to: security@yourproject.com
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact assessment
   - Suggested mitigation

We will respond within 24 hours and work with you to address the issue responsibly.

---

Remember: Security is an ongoing process, not a one-time setup. Regular review and updates of these practices are essential for maintaining the security of your backup system.