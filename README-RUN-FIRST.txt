MIT SOCIALS - ONE CLICK FRESH START

Run from this folder:

powershell -ExecutionPolicy Bypass -File .\START-FRESH.ps1

The script finds Java 21, Tomcat 10.1.60 and MySQL, resets mit_socials, imports the schema/demo data, builds the WAR, deploys it, sets CATALINA_HOME correctly, and verifies port 8080 before saying DONE.
