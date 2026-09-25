Required JAR files for CampusCare
=================================

Required JARs in web/WEB-INF/lib/ (included in this project):

1. mysql-connector-j.jar   (MySQL JDBC driver)
2. jstl-1.2.jar            (JSTL 1.2 for JSP tag libraries)
3. javax.mail.jar          (JavaMail API for forgot-password email)
4. javax.activation.jar    (required by JavaMail)

Without these JARs, compile and runtime will fail.
