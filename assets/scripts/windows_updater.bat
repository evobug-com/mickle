@echo off
setlocal EnableDelayedExpansion

:: ================================================
:: Update Script for Mickle - Updated Version
:: ================================================
:: This script updates the Mickle application by:
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
set "BACKUP_DIR=%TEMP%\mickle\backups"

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
if not exist "%DEST_DIR%\mickle.exe" (
    call :Log "ERROR: Critical file 'mickle.exe' not found in destination directory after copy."
    exit /b 1
)

:: Start the Application
if exist "%DEST_DIR%\mickle.exe" (
    call :Log "Starting application 'mickle.exe'..."
    start "" "%DEST_DIR%\mickle.exe" >nul 2>>"%LOG_FILE%" && call :Log "Application 'mickle.exe' started successfully." || (
        call :Log "WARNING: Failed to start application 'mickle.exe'."
    )
) else (
    call :Log "WARNING: 'mickle.exe' not found in '%DEST_DIR%'."
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