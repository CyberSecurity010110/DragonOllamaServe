@echo off
setlocal EnableDelayedExpansion

echo Starting Ollama Serve Cleanup and Launch...

:: Check if 'ollama' is in PATH by trying to locate it
where ollama >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Ollama not found in PATH. Attempting to locate and add it...
    
    :: Default Ollama install path (adjust if yours is different)
    set "OLLAMA_PATH=%USERPROFILE%\AppData\Local\Programs\Ollama\ollama.exe"
    
    :: Check if Ollama exists at the default path
    if exist "!OLLAMA_PATH!" (
        echo Found Ollama at !OLLAMA_PATH!
    ) else (
        echo Ollama not found at default path. Please enter the full path to ollama.exe:
        set /p OLLAMA_PATH="Path (e.g., C:\path\to\ollama.exe): "
        if not exist "!OLLAMA_PATH!" (
            echo Error: Provided path does not exist. Exiting...
            pause
            exit /b 1
        )
    )
    
    :: Add Ollama directory to PATH for this session and permanently
    for %%F in ("!OLLAMA_PATH!") do set "OLLAMA_DIR=%%~dpF"
    set "PATH=!OLLAMA_DIR!;%PATH%"
    echo Added !OLLAMA_DIR! to PATH for this session.
    
    :: Permanently add to system PATH (requires admin)
    setx PATH "!OLLAMA_DIR!;%PATH%" /M
    if %ERRORLEVEL% EQU 0 (
        echo Permanently added !OLLAMA_DIR! to system PATH. Restart your terminal to apply globally.
    ) else (
        echo Warning: Failed to update system PATH permanently. Run as admin and try again.
    )
) else (
    echo Ollama already in PATH. Proceeding...
)

:: Run PowerShell command as a single line to kill existing Ollama processes and start ollama serve
echo Cleaning up existing Ollama processes and starting serve...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Stop-Process -Name 'ollama' -Force -ErrorAction SilentlyContinue; Start-Process -FilePath 'ollama' -ArgumentList 'serve' -NoNewWindow"

if %ERRORLEVEL% EQU 0 (
    echo Ollama Serve should now be running in the background.
) else (
    echo Error: Failed to start Ollama Serve. Check logs or process status.
)

:: Keep window open for debugging, allow minimizing
echo Script complete. Window will remain open for debugging. Minimize or close as needed.
pause
exit /b 0