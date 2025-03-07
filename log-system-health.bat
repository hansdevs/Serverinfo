@echo off

REM -------------------------------------------------------------
REM log-system-health.bat
REM Collects basic server info, CPU temp (if available),
REM and writes them to a date-stamped file (system_health_YYYY-MM-DD.txt).
REM Then commits & pushes to GitHub.
REM -------------------------------------------------------------

:: 1) Change directory to the local repo on E:
cd /d E:\Serverinfo

:: 2) Get current date in an ISO-like format from WMI to avoid locale issues:
for /f "tokens=2 delims==" %%i in ('wmic os get LocalDateTime /value') do set currentDT=%%i
:: currentDT might look like: 20250306172116.234000-360
:: We'll extract YYYY-MM-DD from it:
set currentDate=%currentDT:~0,4%-%currentDT:~4,2%-%currentDT:~6,2%

:: 3) Construct the output file name:
set LOGFILE=system_health_%currentDate%.txt

:: 4) Gather basic system info
set OS_NAME=N/A
set MANUFACTURER=N/A
set MODEL=N/A

REM --- Operating System Name ---
for /f "tokens=1,* delims==" %%A in ('wmic os get Caption /value 2^>nul') do (
  if "%%A"=="Caption" (
    set OS_NAME=%%B
  )
)

REM --- System Manufacturer ---
for /f "tokens=1,* delims==" %%A in ('wmic computersystem get Manufacturer /value 2^>nul') do (
  if "%%A"=="Manufacturer" (
    set MANUFACTURER=%%B
  )
)

REM --- System Model ---
for /f "tokens=1,* delims==" %%A in ('wmic computersystem get Model /value 2^>nul') do (
  if "%%A"=="Model" (
    set MODEL=%%B
  )
)

:: 5) Attempt to read CPU temperature from WMI (tenths of Kelvin), convert to Celsius
set CPU_TEMP_CELSIUS=N/A
for /f "tokens=1 skip=1 delims=" %%A in ('wmic /namespace:\\root\wmi PATH MSAcpi_ThermalZoneTemperature get CurrentTemperature 2^>nul') do (
  if NOT "%%A"=="" (
    set /a rawKelvin=%%A
    set /a tempKelvin=%rawKelvin% / 10
    set /a tempCelsius=%tempKelvin% - 273
    set CPU_TEMP_CELSIUS=%tempCelsius%
  )
)

:: 6) Write all info into the daily file
(
  echo Date/Time: %date% %time%
  echo OS Name:    %OS_NAME%
  echo Vendor:     %MANUFACTURER%
  echo Model:      %MODEL%
  echo CPU Temp(C): %CPU_TEMP_CELSIUS%
) > %LOGFILE%

:: 7) Stage, commit, and push changes
git add -A
git commit -m "Auto health log: %date% %time%"
git push origin main
