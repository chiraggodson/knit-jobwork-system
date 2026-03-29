@echo off
title Flutter App Runner

echo ===============================
echo Starting Flutter Application
echo ===============================

cd /d "%~dp0"

flutter clean
flutter pub get
flutter run -d windows

pause
