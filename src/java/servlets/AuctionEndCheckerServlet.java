package servlets;

import util.DBConnector;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/AuctionEndCheckerServlet")
public class AuctionEndCheckerServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnector.getConnection();

            // Step 1: Get all active auctions that have ended
            String getEndedAuctions = "SELECT Auction_ID FROM Auctions WHERE Status = 'active' AND End_Time <= CURRENT_TIMESTAMP";
            ps = conn.prepareStatement(getEndedAuctions);
            rs = ps.executeQuery();

            while (rs.next()) {
                int auctionId = rs.getInt("Auction_ID");

                // Step 2: Get highest bid for that auction
                String highestBidSql = "SELECT User_ID, Bid_Amount FROM Bids WHERE Auction_ID = ? ORDER BY Bid_Amount DESC FETCH FIRST 1 ROWS ONLY";
                try (PreparedStatement ps2 = conn.prepareStatement(highestBidSql)) {
                    ps2.setInt(1, auctionId);
                    ResultSet rs2 = ps2.executeQuery();

                    if (rs2.next()) {
                        int winnerId = rs2.getInt("User_ID");
                        double amount = rs2.getDouble("Bid_Amount");

                        // Step 3: Insert into Payments
                        String insertPayment = "INSERT INTO Payments (User_ID, Auction_ID, Amount_Paid, Payment_status) VALUES (?, ?, ?, 'pending')";
                        try (PreparedStatement ps3 = conn.prepareStatement(insertPayment)) {
                            ps3.setInt(1, winnerId);
                            ps3.setInt(2, auctionId);
                            ps3.setDouble(3, amount);
                            ps3.executeUpdate();
                        }

                        // Step 4: Insert Notification
                        String insertNotif = "INSERT INTO Notifications (User_ID, Message) VALUES (?, ?)";
                        String message = "Congratulations! You won the auction #" + auctionId + ". Please proceed with payment.";
                        try (PreparedStatement ps4 = conn.prepareStatement(insertNotif)) {
                            ps4.setInt(1, winnerId);
                            ps4.setString(2, message);
                            ps4.executeUpdate();
                        }
                    }

                    rs2.close();
                }

                // Step 5: Update auction status to 'ended'
                String updateAuction = "UPDATE Auctions SET Status = 'ended' WHERE Auction_ID = ?";
                try (PreparedStatement ps5 = conn.prepareStatement(updateAuction)) {
                    ps5.setInt(1, auctionId);
                    ps5.executeUpdate();
                }
            }

            response.getWriter().println("Auction processing completed.");

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error while processing auctions.");
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
    }
}
