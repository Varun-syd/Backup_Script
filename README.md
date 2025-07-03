# 🛡️ Bash Backup Script

A robust, cross-platform backup solution that creates timestamped compressed archives with comprehensive logging. Compatible with Linux, macOS, and Windows (via Git Bash).

## � Table of Contents

- [Features](#-features)
- [Requirements](#-requirements)
- [Installation](#-installation)
- [Quick Start](#-quick-start)
- [Usage](#-usage)
- [Configuration](#-configuration)
- [Examples](#-examples)
- [Automation](#-automation)
- [Logging](#-logging)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [License](#-license)

## ✨ Features

- **Cross-Platform Compatibility**: Works on Linux, macOS, and Windows (Git Bash)
- **Timestamped Backups**: Automatic timestamp generation (`YYYY-MM-DD_HH-MM-SS`)
- **Compressed Archives**: Uses `tar.gz` compression for space efficiency
- **Comprehensive Logging**: Detailed backup logs with timestamps
- **Error Handling**: Robust error checking and reporting
- **Flexible Input**: Supports both files and directories
- **Automation Ready**: Perfect for cron jobs and scheduled tasks

## 📋 Requirements

### Linux/macOS
- Bash shell (version 4.0 or higher)
- `tar` command (usually pre-installed)
- `date` command (usually pre-installed)

### Windows
- [Git for Windows](https://git-scm.com/download/win) (includes Git Bash)
- Or [Windows Subsystem for Linux (WSL)](https://docs.microsoft.com/en-us/windows/wsl/install)

## 🚀 Installation

### Option 1: Clone Repository
```bash
git clone https://github.com/yourusername/backup-script.git
cd backup-script
chmod +x backup.sh
```

### Option 2: Direct Download
```bash
wget https://raw.githubusercontent.com/yourusername/backup-script/main/backup.sh
chmod +x backup.sh
```

### Option 3: Manual Installation
1. Copy the `backup.sh` script to your desired location
2. Make it executable: `chmod +x backup.sh`

## 🏃 Quick Start

```bash
# Basic backup command
./backup.sh /path/to/source /path/to/backup/destination

# Example: Backup your Documents folder
./backup.sh ~/Documents ~/Backups
```

## 📚 Usage

### Basic Syntax
```bash
./backup.sh <source_path> <backup_directory>
```

### Parameters
- `<source_path>`: Path to the file or directory you want to backup
- `<backup_directory>`: Directory where the backup archive will be stored

### Exit Codes
- `0`: Backup completed successfully
- `1`: Invalid arguments or backup failed

## ⚙️ Configuration

### Environment Variables
You can customize the script behavior using environment variables:

```bash
# Custom timestamp format
export BACKUP_TIMESTAMP_FORMAT="%Y%m%d_%H%M%S"

# Custom log file name
export BACKUP_LOG_NAME="custom_backup.log"

# Run the script with custom settings
./backup.sh ~/Documents ~/Backups
```

### Script Modifications
For permanent customization, edit these variables in `backup.sh`:

```bash
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")  # Timestamp format
LOG_FILE="${BACKUP_DIR}/backup.log"     # Log file location
```

## 💡 Examples

### Basic File Backup
```bash
# Backup a single file
./backup.sh ~/important-document.pdf ~/Backups
```

### Directory Backup
```bash
# Backup entire directory
./backup.sh ~/Projects ~/Backups
```

### System Configuration Backup
```bash
# Backup system configs (Linux)
sudo ./backup.sh /etc ~/Backups/system-configs
```

### Multiple Backups
```bash
# Create multiple backups with different sources
./backup.sh ~/Documents ~/Backups
./backup.sh ~/Pictures ~/Backups
./backup.sh ~/Projects ~/Backups
```

### Network Drive Backup
```bash
# Backup to network location (ensure mount point exists)
./backup.sh ~/important-data /mnt/network-backup
```

## 🤖 Automation

### Linux/macOS Cron Jobs

Edit your crontab:
```bash
crontab -e
```

Add backup schedules:
```bash
# Daily backup at 2 AM
0 2 * * * /path/to/backup.sh ~/Documents ~/Backups

# Weekly backup every Sunday at 3 AM
0 3 * * 0 /path/to/backup.sh ~/Projects ~/Weekly-Backups

# Monthly backup on the 1st day at 4 AM
0 4 1 * * /path/to/backup.sh ~/important-files ~/Monthly-Backups
```

### Windows Task Scheduler

1. Open Task Scheduler
2. Create Basic Task
3. Set trigger (daily, weekly, etc.)
4. Set action to start a program:
   - Program: `"C:\Program Files\Git\bin\bash.exe"`
   - Arguments: `"/path/to/backup.sh" "C:\Users\username\Documents" "C:\Backups"`

### Systemd Timer (Linux)

Create a service file `/etc/systemd/system/backup.service`:
```ini
[Unit]
Description=Backup Script
Wants=backup.timer

[Service]
Type=oneshot
ExecStart=/path/to/backup.sh /home/user/Documents /home/user/Backups

[Install]
WantedBy=multi-user.target
```

Create a timer file `/etc/systemd/system/backup.timer`:
```ini
[Unit]
Description=Run backup script daily
Requires=backup.service

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
```

Enable and start:
```bash
sudo systemctl enable backup.timer
sudo systemctl start backup.timer
```

## � Logging

### Log Format
```
[YYYY-MM-DD_HH-MM-SS] Backing up /source/path to filename_timestamp.tar.gz
[YYYY-MM-DD_HH-MM-SS] Backup successful!
```

### Log Location
- Default: `<backup_directory>/backup.log`
- Logs are appended, not overwritten
- Both console output and log file are updated simultaneously

### Log Management
```bash
# View recent backup logs
tail -f ~/Backups/backup.log

# View last 20 backup entries
tail -20 ~/Backups/backup.log

# Search for failed backups
grep "FAILED" ~/Backups/backup.log

# Rotate logs (keep last 100 lines)
tail -100 ~/Backups/backup.log > ~/Backups/backup.log.tmp
mv ~/Backups/backup.log.tmp ~/Backups/backup.log
```

## 🔧 Troubleshooting

### Common Issues

#### Permission Denied
```bash
# Make script executable
chmod +x backup.sh

# Run with appropriate permissions
sudo ./backup.sh /protected/path ~/Backups
```

#### No Space Left on Device
```bash
# Check available space
df -h ~/Backups

# Clean old backups
find ~/Backups -name "*.tar.gz" -mtime +30 -delete
```

#### Invalid Arguments
```bash
# Correct syntax
./backup.sh /valid/source/path /valid/backup/destination

# Check if paths exist
ls -la /path/to/source
ls -la /path/to/backup/directory
```

#### Backup Failed
```bash
# Check log file for details
cat ~/Backups/backup.log

# Verify source path exists and is readable
ls -la /source/path

# Ensure backup directory is writable
touch ~/Backups/test_file && rm ~/Backups/test_file
```

### Windows-Specific Issues

#### Path Format
```bash
# Use forward slashes in Git Bash
./backup.sh "/c/Users/username/Documents" "/c/Backups"

# Or use Unix-style paths
./backup.sh "/home/username/Documents" "/home/username/Backups"
```

#### Git Bash Not Found
1. Install [Git for Windows](https://git-scm.com/download/win)
2. Add Git Bash to PATH
3. Use full path: `"C:\Program Files\Git\bin\bash.exe"`

### Debug Mode
Add debug output to the script:
```bash
# Enable debug mode
set -x
./backup.sh ~/Documents ~/Backups
set +x
```

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

### Reporting Issues
1. Check existing issues first
2. Provide detailed description
3. Include system information (OS, bash version)
4. Add relevant log outputs

### Submitting Changes
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on multiple platforms
5. Submit a pull request

### Development Setup
```bash
git clone https://github.com/yourusername/backup-script.git
cd backup-script

# Test the script
./backup.sh test-data test-backups

# Run shellcheck for code quality
shellcheck backup.sh
```

### Code Style
- Use 4-space indentation
- Follow bash best practices
- Add comments for complex logic
- Test on Linux, macOS, and Windows

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Related Projects

- [rsync](https://rsync.samba.org/) - Network file synchronization
- [duplicity](http://duplicity.nongnu.org/) - Encrypted backup to cloud
- [borgbackup](https://www.borgbackup.org/) - Deduplicating backup program

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/backup-script/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/backup-script/discussions)
- **Email**: support@yourproject.com

---

Made with ❤️ for reliable backups
