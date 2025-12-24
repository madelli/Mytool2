@echo off
title MyTool App Launcher

echo Starting MyTool server...

:: GUI を自動で開く
start "" "http://localhost:8000/index.html"

:: PowerShell サーバー起動
powershell -ExecutionPolicy Bypass -File "C:\Mytool_ver2\server.ps1"

pause

