#!/bin/bash
set -e

# ================================================
# Update Script for Mickle - Unix Version
# ================================================
# This script updates the Mickle application by:
# 1. Validating input paths.
# 2. Creating backups before update.
# 3. Using rsync for efficient file operations.
# 4. Logging actions with timestamps.
# 5. Starting the application after update.
# ================================================

# -----------------------
# Configuration
# -----------------------
ENABLE_CONFIRM=1  # Set to 1 to enable confirmations, 0 to disable
ENABLE_LOG=1      # Set to 1 to enable logging to file, 0 to disable
LOG_FILE="/tmp/update_log.txt"
BACKUP_DIR="/tmp/mickle/backups"

# -----------------------
# Parameters
# -----------------------
DEST_DIR="$1"
SOURCE_DIR="$2"

# -----------------------
# Validate Input Parameters
# -----------------------
if [ -z "$DEST_DIR" ] || [ -z "$SOURCE_DIR" ]; then
    echo "Usage: $(basename "$0") [destination directory] [source directory]"
    exit 1
fi

# -----------------------
# Initialize Log File
# -----------------------
if [ "$ENABLE_LOG" -eq 1 ]; then
    echo "Update Script Log - $(date '+%Y-%m-%d %H:%M:%S')" > "$LOG_FILE"
    echo "============================================" >> "$LOG_FILE"
fi


# -----------------------
# Function Definitions
# -----------------------

# Function to Log Messages with Timestamps
Log() {
    message="$1"
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    if [ "$ENABLE_LOG" -eq 1 ]; then
        echo "[$timestamp] $message" >> "$LOG_FILE"
    fi
    echo "[$timestamp] $message"
}

# Function to Confirm Actions
ConfirmAction() {
    action="$1"
    if [ "$ENABLE_CONFIRM" -eq 1 ]; then
        Log "ACTION: $action"
        read -p "Confirm? Press Enter to continue or Ctrl+C to abort..."
    else
        Log "ACTION: $action"
    fi
}

# Function to Validate Safe Paths
IsSafePath() {
    testPath="$1"
    unsafe=0

    # Remove trailing slash if it exists
    testPath="${testPath%/}"

    # List of critical system directories
    critical_dirs=(
        "/"
        "/root"
        "/bin"
        "/sbin"
        "/lib"
        "/lib64"
        "/usr"
        "/usr/bin"
        "/usr/sbin"
        "/etc"
        "/var"
        "/boot"
        "/dev"
        "/proc"
        "/sys"
    )

    for dir in "${critical_dirs[@]}"; do
        if [ "$testPath" = "$dir" ]; then
            unsafe=1
            break
        fi
    done

    if [ "$unsafe" -eq 1 ]; then
        Log "ERROR: Attempted to operate on critical system directory '$testPath'. Operation aborted."
        exit 1
    fi

    return 0
}

# Function to Get a Safe Timestamp for Backup Naming
GetSafeTimestamp() {
    timestamp="$(date '+%Y-%m-%d_%H%M%S')"
}

# -----------------------
# Main Execution Flow
# -----------------------

# Ensure DEST_DIR and SOURCE_DIR are absolute paths
if [[ "$DEST_DIR" != /* ]]; then
    Log "ERROR: Destination directory '$DEST_DIR' is not an absolute path. Operation aborted."
    exit 1
fi

if [[ "$SOURCE_DIR" != /* ]]; then
    Log "ERROR: Source directory '$SOURCE_DIR' is not an absolute path. Operation aborted."
    exit 1
fi

# Validate Paths are Safe
IsSafePath "$DEST_DIR" || exit 1
IsSafePath "$SOURCE_DIR" || exit 1

# Create Backup Directory
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR" && Log "Created backup directory at '$BACKUP_DIR'."
    if [ $? -ne 0 ]; then
        Log "ERROR: Failed to create backup directory at '$BACKUP_DIR'. Operation aborted."
        exit 1
    fi
else
    Log "Backup directory '$BACKUP_DIR' already exists."
fi

# Check if Directories Exist
if [ ! -d "$DEST_DIR" ]; then
    Log "ERROR: Destination directory '$DEST_DIR' does not exist. Operation aborted."
    exit 1
fi

if [ ! -d "$SOURCE_DIR" ]; then
    Log "ERROR: Source directory '$SOURCE_DIR' does not exist. Operation aborted."
    exit 1
fi

# Backup Current Destination Directory using rsync
GetSafeTimestamp
SAFE_TIMESTAMP="$timestamp"
BACKUP_PATH="$BACKUP_DIR/backup_$SAFE_TIMESTAMP"
ConfirmAction "Backing up current destination directory to '$BACKUP_PATH'"
rsync -a --delete "$DEST_DIR/" "$BACKUP_PATH/" > /dev/null 2>>"$LOG_FILE"
if [ $? -ne 0 ]; then
    Log "ERROR: Failed to backup destination directory. Operation aborted."
    exit 1
else
    Log "Successfully backed up destination directory to '$BACKUP_PATH'."
fi

# Copy New Content to Destination Directory using rsync
ConfirmAction "Copying contents from '$SOURCE_DIR' to '$DEST_DIR' using rsync"
RSYNC_LOG="/tmp/rsync_log.txt"
rsync -a --delete "$SOURCE_DIR/" "$DEST_DIR/" > "$RSYNC_LOG" 2>&1
RSYNC_EXIT=$?

if [ $RSYNC_EXIT -ne 0 ]; then
    Log "ERROR: rsync encountered errors. Exit code: $RSYNC_EXIT"
    Log "Please check the rsync log file at: $RSYNC_LOG"
    cat "$RSYNC_LOG" >> "$LOG_FILE"
    exit 1
else
    Log "Successfully copied contents from '$SOURCE_DIR' to '$DEST_DIR' using rsync."
fi

# Check if critical files exist in destination
if [ ! -f "$DEST_DIR/mickle" ]; then
    Log "ERROR: Critical file 'mickle' not found in destination directory after copy."
    exit 1
fi

# Start the Application
if [ -x "$DEST_DIR/mickle" ]; then
    Log "Starting application 'mickle'..."
    "$DEST_DIR/mickle" &> /dev/null &
    if [ $? -eq 0 ]; then
        Log "Application 'mickle' started successfully."
    else
        Log "WARNING: Failed to start application 'mickle'."
    fi
else
    Log "WARNING: 'mickle' not found or is not executable in '$DEST_DIR'."
fi

Log "Update complete."
exit 0