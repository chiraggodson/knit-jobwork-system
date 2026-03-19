@echo off
echo =============================
echo   GIT AUTO COMMIT SCRIPT
echo =============================

echo.
set /p msg="Enter commit message: "

echo.
echo Adding files...
git add .

echo.
echo Committing...
git commit -m "%msg%"

echo.
echo Pulling latest changes...
git pull origin main --rebase

echo.
echo Pushing to GitHub...
git push origin main

echo.
echo ✅ DONE!
pause