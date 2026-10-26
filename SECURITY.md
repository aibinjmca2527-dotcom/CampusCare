# 🔒 Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

---

## 🛡️ Reporting a Vulnerability

The CampusCare team is committed to ensuring the security and privacy of campus users and data. If you discover a security vulnerability, we appreciate your help in disclosing it to us responsibly.

**Please DO NOT report security vulnerabilities through public GitHub issues.**

Instead, please report security vulnerabilities privately:
1. Open a **Private Security Advisory** via the GitHub repository [Security tab](https://github.com/aibinjmca2527-dotcom/CampusCare/security/advisories/new).
2. Alternatively, reach out directly to the maintainer via email.

Please include:
- A description of the vulnerability and its potential impact.
- Detailed step-by-step instructions or proof-of-concept to reproduce the issue.
- Any suggested mitigations or patches if available.

We will acknowledge receipt of your report within 48 hours and provide a timeline for triage and resolution.

---

## ⚠️ Best Practices for Deployments

- **Protect Secrets**: Never commit real database passwords, SMTP credentials, or secret keys to source control. Always use environment variables or local, git-ignored configuration files (`email.properties`).
- **Database User**: Avoid using the MySQL `root` user in production environments. Create a dedicated user with scoped privileges:
  ```sql
  CREATE USER 'campuscare_user'@'localhost' IDENTIFIED BY 'strong_password';
  GRANT ALL PRIVILEGES ON campuscare_db.* TO 'campuscare_user'@'localhost';
  FLUSH PRIVILEGES;
  ```
- **HTTPS / SSL**: Always terminate SSL/TLS when deploying Apache Tomcat in production to safeguard login credentials and user sessions in transit.
