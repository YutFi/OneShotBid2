package servlets;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

import util.DBConnector;

@WebServlet("/DeleteAuctionServlet")
public class DeleteAuctionServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String auctionIdStr = request.getParameter("auctionId");

        if (auctionIdStr == null || auctionIdStr.isEmpty()) {
            request.setAttribute("error", "Auction ID is missing.");
            request.getRequestDispatcher("manage-auction.jsp").forward(request, response);
            return;
        }

        int auctionId;
        try {
            auctionId = Integer.parseInt(auctionIdStr);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid Auction ID.");
            request.getRequestDispatcher("manage-auction.jsp").forward(request, response);
            return;
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnector.getConnection();
            conn.setAutoCommit(false); // start transaction

            // Get Product_ID associated with the auction
            String getProductSql = "SELECT Product_ID FROM Auctions WHERE Auction_ID = ?";
            ps = conn.prepareStatement(getProductSql);
            ps.setInt(1, auctionId);
            rs = ps.executeQuery();

            int productId = -1;
            if (rs.next()) {
                productId = rs.getInt("Product_ID");
            } else {
                request.setAttribute("error", "Auction not found.");
                request.getRequestDispatcher("manage-auction.jsp").forward(request, response);
                return;
            }

            rs.close();
            ps.close();

            // Delete the auction
            String deleteAuctionSQL = "DELETE FROM Auctions WHERE Auction_ID = ?";
            ps = conn.prepareStatement(deleteAuctionSQL);
            ps.setInt(1, auctionId);
            ps.executeUpdate();
            ps.close();

            // Check if product is used in any other auctions
            String countProductSql = "SELECT COUNT(*) FROM Auctions WHERE Product_ID = ?";
            ps = conn.prepareStatement(countProductSql);
            ps.setInt(1, productId);
            rs = ps.executeQuery();

            boolean isProductUsed = false;
            if (rs.next()) {
                isProductUsed = rs.getInt(1) > 0;
            }

            rs.close();
            ps.close();

            // If not used, delete the product too
            if (!isProductUsed) {
                String deleteProductSQL = "DELETE FROM Products WHERE Product_ID = ?";
                ps = conn.prepareStatement(deleteProductSQL);
                ps.setInt(1, productId);
                ps.executeUpdate();
            }

            conn.commit(); // commit transaction
            response.sendRedirect("manage-auction.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            request.setAttribute("error", "Failed to delete auction.");
            request.getRequestDispatcher("manage-auction.jsp").forward(request, response);
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
    }
}
