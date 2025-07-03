package servlets;

import util.DBConnector;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.sql.*;
import java.util.Timer;
import java.util.TimerTask;

@WebListener
public class AuctionEndChecker implements ServletContextListener {

    private Timer timer;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        timer = new Timer(true); // background daemon
        timer.scheduleAtFixedRate(new TimerTask() {
            public void run() {
                try (Connection conn = DBConnector.getConnection()) {

                    String getEndedAuctions = "SELECT Auction_ID FROM Auctions WHERE Status = 'active' AND End_Time <= CURRENT_TIMESTAMP";
                    try (PreparedStatement ps = conn.prepareStatement(getEndedAuctions);
                         ResultSet rs = ps.executeQuery()) {

                        while (rs.next()) {
                            int auctionId = rs.getInt("Auction_ID");

                            // Get highest bid
                            String highestBidSql = "SELECT User_ID, Bid_Amount FROM Bids WHERE Auction_ID = ? ORDER BY Bid_Amount DESC FETCH FIRST 1 ROWS ONLY";
                            try (PreparedStatement ps2 = conn.prepareStatement(highestBidSql)) {
                                ps2.setInt(1, auctionId);
                                ResultSet rs2 = ps2.executeQuery();

                                if (rs2.next()) {
                                    int winnerId = rs2.getInt("User_ID");
                                    double amount = rs2.getDouble("Bid_Amount");

                                    // Insert payment
                                    String insertPayment = "INSERT INTO Payments (User_ID, Auction_ID, Amount_Paid, Payment_status) VALUES (?, ?, ?, 'pending')";
                                    try (PreparedStatement ps3 = conn.prepareStatement(insertPayment)) {
                                        ps3.setInt(1, winnerId);
                                        ps3.setInt(2, auctionId);
                                        ps3.setDouble(3, amount);
                                        ps3.executeUpdate();
                                    }

                                    // Insert notification
                                    String insertNotif = "INSERT INTO Notifications (User_ID, Message) VALUES (?, ?)";
                                    String message = "Congratulations! You won auction #" + auctionId + ". Please proceed with payment.";
                                    try (PreparedStatement ps4 = conn.prepareStatement(insertNotif)) {
                                        ps4.setInt(1, winnerId);
                                        ps4.setString(2, message);
                                        ps4.executeUpdate();
                                    }
                                }
                                rs2.close();
                            }

                            // Mark auction as ended
                            String updateAuction = "UPDATE Auctions SET Status = 'ended' WHERE Auction_ID = ?";
                            try (PreparedStatement ps5 = conn.prepareStatement(updateAuction)) {
                                ps5.setInt(1, auctionId);
                                ps5.executeUpdate();
                            }
                        }
                    }

                } catch (Exception e) {
                    System.err.println("AuctionEndChecker error:");
                    e.printStackTrace();
                }
            }
        }, 0, 60 * 1000); // every 60 seconds
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (timer != null) {
            timer.cancel();
        }
    }
}
