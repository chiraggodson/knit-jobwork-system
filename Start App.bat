@echo off
title Full Stack App

echo Starting Backend...
start cmd /k "cd backend && npm run dev"

timeout /t 5

cd C:\Users\acb\Desktop\App Development\knit-jobwork-system\knit_jobwork_app

flutter run -d windows



pause
