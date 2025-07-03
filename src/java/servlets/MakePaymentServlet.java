package servlets;

import util.DBConnector;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/MakePaymentServlet")
public class MakePaymentServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String paymentIdStr = request.getParameter("paymentId");
        String paymentMethod = request.getParameter("paymentMethod");

        if (paymentIdStr == null || paymentMethod == null || paymentMethod.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing payment ID or method.");
            return;
        }

        int paymentId;
        try {
            paymentId = Integer.parseInt(paymentIdStr);
            if (paymentId <= 0) throw new IllegalArgumentException("Invalid ID");
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid payment ID.");
            return;
        }

        try (Connection conn = DBConnector.getConnection()) {
            if (conn == null) {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "DB connection failed.");
                return;
            }

            // Step 1: Add payment method and complete payment
            String updatePayment = "UPDATE Payments SET Payment_status = 'completed', Payment_date = CURRENT_TIMESTAMP WHERE Payment_ID = ?";
            try (PreparedStatement ps = conn.prepareStatement(updatePayment)) {
                ps.setInt(1, paymentId);
                int updated = ps.executeUpdate();
                if (updated == 0) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Payment not found.");
                    return;
                }
            }

            // Step 2: Optionally, log/store method in a new column or payment method table
            String insertMethod = "INSERT INTO Payment_Methods (Payment_ID, Method_Type) VALUES (?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(insertMethod)) {
                ps.setInt(1, paymentId);
                ps.setString(2, paymentMethod.toLowerCase());
                ps.executeUpdate();
            }

            // Step 3: Set related auction to 'ended'
            String updateAuction = "UPDATE Auctions SET Status = 'ended' WHERE Auction_ID = (SELECT Auction_ID FROM Payments WHERE Payment_ID = ?)";
            try (PreparedStatement ps = conn.prepareStatement(updateAuction)) {
                ps.setInt(1, paymentId);
                ps.executeUpdate();
            }

            response.sendRedirect("dashboard.jsp");

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error during payment.");
        }
    }
}
