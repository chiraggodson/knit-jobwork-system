@echo off
title Factory Management App

echo Starting Backend...
start cmd /k "cd backend && npm run dev"

timeout /t 5

echo Starting Flutter App...
start "" "C:\Users\Raag\Desktop\New App\knit_jobwork_app\build\windows\x64\runner\Release\knit_jobwork_app.exe"

exit
