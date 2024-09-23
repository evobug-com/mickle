const String windowsUpdateScript = r"""
@echo off
setlocal EnableDelayedExpansion

:: ================================================
:: Update Script for SiocomTalk - Updated Version
:: ================================================
:: This script updates the SiocomTalk application by:
:: 1. Validating input paths.
:: 2. Creating backups before update.
:: 3. Using Robocopy for efficient file operations.
:: 4. Logging actions with timestamps.
:: 5. Starting the application after update.
:: ================================================

:: -----------------------
:: Configuration
:: -----------------------
set "ENABLE_CONFIRM=1"  :: Set to 1 to enable confirmations, 0 to disable
set "ENABLE_LOG=1"      :: Set to 1 to enable logging to file, 0 to disable
set "LOG_FILE=%TEMP%\update_log.txt"
set "BACKUP_DIR=%TEMP%\SiocomTalk_Backups"

:: -----------------------
:: Parameters
:: -----------------------
set "DEST_DIR=%~1"
set "SOURCE_DIR=%~2"

:: -----------------------
:: Validate Input Parameters
:: -----------------------
if "%~1"=="" (
    echo Usage: %~nx0 [destination directory] [source directory]
    exit /b 1
)
if "%~2"=="" (
    echo Usage: %~nx0 [destination directory] [source directory]
    exit /b 1
)

:: -----------------------
:: Initialize Log File
:: -----------------------
if "%ENABLE_LOG%"=="1" (
    echo Update Script Log - %date% %time% > "%LOG_FILE%"
    echo ============================================ >> "%LOG_FILE%"
)

:: -----------------------
:: Main Execution Flow
:: -----------------------

:: Ensure DEST_DIR and SOURCE_DIR are absolute paths
if not "%DEST_DIR:~1,1%"==":" (
    call :Log "ERROR: Destination directory '%DEST_DIR%' is not an absolute path. Operation aborted."
    exit /b 1
)
if not "%SOURCE_DIR:~1,1%"==":" (
    call :Log "ERROR: Source directory '%SOURCE_DIR%' is not an absolute path. Operation aborted."
    exit /b 1
)

:: Validate Paths are Safe
call :IsSafePath "%DEST_DIR%" || exit /b 1
call :IsSafePath "%SOURCE_DIR%" || exit /b 1

:: Create Backup Directory
if not exist "%BACKUP_DIR%" (
    mkdir "%BACKUP_DIR%" && call :Log "Created backup directory at '%BACKUP_DIR%'."
    if %ERRORLEVEL% NEQ 0 (
        call :Log "ERROR: Failed to create backup directory at '%BACKUP_DIR%'. Operation aborted."
        exit /b 1
    )
) else (
    call :Log "Backup directory '%BACKUP_DIR%' already exists."
)

:: Check if Directories Exist
if not exist "%DEST_DIR%" (
    call :Log "ERROR: Destination directory '%DEST_DIR%' does not exist. Operation aborted."
    exit /b 1
)

if not exist "%SOURCE_DIR%" (
    call :Log "ERROR: Source directory '%SOURCE_DIR%' does not exist. Operation aborted."
    exit /b 1
)

:: Backup Current Destination Directory using Robocopy
call :GetSafeTimestamp
set "SAFE_TIMESTAMP=!timestamp!"
set "BACKUP_PATH=%BACKUP_DIR%\backup_!SAFE_TIMESTAMP!"
call :ConfirmAction "Backing up current destination directory to '%BACKUP_PATH%'"
robocopy "%DEST_DIR%" "%BACKUP_PATH%" /MIR /COPY:DAT /R:3 /W:5 /NP /NDL /NFL /NJH /NJS >nul 2>>"%LOG_FILE%"
if %ERRORLEVEL% GEQ 8 (
    call :Log "ERROR: Failed to backup destination directory. Operation aborted."
    exit /b 1
) else (
    call :Log "Successfully backed up destination directory to '%BACKUP_PATH%'."
)

:: Copy New Content to Destination Directory using Robocopy
call :ConfirmAction "Copying contents from '%SOURCE_DIR%' to '%DEST_DIR%' using Robocopy"
set "ROBOCOPY_LOG=%TEMP%\robocopy_log.txt"
robocopy "%SOURCE_DIR%" "%DEST_DIR%" /MIR /COPY:DAT /R:3 /W:5 /TEE /LOG:"%ROBOCOPY_LOG%"
set "ROBOCOPY_EXIT=%ERRORLEVEL%"

:: Interpret Robocopy exit code
if %ROBOCOPY_EXIT% GEQ 8 (
    call :Log "ERROR: Robocopy encountered errors. Exit code: %ROBOCOPY_EXIT%"
    call :Log "Please check the Robocopy log file at: %ROBOCOPY_LOG%"
    type "%ROBOCOPY_LOG%" >> "%LOG_FILE%"
    exit /b 1
) else (
    call :Log "Successfully copied contents from '%SOURCE_DIR%' to '%DEST_DIR%' using Robocopy."
)

:: Check if critical files exist in destination
if not exist "%DEST_DIR%\talk.exe" (
    call :Log "ERROR: Critical file 'talk.exe' not found in destination directory after copy."
    exit /b 1
)

:: Start the Application
if exist "%DEST_DIR%\talk.exe" (
    call :Log "Starting application 'talk.exe'..."
    start "" "%DEST_DIR%\talk.exe" >nul 2>>"%LOG_FILE%" && call :Log "Application 'talk.exe' started successfully." || (
        call :Log "WARNING: Failed to start application 'talk.exe'."
    )
) else (
    call :Log "WARNING: 'talk.exe' not found in '%DEST_DIR%'."
)

call :Log "Update complete."
exit /b 0

:: -----------------------
:: Prevent Accidental Fall-Through
:: -----------------------
goto :EOF

:: -----------------------
:: Function Definitions
:: -----------------------

:: Function to Log Messages with Timestamps
:Log
set "message=%~1"
if "%ENABLE_LOG%"=="1" (
    echo [%date% %time%] %message% >> "%LOG_FILE%"
)
echo [%date% %time%] %message%
goto :EOF

:: Function to Confirm Actions
:ConfirmAction
set "action=%~1"
if "%ENABLE_CONFIRM%"=="1" (
    call :Log "ACTION: %action%"
    set /p ="Confirm? Press Enter to continue or Ctrl+C to abort..."
) else (
    call :Log "ACTION: %action%"
)
goto :EOF

:: Function to Validate Safe Paths
:IsSafePath
set "testPath=%~1"
set "unsafe=0"
:: Remove trailing backslash if it exists
if "%testPath:~-1%"=="\" set "testPath=%testPath:~0,-1%"

:: Check if testPath is exactly any of the critical directories
for %%i in (
    "%SystemDrive%"
    "%SystemRoot%"
    "%ProgramFiles%"
    "%ProgramFiles(x86)%"
    "%AllUsersProfile%"
    "%Public%"
) do (
    if /i "%testPath%"=="%%~i" set "unsafe=1"
)

:: Check if testPath is the root of %UserProfile%
if /i "%testPath%"=="%UserProfile%" set "unsafe=1"

if "%unsafe%"=="1" (
    call :Log "ERROR: Attempted to operate on critical system directory '%testPath%'. Operation aborted."
    exit /b 1
)
goto :EOF

:: Function to Get a Safe Timestamp for Backup Naming
:GetSafeTimestamp
:: Using WMIC to get a consistent timestamp format (YYYY-MM-DD_HHMMSS)
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "timestamp=%dt:~0,4%-%dt:~4,2%-%dt:~6,2%_%dt:~8,2%%dt:~10,2%%dt:~12,2%"
goto :EOF
""";

const String linuxUpdateScript = r"""
#!/bin/bash
set -e

# ================================================
# Update Script for SiocomTalk - Unix Version
# ================================================
# This script updates the SiocomTalk application by:
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
BACKUP_DIR="/tmp/SiocomTalk_Backups"

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
if [ ! -f "$DEST_DIR/talk" ]; then
    Log "ERROR: Critical file 'talk' not found in destination directory after copy."
    exit 1
fi

# Start the Application
if [ -x "$DEST_DIR/talk" ]; then
    Log "Starting application 'talk'..."
    "$DEST_DIR/talk" &> /dev/null &
    if [ $? -eq 0 ]; then
        Log "Application 'talk' started successfully."
    else
        Log "WARNING: Failed to start application 'talk'."
    fi
else
    Log "WARNING: 'talk' not found or is not executable in '$DEST_DIR'."
fi

Log "Update complete."
exit 0

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
""";
