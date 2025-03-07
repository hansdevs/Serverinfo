@echo off

REM -----------------------------------------
REM log-system-health.bat
REM Minimal daily CPU temp logger for GitHub
REM -----------------------------------------

:: 1) Change to the local repo directory on E:
cd /d E:\Serverinfo

:: 2) Name of the log file
set LOGFILE=system_health_log.txt

:: 3) Attempt to read CPU temperature from WMI (tenths of Kelvin)
set CPU_TEMP_CELSIUS=N/A

for /f "tokens=1 skip=1 delims=" %%A in ('wmic /namespace:\\root\wmi PATH MSAcpi_ThermalZoneTemperature get CurrentTemperature 2^>nul') do (
  if NOT "%%A"=="" (
    set /a rawKelvin=%%A
    set /a tempKelvin=%rawKelvin% / 10
    set /a tempCelsius=%tempKelvin% - 273
    set CPU_TEMP_CELSIUS=%tempCelsius%
  )
)

:: 4) Append date/time and CPU temp (or N/A) to the log file
echo %date% %time% - CPU Temp (C) = %CPU_TEMP_CELSIUS% >> %LOGFILE%

:: 5) Stage, commit, and push changes
git add -A
git commit -m "Auto health log: %date% %time%"
git push origin main
