# CampusCare

Smart campus issue reporting system built with Java Servlets, JSP, and MySQL.

## Project structure

```
CampusCare/
├── web/                 JSP pages, CSS, WEB-INF
├── src/java/com/campuscare/
│   ├── servlet/         Login, Register, ReportIssue, etc.
│   ├── db/              DBConnection
│   ├── util/            Upload, Mail
│   └── model/           User, Issue
├── CampusCare.sql       Full database setup
├── campuscare_db.sql    Same schema (alternate name)
└── database-migration-profile.sql
```

## Setup (NetBeans / Tomcat)

1. Open `CampusCare` as a Java Web Application.
2. Add **MySQL Connector/J** and **JavaMail API** (javax.mail) to Libraries.
3. Run `CampusCare.sql` in MySQL Workbench.
4. Edit `src/java/com/campuscare/db/DBConnection.java` — set your MySQL username and password.
5. Optional forgot-password email: copy `web/WEB-INF/email.properties.example` to `web/WEB-INF/email.properties` and fill in SMTP settings.
6. Clean and Build, then Run.

## Default admin account

| Field    | Value                    |
|----------|--------------------------|
| Email    | admin@campuscare.com     |
| Password | admin123                 |

## Features

- User registration and login
- Submit campus issues with optional photo
- Admin issue management and user management
- Profile update (name, password, photo)
- Forgot password via email (when SMTP is configured)
- White top navigation (classic layout)
