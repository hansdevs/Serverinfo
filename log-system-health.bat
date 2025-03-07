@echo off

REM ---------------------------------------------------
REM log-system-health.bat - Fallback version
REM Uses %DATE% for filename, tries WMI calls gently.
REM ---------------------------------------------------

:: 1) Go to your repo folder on E:
cd /d E:\Serverinfo

:: 2) Create a "safe" date string from %DATE%.
::    %DATE% often looks like: "Thu 03/09/2025" depending on locale.
::    We'll replace slashes with dashes, remove spaces, etc.
set safeDate=%DATE:/=-%
set safeDate=%safeDate: =_%

:: Now safeDate might look like: "Thu_03-09-2025"
:: You can trim the leading day if you want, but let's keep it simple.
set LOGFILE=system_health_%safeDate%.txt

echo Logging to: %LOGFILE%

:: 3) Collect Basic Info with WMI calls (if they exist).
::    If WMIC is removed or fails, we won't break the script.

:: -- OS Name --
set OS_NAME=N/A
for /f "tokens=1,* delims==" %%A in ('wmic os get Caption /value 2^>nul') do (
  if "%%A"=="Caption" (
    set OS_NAME=%%B
  )
)

:: -- Manufacturer --
set MANUFACTURER=N/A
for /f "tokens=1,* delims==" %%A in ('wmic computersystem get Manufacturer /value 2^>nul') do (
  if "%%A"=="Manufacturer" (
    set MANUFACTURER=%%B
  )
)

:: -- Model --
set MODEL=N/A
for /f "tokens=1,* delims==" %%A in ('wmic computersystem get Model /value 2^>nul') do (
  if "%%A"=="Model" (
    set MODEL=%%B
  )
)

:: 4) Attempt to read CPU temperature (if WMIC is present).
set CPU_TEMP_CELSIUS=N/A
for /f "tokens=1 skip=1 delims=" %%A in ('wmic /namespace:\\root\wmi PATH MSAcpi_ThermalZoneTemperature get CurrentTemperature 2^>nul') do (
  if NOT "%%A"=="" (
    set /a rawKelvin=%%A 2>nul
    if "%ERRORLEVEL%"=="0" (
      set /a tempKelvin=%rawKelvin% / 10
      set /a tempCelsius=%tempKelvin% - 273
      set CPU_TEMP_CELSIUS=%tempCelsius%
    )
  )
)

:: 5) Write out info to the daily file (overwrite or append, your choice).
(
  echo Date/Time: %DATE% %TIME%
  echo OS Name:    %OS_NAME%
  echo Vendor:     %MANUFACTURER%
  echo Model:      %MODEL%
  echo CPU Temp(C): %CPU_TEMP_CELSIUS%
) > "%LOGFILE%"

:: 6) Commit and push. Add some error echo & pause for debugging.
git add -A
git commit -m "Auto health log: %DATE% %TIME%"
git push origin main

IF ERRORLEVEL 1 (
  echo ERROR: Git push failed!
) ELSE (
  echo SUCCESS: Git push completed.
)

pause
