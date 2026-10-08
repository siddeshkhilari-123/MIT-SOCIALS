$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$TomcatCandidates = @(
  "$env:USERPROFILE\Downloads\apache-tomcat-10.1.60-windows-x64\apache-tomcat-10.1.60",
  "$env:USERPROFILE\Downloads\apache-tomcat-10.1.60\apache-tomcat-10.1.60",
  "C:\apache-tomcat-10.1.60"
)
$Tomcat = $TomcatCandidates | Where-Object { Test-Path "$_\bin\startup.bat" } | Select-Object -First 1
if (-not $Tomcat) { $Tomcat = Get-ChildItem "$env:USERPROFILE\Downloads" -Directory -Recurse -ErrorAction SilentlyContinue | Where-Object { Test-Path "$($_.FullName)\bin\startup.bat" } | Select-Object -ExpandProperty FullName -First 1 }
if (-not $Tomcat) { throw 'Tomcat 10.1.60 not found in Downloads.' }
$Java = Get-ChildItem 'C:\Program Files\RedHat' -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'java-21-openjdk*' } | Select-Object -First 1
if (-not $Java) { $Java = Get-ChildItem 'C:\Program Files\Java' -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'jdk-21*' -or $_.Name -like 'java-21*' } | Select-Object -First 1 }
if (-not $Java) { throw 'Java 21 not found.' }
$env:JAVA_HOME = $Java.FullName; $env:JRE_HOME = $Java.FullName
# Tomcat requires CATALINA_HOME to point to the actual Tomcat installation.
$env:CATALINA_HOME = $Tomcat
$env:CATALINA_BASE = $Tomcat
$mysql = Get-ChildItem 'C:\Program Files\MySQL' -Filter mysql.exe -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
if (-not $mysql) { throw 'mysql.exe not found under C:\Program Files\MySQL.' }
$dbPassword = $env:MITSOCIALS_DB_PASSWORD
if (-not $dbPassword) { $dbPassword = Read-Host 'Enter MySQL root password' }
if ([string]::IsNullOrWhiteSpace($dbPassword)) { throw 'MySQL password is required.' }
# Critical: Tomcat/JVM must inherit the same password that was just verified with mysql.exe.
$env:MITSOCIALS_DB_PASSWORD = $dbPassword
Write-Host '=== MIT SOCIALS: FRESH START ===' -ForegroundColor Green
Write-Host "Java: $env:JAVA_HOME"; Write-Host "Tomcat: $Tomcat"; Write-Host "MySQL: $mysql"
$svc = Get-Service MySQL80 -ErrorAction SilentlyContinue
if ($svc -and $svc.Status -ne 'Running') { Start-Service MySQL80; Start-Sleep 2 }
& $mysql --user=root --password=$dbPassword --connect-timeout=10 -e "SELECT 1 AS db_ok;"
if ($LASTEXITCODE -ne 0) { throw 'MySQL login failed.' }
Write-Host 'Resetting database and loading demo data...' -ForegroundColor Cyan
& $mysql --user=root --password=$dbPassword -e "DROP DATABASE IF EXISTS mit_socials; CREATE DATABASE mit_socials CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
if ($LASTEXITCODE -ne 0) { throw 'Database creation failed.' }
Get-Content (Join-Path $ProjectRoot 'database\mit_socials.sql') -Raw | & $mysql --user=root --password=$dbPassword
if ($LASTEXITCODE -ne 0) { throw 'Schema import failed.' }
Get-Content (Join-Path $ProjectRoot 'database\demo_data.sql') -Raw | & $mysql --user=root --password=$dbPassword
if ($LASTEXITCODE -ne 0) { throw 'Demo data import failed.' }
Write-Host 'Building WAR...' -ForegroundColor Cyan
Push-Location $ProjectRoot
try { & mvn clean package; if ($LASTEXITCODE -ne 0) { throw 'Maven build failed.' } } finally { Pop-Location }
$war = Join-Path $ProjectRoot 'target\MIT-SOCIALS.war'
if (-not (Test-Path $war)) { throw 'WAR was not created.' }
# Stop any existing Tomcat using this installation.
$shutdown = Join-Path $Tomcat 'bin\shutdown.bat'; if (Test-Path $shutdown) { cmd /c """$shutdown""" | Out-Null }
Start-Sleep 2
# If an old Tomcat process is still holding 8080, terminate only that process so the new WAR is actually served.
$owners = Get-NetTCPConnection -State Listen -LocalPort 8080 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -Unique
foreach ($pid in $owners) { if ($pid -and $pid -ne $PID) { try { Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue } catch {} } }
Start-Sleep 2
$webapps = Join-Path $Tomcat 'webapps'; $oldDir = Join-Path $webapps 'MIT-SOCIALS'; $oldWar = Join-Path $webapps 'MIT-SOCIALS.war'
if (Test-Path $oldDir) { Remove-Item $oldDir -Recurse -Force -ErrorAction SilentlyContinue }
if (Test-Path $oldWar) { Remove-Item $oldWar -Force -ErrorAction SilentlyContinue }
Copy-Item $war $oldWar -Force
Write-Host 'Starting Tomcat...' -ForegroundColor Cyan
& cmd.exe /c ""$(Join-Path $Tomcat 'bin\startup.bat')""
if ($LASTEXITCODE -ne 0) { throw "Tomcat startup command failed. Check $Tomcat\logs\catalina*.log" }
$opened = $false
for ($i = 0; $i -lt 15; $i++) {
  Start-Sleep 1
  if (Get-NetTCPConnection -State Listen -LocalPort 8080 -ErrorAction SilentlyContinue) { $opened = $true; break }
}
if (-not $opened) { throw "Tomcat did not open port 8080. Check $Tomcat\logs\catalina*.log" }
# Give the webapp a moment to deploy, then verify the application's DB health endpoint.
Start-Sleep 3
try {
  $health = Invoke-WebRequest -UseBasicParsing -Uri 'http://localhost:8080/MIT-SOCIALS/api/health' -TimeoutSec 10
  if ($health.StatusCode -ne 200) { throw 'Health endpoint did not return HTTP 200.' }
  Write-Host 'Database health check: OK' -ForegroundColor Green
} catch {
  Write-Host 'Tomcat is listening, but the MIT-SOCIALS application/DB health check failed.' -ForegroundColor Red
  Write-Host "Check: $Tomcat\logs\localhost*.log and $Tomcat\logs\catalina*.log"
  throw
}
Write-Host ''
Write-Host 'DONE. Open this:' -ForegroundColor Green
Write-Host 'http://localhost:8080/MIT-SOCIALS/login.html' -ForegroundColor Yellow
Write-Host 'Demo login: demo.aarav@mit.edu (password depends on demo account setup; use Register for your own account).' -ForegroundColor DarkYellow
