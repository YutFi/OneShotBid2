package util;

import java.sql.*;

public class DBConnector {
    public static Connection getConnection() throws SQLException {
        String url = "jdbc:derby://localhost:1527/auction_db";
        String user = "app";
        String pass = "app";
        return DriverManager.getConnection(url, user, pass);
    }
}
