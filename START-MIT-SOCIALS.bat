@echo off
title MIT Socials - Start
setlocal

echo.
echo ==========================================
echo        MIT SOCIALS - STARTING
echo ==========================================
echo.

REM Find Java 21 automatically
for /d %%J in ("C:\Program Files\RedHat\java-21-openjdk*") do (
    if exist "%%J\bin\java.exe" set "JAVA_HOME=%%J"
)

if not defined JAVA_HOME (
    echo ERROR: Java 21 was not found.
    echo.
    pause
    exit /b 1
)

set "CATALINA_HOME=C:\Users\siddesh\Downloads\apache-tomcat-10.1.60-windows-x64\apache-tomcat-10.1.60"

echo Java: %JAVA_HOME%
echo Tomcat: %CATALINA_HOME%
echo.

REM Start MySQL if it is not running
echo Checking MySQL...
sc query MySQL80 | findstr /I "RUNNING" >nul
if errorlevel 1 (
    echo Starting MySQL...
    net start MySQL80
) else (
    echo MySQL is already running.
)

echo.

REM Check whether Tomcat is already running
powershell -NoProfile -Command "$x=(Test-NetConnection -ComputerName localhost -Port 8080 -WarningAction SilentlyContinue).TcpTestSucceeded; if($x){exit 0}else{exit 1}"

if errorlevel 1 (
    echo Starting Tomcat...
    call "%CATALINA_HOME%\bin\startup.bat"
    echo Waiting for Tomcat...
    timeout /t 8 /nobreak >nul
) else (
    echo Tomcat is already running.
)

echo.
echo Opening MIT Socials...
powershell -NoProfile -Command "Start-Process 'http://localhost:8080/MIT-SOCIALS/'"

echo.
echo ==========================================
echo       MIT SOCIALS IS READY
echo ==========================================
echo.
echo URL: http://localhost:8080/MIT-SOCIALS/
echo.
echo You can close this window.
echo ==========================================
timeout /t 5 /nobreak >nul

endlocal
