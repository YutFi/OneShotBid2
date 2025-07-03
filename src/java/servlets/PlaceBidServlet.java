package servlets;

import bean.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import util.DBConnector;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.*;

@WebServlet("/PlaceBidServlet")
public class PlaceBidServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int auctionId = Integer.parseInt(request.getParameter("auctionId"));
        BigDecimal bidAmount = new BigDecimal(request.getParameter("bidAmount"));

        try (Connection conn = DBConnector.getConnection()) {

            // Get current highest bid
            String checkSql = "SELECT MAX(Bid_Amount) AS MaxBid FROM Bids WHERE Auction_ID = ?";
            PreparedStatement checkStmt = conn.prepareStatement(checkSql);
            checkStmt.setInt(1, auctionId);
            ResultSet rs = checkStmt.executeQuery();

            BigDecimal maxBid = BigDecimal.ZERO;
            if (rs.next()) {
                maxBid = rs.getBigDecimal("MaxBid");
            }
            rs.close();
            checkStmt.close();

            // Get start price if no bids
            if (maxBid == null || maxBid.compareTo(BigDecimal.ZERO) == 0) {
                String startSql = "SELECT p.Start_Bid_Price FROM Auctions a JOIN Products p ON a.Product_ID = p.Product_ID WHERE a.Auction_ID = ?";
                PreparedStatement startStmt = conn.prepareStatement(startSql);
                startStmt.setInt(1, auctionId);
                rs = startStmt.executeQuery();
                if (rs.next()) {
                    maxBid = rs.getBigDecimal("Start_Bid_Price");
                }
                rs.close();
                startStmt.close();
            }

            if (bidAmount.compareTo(maxBid) <= 0) {
                request.setAttribute("error", "Bid must be higher than current bid.");
                request.getRequestDispatcher("product.jsp?id=" + auctionId).forward(request, response);
                return;
            }

            // Insert bid
            String insertSql = "INSERT INTO Bids (Auction_ID, User_ID, Bid_Amount) VALUES (?, ?, ?)";
            PreparedStatement insertStmt = conn.prepareStatement(insertSql);
            insertStmt.setInt(1, auctionId);
            insertStmt.setInt(2, user.getUserId());
            insertStmt.setBigDecimal(3, bidAmount);
            insertStmt.executeUpdate();
            insertStmt.close();

            response.sendRedirect("product.jsp?id=" + auctionId + "&success=true");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error placing bid.");
            request.getRequestDispatcher("product.jsp?id=" + auctionId).forward(request, response);
        }
    }
}
