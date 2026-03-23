@echo off
echo =============================
echo   GIT STATUS CHECK
echo =============================

echo.
echo Current Branch:
git branch --show-current

echo.
echo Status:
git status

echo.
echo Last Commit:
git log -1 --oneline

echo.
pause