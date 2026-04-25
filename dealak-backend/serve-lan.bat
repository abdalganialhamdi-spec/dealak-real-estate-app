@echo off
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4"') do (
    for /f "tokens=1-4 delims=." %%b in ("%%a") do (
        set LAN_IP=%%b.%%c.%%d.%%e
        goto :found
    )
)
:found
set LAN_IP=%LAN_IP: =%
echo ============================================
echo   DEALAK Laravel Server - LAN Mode
echo ============================================
echo.
echo   Local:   http://localhost:8000
echo   Network: http://%LAN_IP%:8000
echo.
echo   Press Ctrl+C to stop the server
echo ============================================
echo.

php artisan serve --host=0.0.0.0 --port=8000