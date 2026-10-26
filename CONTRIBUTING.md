# 🤝 Contributing to CampusCare

Thank you for your interest in contributing to **CampusCare**! We welcome contributions from developers, designers, and students of all skill levels. Whether you are fixing a bug, adding a new feature, improving documentation, or styling user interfaces, your support is greatly appreciated.

---

## 📋 Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md). Please treat all contributors with kindness, empathy, and respect.

---

## 🛠️ Getting Started

1. **Fork the Repository**:
   Click the **Fork** button on the top-right corner of the [CampusCare GitHub repository](https://github.com/aibinjmca2527-dotcom/CampusCare).

2. **Clone Your Fork**:
   ```bash
   git clone https://github.com/<your-username>/CampusCare.git
   cd CampusCare
   ```

3. **Set Up the Upstream Remote**:
   ```bash
   git remote add upstream https://github.com/aibinjmca2527-dotcom/CampusCare.git
   ```

4. **Create a Feature Branch**:
   ```bash
   git checkout -b feature/my-new-feature
   ```

---

## 💻 Development Workflow

1. **Import Project**:
   - Open NetBeans IDE (or Eclipse / IntelliJ IDEA).
   - Open the directory as a Java Web Application.
   - Ensure JDK 8+ and Apache Tomcat 9/10 are configured.

2. **Database Setup**:
   - Run `CampusCare.sql` in your local MySQL instance.
   - Configure credentials in `src/java/com/campuscare/db/DBConnection.java` or via environment variables (`DB_URL`, `DB_USER`, `DB_PASSWORD`).

3. **Email Configuration (Optional)**:
   - Copy `web/WEB-INF/email.properties.example` to `web/WEB-INF/email.properties`.
   - Never commit `email.properties` containing real passwords.

4. **Coding Guidelines**:
   - Follow standard Java naming conventions (PascalCase for classes, camelCase for methods and variables).
   - Use prepared statements (`PreparedStatement`) for all database operations to prevent SQL injection vulnerabilities.
   - Keep JSP presentation logic clean; delegate business and database logic to Servlets and Utility classes.
   - Maintain mobile-responsive design standards in `web/css/style.css`.

---

## 📬 Submitting a Pull Request (PR)

1. **Commit Your Changes**:
   Write clear, concise commit messages following standard conventions:
   ```bash
   git commit -m "feat: add category-based issue export to CSV"
   ```

2. **Rebase with Upstream**:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

3. **Push to Your Fork**:
   ```bash
   git push origin feature/my-new-feature
   ```

4. **Open a Pull Request**:
   - Go to your fork on GitHub and click **Compare & pull request**.
   - Fill out the provided PR template thoroughly.
   - Link any related issues (e.g. `Fixes #12`).

---

## 🐛 Reporting Bugs

If you find a bug, please check the [Issues](https://github.com/aibinjmca2527-dotcom/CampusCare/issues) page first to see if it has already been reported. If not, open a new issue using our **Bug Report** template, including:
- Clear description of the unexpected behavior
- Steps to reproduce
- Screenshots or console log snippets
- Operating System, Tomcat version, and browser used
