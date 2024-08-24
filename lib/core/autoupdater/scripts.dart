const String windowsUpdateScript = """
@echo off
setlocal enabledelayedexpansion

:: Parameters
set "DEST_DIR=%~1"
set "SOURCE_DIR=%~2"

:: Validate input parameters
if "%~1"=="" (
    echo Usage: %~nx0 [destination directory] [source directory]
    exit /b 1
)
if "%~2"=="" (
    echo Usage: %~nx0 [destination directory] [source directory]
    exit /b 1
)

:: Wait for a moment to ensure the application has exited
timeout /t 2 /nobreak >nul

:: Ensure destination directory exists
if not exist "%DEST_DIR%" (
    echo Error: Destination directory does not exist.
    exit /b 1
)

:: Clear destination directory
echo Updating contents of "%DEST_DIR%"...
for /D %%x in ("%DEST_DIR%\*") do rd /s /q "%%x" 2>nul
for %%x in ("%DEST_DIR%\*") do del /q "%%x" 2>nul

:: Move new content to destination directory
echo Moving contents from "%SOURCE_DIR%" to "%DEST_DIR%"
xcopy /s /e /q /y "%SOURCE_DIR%\*" "%DEST_DIR%\" || (
    echo Failed to copy new contents. Update aborted.
    exit /b 1
)

echo Update complete.

:: Start the application
if exist "%DEST_DIR%\talk.exe" (
    start "" "%DEST_DIR%\talk.exe"
) else (
    echo Warning: talk.exe not found in the destination directory.
)

exit /b 0
""";

const String linuxUpdateScript = """
#!/bin/bash

set -e

# Validate input parameters
if [ \$# -ne 2 ]; then
    echo "Usage: \$0 [destination directory] [source directory]"
    exit 1
fi

DEST_DIR="\$1"
SOURCE_DIR="\$2"

# Delay to ensure the application has fully exited
echo "Waiting for the application to exit..."
sleep 2

# Check if directories exist
if [ ! -d "\$DEST_DIR" ]; then
    echo "Error: Destination directory does not exist."
    exit 1
fi

if [ ! -d "\$SOURCE_DIR" ]; then
    echo "Error: Source directory does not exist."
    exit 1
fi

# Delete the contents of the destination directory
echo "Updating contents of \$DEST_DIR..."
find "\$DEST_DIR" -mindepth 1 -print0 | xargs -0 rm -rf

# Move new content to destination directory
echo "Moving contents from \$SOURCE_DIR to \$DEST_DIR"
cp -a "\$SOURCE_DIR"/. "\$DEST_DIR"/

echo "Update complete."

# Start the application
if [ -x "\$DEST_DIR/talk" ]; then
    "\$DEST_DIR/talk" &
else
    echo "Warning: Executable 'talk' not found in the destination directory."
fi
""";