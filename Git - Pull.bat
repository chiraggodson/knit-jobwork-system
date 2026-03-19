@echo off
echo =============================
echo   SMART GIT PULL
echo =============================

cd /d %~dp0

echo.
echo 📌 Checking status...
git status

echo.
echo 🔄 Pulling latest changes...
git pull

IF %ERRORLEVEL% NEQ 0 (
    echo ❌ Pull failed! Resolve conflicts.
) ELSE (
    echo ✅ Pull successful!
)

pause