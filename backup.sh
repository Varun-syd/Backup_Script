#!/bin/bash

# === Configuration ===
SOURCE="$1"
BACKUP_DIR="$2"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_NAME=$(basename "$SOURCE")
ARCHIVE_NAME="${BACKUP_NAME}_${TIMESTAMP}.tar.gz"
LOG_FILE="${BACKUP_DIR}/backup.log"

# === Check arguments ===
if [[ -z "$SOURCE" || -z "$BACKUP_DIR" ]]; then
    echo "Usage: $0 /path/to/source /path/to/backup"
        exit 1
	fi

	# === Create backup directory if not exist ===
	mkdir -p "$BACKUP_DIR"

	# === Create the backup ===
	echo "[$TIMESTAMP] Backing up $SOURCE to $ARCHIVE_NAME" | tee -a "$LOG_FILE"
	if tar -czf "$BACKUP_DIR/$ARCHIVE_NAME" -C "$(dirname "$SOURCE")" "$(basename "$SOURCE")"; then
	    echo "[$TIMESTAMP] Backup successful!" | tee -a "$LOG_FILE"
	    else
	        echo "[$TIMESTAMP] Backup FAILED!" | tee -a "$LOG_FILE"
		fi

