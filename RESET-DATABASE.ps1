$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$mysql = Get-ChildItem 'C:\Program Files\MySQL' -Filter mysql.exe -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
if (-not $mysql) { throw 'mysql.exe not found under C:\Program Files\MySQL.' }
if (-not $env:MITSOCIALS_DB_PASSWORD) { $env:MITSOCIALS_DB_PASSWORD = Read-Host 'Enter MySQL root password' }
$schema = Join-Path $ProjectRoot 'database\mit_socials.sql'
$demo = Join-Path $ProjectRoot 'database\demo_data.sql'
Write-Host 'This resets mit_socials and loads the complete demo dataset.' -ForegroundColor Yellow
$answer = Read-Host 'Type RESET to continue'
if ($answer -ne 'RESET') { Write-Host 'Cancelled.'; exit }
& $mysql -u root -p$env:MITSOCIALS_DB_PASSWORD -e "DROP DATABASE IF EXISTS mit_socials; CREATE DATABASE mit_socials CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
if ($LASTEXITCODE -ne 0) { throw 'Could not create database.' }
Get-Content $schema -Raw | & $mysql -u root -p$env:MITSOCIALS_DB_PASSWORD
if ($LASTEXITCODE -ne 0) { throw 'Schema import failed.' }
Get-Content $demo -Raw | & $mysql -u root -p$env:MITSOCIALS_DB_PASSWORD
if ($LASTEXITCODE -ne 0) { throw 'Demo data import failed.' }
& $mysql -u root -p$env:MITSOCIALS_DB_PASSWORD -e "USE mit_socials; SELECT COUNT(*) AS users FROM users; SELECT COUNT(*) AS events FROM events; SELECT COUNT(*) AS clubs FROM clubs;"
Write-Host 'DATABASE RESET COMPLETE.' -ForegroundColor Green
