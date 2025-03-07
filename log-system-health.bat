@echo off

REM -----------------------------------------------------------------
REM log-system-health.bat (No WMIC, No CPU temp)
REM 1) Uses systeminfo to get OS/Manufacturer/Model
REM 2) Creates a date-stamped file
REM 3) Commits & pushes to GitHub
REM -----------------------------------------------------------------

:: 1) Go to your cloned Git repo folder on E:
cd /d E:\Serverinfo

:: 2) Create a safe date string from %DATE%.
::    Example %DATE% = "Thu 03/09/2025"
::    We replace slashes "/" with "-", and space " " with "-"
set safeDate=%DATE:/=-%
set safeDate=%safeDate: =-%

:: 3) Construct a date-stamped filename
set LOGFILE=serverinfo_%safeDate%.txt

:: 4) Write some info to the file
echo System Info logged on %DATE% %TIME% > "%LOGFILE%"
echo. >> "%LOGFILE%"

:: Pull OS/Manufacturer/Model lines from systeminfo
:: (Adjust if your systeminfo is localized in another language.)
systeminfo | findstr /I "OS Name" >> "%LOGFILE%"
systeminfo | findstr /I "System Manufacturer" >> "%LOGFILE%"
systeminfo | findstr /I "System Model" >> "%LOGFILE%"

echo. >> "%LOGFILE%"
echo CPU Temperature is omitted here because WMIC is broken. >> "%LOGFILE%"

:: 5) Commit & push to GitHub
git add -A
git commit -m "Auto log: %DATE% %TIME%"
git push origin main

:: 6) Pause so you can see errors (remove if you want no console)
pause
