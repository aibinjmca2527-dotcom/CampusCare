package com.campuscare.db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Manages database connectivity for the CampusCare application.
 * Supports configurable connection parameters via environment variables,
 * JVM system properties, or default local settings.
 */
public final class DBConnection {

    private static final String DEFAULT_URL = 
            "jdbc:mysql://localhost:3306/campuscare_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    private static final String DEFAULT_USER = "root";
    private static final String DEFAULT_PASSWORD = "";

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MySQL JDBC driver not found.", e);
        }
    }

    private DBConnection() {
        // Prevent instantiation
    }

    /**
     * Obtains an active connection to the MySQL database.
     * Evaluates DB_URL, DB_USER, and DB_PASSWORD environment variables/system properties
     * with fallback to standard localhost defaults.
     *
     * @return active java.sql.Connection instance
     * @throws SQLException if a database access error occurs
     */
    public static Connection getConnection() throws SQLException {
        String url = System.getenv("DB_URL");
        if (url == null || url.trim().isEmpty()) {
            url = System.getProperty("db.url", DEFAULT_URL);
        }

        String user = System.getenv("DB_USER");
        if (user == null || user.trim().isEmpty()) {
            user = System.getProperty("db.user", DEFAULT_USER);
        }

        String password = System.getenv("DB_PASSWORD");
        if (password == null) {
            password = System.getProperty("db.password", DEFAULT_PASSWORD);
        }

        return DriverManager.getConnection(url, user, password);
    }
}
