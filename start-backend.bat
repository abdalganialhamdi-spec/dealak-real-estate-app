@echo off
cd /d "%~dp0dealak-backend"
php artisan serve --host=10.183.151.121 --port=8000
pause
