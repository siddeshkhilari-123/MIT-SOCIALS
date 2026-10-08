# MIT Socials

A beginner-friendly college social platform built only with HTML5, CSS3, Vanilla JavaScript, Core Java, Java Servlets, JDBC, MySQL and Apache Tomcat 10.1.

## Main modules

Dashboard, Digital Identity, Student Portal, Career, Community, Sports & Cultural, Analytics, 3D Sports, 3D Campus, Student Directory, Clubs, Events, Digital Yearbook, Notifications, Messaging, Leaderboard and Admin.

## Requirements

- JDK 21
- Maven 3.9+
- MySQL 8+
- Apache Tomcat 10.1+

## Database

Run `database/mit_socials.sql` in MySQL. The script creates the original social-network tables plus academic/career/campus tables and sample data.

## Database password

Do not hard-code your MySQL password. In PowerShell before starting Tomcat:

```powershell
$env:MITSOCIALS_DB_PASSWORD="YOUR_MYSQL_PASSWORD"
```

The application connects to `localhost:3306/mit_socials` as `root` by default.

## Build

From the folder containing `pom.xml`:

```powershell
mvn clean package
```

The generated WAR is `target/MIT-SOCIALS.war`.

## Deploy to Tomcat

Copy the WAR into Tomcat's `webapps` folder, then start Tomcat with:

```powershell
$env:JAVA_HOME="C:\Path\To\jdk-21"
$env:JRE_HOME=$env:JAVA_HOME
cd "C:\Path\To\apache-tomcat-10.1.60\bin"
.\catalina.bat run
```

Open `http://localhost:8080/MIT-SOCIALS/`.

## Architecture

Browser -> Vanilla JS -> Java Servlet -> DAO/JDBC -> MySQL.

`PlatformServlet` provides the main database-backed application API. Existing authentication/profile servlets remain separate so the project is easy to explain in a viva.

## Campus Navigator UI

The 3D Campus module follows the supplied hand-drawn campus plan as the source of truth for placement and the supplied EcoSpace screenshot as the visual style reference. It uses a lightweight SVG/CSS isometric presentation (no frontend framework and no 3D framework) with clickable Academic Buildings 1–3, Basketball Court, Hostel, Gazebo, Main Ground and Swimming Pool. The former Library/Sports-3D concepts are not part of this campus view.

## Demo Data (Recommended for Screenshots)

The project includes `database/demo_data.sql` with non-destructive demo content: students, profiles, feed posts, comments, likes, future 2026 events, clubs, communities, messages, notifications, jobs, sports/cultural records and leaderboard entries.

Run `mit_socials.sql` first for a fresh database. If the schema already exists, run only `demo_data.sql` afterward to populate the app without dropping existing tables.


## IMPORTANT FIX
The fresh-start script uses the MySQL password as a single explicit `--password=...` argument. If MySQL login works manually, this avoids the PowerShell `-p...` parsing issue in the previous package.
