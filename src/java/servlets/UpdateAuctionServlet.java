package servlets;

import util.DBConnector;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/UpdateAuctionServlet")
public class UpdateAuctionServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int auctionId = Integer.parseInt(request.getParameter("auctionId"));
        int productId = Integer.parseInt(request.getParameter("productId"));
        String itemName = request.getParameter("itemName");
        String description = request.getParameter("description");
        int editionCount = Integer.parseInt(request.getParameter("editionCount"));
        double minBid = Double.parseDouble(request.getParameter("minBid"));
        Timestamp startTime = Timestamp.valueOf(request.getParameter("startTime").replace("T", " ") + ":00");
        Timestamp endTime = Timestamp.valueOf(request.getParameter("endTime").replace("T", " ") + ":00");

        try (Connection conn = DBConnector.getConnection()) {
            conn.setAutoCommit(false);

            // Update Products
            String updateProduct = "UPDATE Products SET Product_Name = ?, Product_Decs = ?, Edition_Count = ?, Start_Bid_Price = ? WHERE Product_ID = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateProduct)) {
                ps.setString(1, itemName);
                ps.setString(2, description);
                ps.setInt(3, editionCount);
                ps.setDouble(4, minBid);
                ps.setInt(5, productId);
                ps.executeUpdate();
            }

            // Update Auctions
            String updateAuction = "UPDATE Auctions SET Start_Time = ?, End_Time = ? WHERE Auction_ID = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateAuction)) {
                ps.setTimestamp(1, startTime);
                ps.setTimestamp(2, endTime);
                ps.setInt(3, auctionId);
                ps.executeUpdate();
            }

            conn.commit();
            response.sendRedirect("manage-auction.jsp?updated=true");

        } catch (Exception ex) {
            ex.printStackTrace();
            response.sendRedirect("manage-auction.jsp?error=Update+failed");
        }
    }
}
