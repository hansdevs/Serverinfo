@echo off

REM ---------------------------------------------------
REM log-system-health.bat
REM Logs basic system info, attempts CPU temp, 
REM commits & pushes to GitHub.
REM ---------------------------------------------------

:: 1) Go to the local repo folder
cd /d E:\Serverinfo

:: 2) Create a safe date string from %DATE%.
::    Typical %DATE% might be: "Fri 03/10/2025" 
::    We'll replace / with -, and space with -
set safeDate=%DATE:/=-%
set safeDate=%safeDate: =-%

:: 3) Construct a date-stamped filename
set LOGFILE=system_health_%safeDate%.txt

:: 4) Gather OS, manufacturer, model (N/A if WMIC fails)
set OS_NAME=N/A
for /f "tokens=1,* delims==" %%A in ('wmic os get Caption /value 2^>nul') do (
  if "%%A"=="Caption" set OS_NAME=%%B
)

set MANUFACTURER=N/A
for /f "tokens=1,* delims==" %%A in ('wmic computersystem get Manufacturer /value 2^>nul') do (
  if "%%A"=="Manufacturer" set MANUFACTURER=%%B
)

set MODEL=N/A
for /f "tokens=1,* delims==" %%A in ('wmic computersystem get Model /value 2^>nul') do (
  if "%%A"=="Model" set MODEL=%%B
)

:: 5) Attempt CPU temp (Celsius). Many systems won't expose this via WMI -> "N/A"
set CPU_TEMP=N/A
for /f "tokens=1 skip=1 delims=" %%A in ('wmic /namespace:\\root\wmi PATH MSAcpi_ThermalZoneTemperature get CurrentTemperature 2^>nul') do (
  if NOT "%%A"=="" (
    set /a rawKelvin=%%A 2>nul
    if "%ERRORLEVEL%"=="0" (
      set /a tempKelvin=%rawKelvin% / 10
      set /a tempCelsius=%tempKelvin% - 273
      set CPU_TEMP=%tempCelsius%
    )
  )
)

:: 6) Write all info to the daily file
(
  echo Date/Time: %DATE% %TIME%
  echo OS Name: %OS_NAME%
  echo Manufacturer: %MANUFACTURER%
  echo Model: %MODEL%
  echo CPU Temp (C): %CPU_TEMP%
) > "%LOGFILE%"

:: 7) Commit & push
git add -A
git commit -m "Automated system info on %DATE% %TIME%"
git push origin main

:: 8) Pause for debugging; remove if you want no console pop-up
pause
