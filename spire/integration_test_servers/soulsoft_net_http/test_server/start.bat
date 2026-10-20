@echo off
setlocal

set PORT=15050
set SCRIPT_DIR=%~dp0
echo Starting TestServer on http://127.0.0.1:%PORT% ...
echo Press Ctrl+C to stop.
echo.

python "%SCRIPT_DIR%server.py" --host 127.0.0.1 --port %PORT%

endlocal
