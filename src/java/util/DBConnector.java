package util;

import java.sql.*;

/**
 * Opens a connection to the Derby database.
 * Defaults match the original project; override with environment variables
 * ONESHOTBID_DB_URL, ONESHOTBID_DB_USER and ONESHOTBID_DB_PASS (no code change needed).
 */
public class DBConnector {
    private static String env(String name, String fallback) {
        String v = System.getenv(name);
        return (v == null || v.isEmpty()) ? fallback : v;
    }

    public static Connection getConnection() throws SQLException {
        String url = env("ONESHOTBID_DB_URL", "jdbc:derby://localhost:1527/auction_db");
        String user = env("ONESHOTBID_DB_USER", "app");
        String pass = env("ONESHOTBID_DB_PASS", "app");
        return DriverManager.getConnection(url, user, pass);
    }

    /** Folder where uploaded item images are stored (override with ONESHOTBID_IMAGE_DIR). */
    public static String imageDir() {
        String def = System.getProperty("os.name", "").toLowerCase().contains("win")
                ? "C:\\auction-images"
                : System.getProperty("user.home") + java.io.File.separator + "auction-images";
        return env("ONESHOTBID_IMAGE_DIR", def);
    }
}
