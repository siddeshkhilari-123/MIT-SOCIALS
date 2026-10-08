package com.mitsocials.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    // ====================================================================
    // DATABASE CONFIGURATION
    // Change these values to match your local MySQL installation.
    // ====================================================================
    private static final String DB_URL = "jdbc:mysql://localhost:3306/mit_socials?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    private static final String DB_USERNAME = "root";
    private static final String DB_PASSWORD = resolvePassword();

    private static String resolvePassword() {
        String env = System.getenv("MITSOCIALS_DB_PASSWORD");
        if (env != null && !env.isBlank()) return env;
        String prop = System.getProperty("MITSOCIALS_DB_PASSWORD");
        if (prop != null && !prop.isBlank()) return prop;
        return "";
    }

    private static final String JDBC_DRIVER = "com.mysql.cj.jdbc.Driver";

    static {
        try {
            Class.forName(JDBC_DRIVER);
        } catch (ClassNotFoundException e) {
            System.err
                    .println("ERROR: MySQL JDBC Driver not found! Ensure mysql-connector-j is included in classpath.");
            e.printStackTrace();
        }
    }

    /**
     * Obtains a new JDBC Connection to the MySQL database.
     * 
     * @return Connection object
     * @throws SQLException if a database access error occurs
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);
    }
}
