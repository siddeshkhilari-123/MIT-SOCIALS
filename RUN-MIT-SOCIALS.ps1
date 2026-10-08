$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$TomcatCandidates = @(
  "$env:USERPROFILE\Downloads\apache-tomcat-10.1.60-windows-x64\apache-tomcat-10.1.60",
  "$env:USERPROFILE\Downloads\apache-tomcat-10.1.60-windows-x64\apache-tomcat-10.1.60",
  "$env:USERPROFILE\Downloads\apache-tomcat-10.1.60\apache-tomcat-10.1.60",
  "C:\apache-tomcat-10.1.60"
)
$Tomcat = $TomcatCandidates | Where-Object { Test-Path "$_\bin\startup.bat" } | Select-Object -First 1
if (-not $Tomcat) {
  $Tomcat = Get-ChildItem "$env:USERPROFILE\Downloads" -Directory -Recurse -ErrorAction SilentlyContinue |
    Where-Object { Test-Path "$($_.FullName)\bin\startup.bat" } |
    Select-Object -ExpandProperty FullName -First 1
}
if (-not $Tomcat) { throw "Tomcat 10.1 was not found under Downloads. Extract Apache Tomcat 10.1.60 first." }

$Java = Get-ChildItem 'C:\Program Files\RedHat' -Directory -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -like 'java-21-openjdk*' } |
  Select-Object -First 1
if (-not $Java) {
  $Java = Get-ChildItem 'C:\Program Files\Java' -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -like 'jdk-21*' -or $_.Name -like 'java-21*' } |
    Select-Object -First 1
}
if (-not $Java) { throw "Java 21 was not found. Install/use the Java 21 already shown in your system." }
$env:JAVA_HOME = $Java.FullName
$env:JRE_HOME = $Java.FullName

$mysql = Get-ChildItem 'C:\Program Files\MySQL' -Filter mysql.exe -Recurse -ErrorAction SilentlyContinue |
  Select-Object -First 1 -ExpandProperty FullName
if (-not $mysql) { throw "mysql.exe was not found under C:\Program Files\MySQL." }

Write-Host "MIT SOCIALS ONE-CLICK START" -ForegroundColor Green
Write-Host "Project : $ProjectRoot"
Write-Host "Tomcat  : $Tomcat"
Write-Host "Java    : $env:JAVA_HOME"
Write-Host "MySQL   : $mysql"

if (-not (Get-Service MySQL80 -ErrorAction SilentlyContinue)) { Write-Warning 'MySQL80 Windows service was not found.' }
else {
  $svc = Get-Service MySQL80
  if ($svc.Status -ne 'Running') { Start-Service MySQL80; Start-Sleep -Seconds 2 }
}

if (-not $env:MITSOCIALS_DB_PASSWORD) {
  $secure = Read-Host 'Enter MySQL root password' -AsSecureString
  $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
  try { $env:MITSOCIALS_DB_PASSWORD = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
  finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
}
if (-not $env:MITSOCIALS_DB_PASSWORD) { throw 'No MySQL password supplied.' }

Write-Host 'Testing MySQL connection...' -ForegroundColor Cyan
& $mysql -u root -p$env:MITSOCIALS_DB_PASSWORD -e "SELECT 1 AS db_ok;" 2>&1
if ($LASTEXITCODE -ne 0) { throw 'MySQL login failed. The application cannot work until the root password is correct.' }

$war = Join-Path $ProjectRoot 'target\MIT-SOCIALS.war'
if (-not (Test-Path $war)) { throw "WAR not found: $war. Run mvn clean package first." }

# Stop old Tomcat instance if present; ignore if not running.
$shutdown = Join-Path $Tomcat 'bin\shutdown.bat'
if (Test-Path $shutdown) { cmd /c """$shutdown""" | Out-Null }
Start-Sleep -Seconds 2

$webapps = Join-Path $Tomcat 'webapps'
$oldDir = Join-Path $webapps 'MIT-SOCIALS'
$oldWar = Join-Path $webapps 'MIT-SOCIALS.war'
if (Test-Path $oldDir) { Remove-Item $oldDir -Recurse -Force -ErrorAction SilentlyContinue }
if (Test-Path $oldWar) { Remove-Item $oldWar -Force -ErrorAction SilentlyContinue }
Copy-Item $war $oldWar -Force

Write-Host 'Starting Tomcat with the database password inherited by the Java process...' -ForegroundColor Cyan
$startup = Join-Path $Tomcat 'bin\startup.bat'
cmd /c """$startup"""
Start-Sleep -Seconds 5

$ok = Get-NetTCPConnection -State Listen -LocalPort 8080 -ErrorAction SilentlyContinue
if (-not $ok) {
  Write-Host 'Tomcat did not open port 8080. Check Tomcat logs:' -ForegroundColor Red
  Write-Host "$Tomcat\logs"
  exit 1
}
Write-Host ''
Write-Host 'SUCCESS: MIT SOCIALS IS RUNNING.' -ForegroundColor Green
Write-Host 'Open: http://localhost:8080/MIT-SOCIALS/login.html' -ForegroundColor Yellow
Write-Host 'Do not start Tomcat from another terminal. This script passes the DB password to Tomcat.' -ForegroundColor DarkYellow
