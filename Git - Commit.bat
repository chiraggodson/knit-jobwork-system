@echo off
echo =============================
echo   GIT AUTO COMMIT SCRIPT
echo =============================

echo.
set /p msg="Enter commit message: "

echo.
echo 🔄 Pulling latest changes first...
git pull origin main --rebase
IF %ERRORLEVEL% NEQ 0 (
    echo ❌ Pull failed! Resolve conflicts first.
    pause
    exit /b
)

echo.
echo 📦 Adding files...
git add .

echo.
echo 💾 Committing...
git commit -m "%msg%"
IF %ERRORLEVEL% NEQ 0 (
    echo ⚠️ Nothing to commit.
    pause
    exit /b
)

echo.
echo 🚀 Pushing to GitHub...
git push origin main
IF %ERRORLEVEL% NEQ 0 (
    echo ❌ Push failed!
    pause
    exit /b
)

echo.
echo ✅ DONE SUCCESSFULLY!
pause