@echo off
setlocal
cd /d "%~dp0"

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0installer-ui.ps1"

if errorlevel 1 (
  echo.
  echo [HATA] Script baslatilamadi. PowerShell'i Yonetici olarak acip su komutu deneyin:
  echo Set-ExecutionPolicy -Scope Process Bypass
  echo .\installer-ui.ps1
  echo.
  pause
)
