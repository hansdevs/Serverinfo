@echo off

:: 1) Switch to your repo directory
cd /d E:\Serverinfo

:: 2) Create a safe date string (replace slashes/spaces)
set safeDate=%DATE:/=-%
set safeDate=%safeDate: =-%
:: Now safeDate might look like: "Thu-03-09-2025" (depending on your locale)

:: 3) Construct a simple filename
set LOGFILE=health_%safeDate%.txt

:: 4) Write a line to that file
echo This is a test at %TIME% on %DATE% > "%LOGFILE%"

:: 5) Commit and push
git add -A
git commit -m "Testing no WMIC: %DATE% %TIME%"
git push origin main

:: 6) Pause for debugging output
pause
