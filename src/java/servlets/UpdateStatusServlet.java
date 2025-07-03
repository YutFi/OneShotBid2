package servlets;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import util.DBConnector;

import java.io.IOException;
import java.sql.*;

@WebServlet("/UpdateStatusServlet")
public class UpdateStatusServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int auctionId = Integer.parseInt(request.getParameter("auctionId"));
        String newStatus = request.getParameter("status");

        try (Connection conn = DBConnector.getConnection()) {
            String sql = "UPDATE Auctions SET Status = ? WHERE Auction_ID = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, newStatus);
            ps.setInt(2, auctionId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Failed to update status.");
        }

        response.sendRedirect("manage-auction.jsp");
    }
}
