MIT SOCIALS - RUN THIS, NOT RANDOM TERMINALS

1. From PowerShell, inside this MIT-SOCIALS folder, run:
   .\RESET-DATABASE.ps1
   Type RESET when asked.

2. Build once:
   mvn clean package

3. Start everything with ONE command:
   .\RUN-MIT-SOCIALS.ps1

4. Open:
   http://localhost:8080/MIT-SOCIALS/login.html

The launcher automatically:
- finds Java 21
- starts MySQL80 if needed
- asks for the MySQL root password
- verifies MySQL login
- stops the old Tomcat instance
- replaces the old MIT-SOCIALS WAR
- starts Tomcat with the password inherited by the Java process
- verifies port 8080

Do NOT manually start Tomcat from a different terminal after using the launcher.
