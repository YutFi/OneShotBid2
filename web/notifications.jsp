<%@ page import="java.sql.*, util.DBConnector, bean.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Your Notifications - OneShotBid</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f0f7ff;
            padding: 30px;
        }

        h2 {
            color: #1a1a40;
            margin-bottom: 20px;
        }

        .notification {
            background: #ffffff;
            border-left: 6px solid #1a1a40;
            margin-bottom: 15px;
            padding: 15px;
            border-radius: 6px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.05);
        }

        .unread {
            border-left-color: #ff6a00;
            background-color: #fff4e5;
        }

        .notification small {
            color: #555;
        }

        .no-notifications {
            font-style: italic;
            color: #555;
        }

        a {
            display: inline-block;
            margin-top: 20px;
            color: #007bff;
            text-decoration: none;
        }

        a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <h2>Your Notifications</h2>

<%
    try {
        conn = DBConnector.getConnection();
        String sql = "SELECT Message, Sent_At, Is_Read FROM Notifications WHERE User_ID = ? ORDER BY Sent_At DESC";
        ps = conn.prepareStatement(sql);
        ps.setInt(1, user.getUserId());
        rs = ps.executeQuery();

        boolean hasNotification = false;
        while (rs.next()) {
            hasNotification = true;
            boolean isRead = rs.getBoolean("Is_Read");
            String message = rs.getString("Message");
            Timestamp sentAt = rs.getTimestamp("Sent_At");

            // Detect and extract auction ID using regex
            java.util.regex.Pattern pattern = java.util.regex.Pattern.compile("#(\\d+)");
            java.util.regex.Matcher matcher = pattern.matcher(message);

            if (matcher.find()) {
                int auctionId = Integer.parseInt(matcher.group(1));
                String productName = null;

                // Get the product name from the auction ID
                String productSql = "SELECT p.Product_Name FROM Auctions a JOIN Products p ON a.Product_ID = p.Product_ID WHERE a.Auction_ID = ?";
                try (PreparedStatement psProduct = conn.prepareStatement(productSql)) {
                    psProduct.setInt(1, auctionId);
                    try (ResultSet rsProduct = psProduct.executeQuery()) {
                        if (rsProduct.next()) {
                            productName = rsProduct.getString("Product_Name");
                        }
                    }
                }

                // Replace #ID with (Product Name)
                if (productName != null) {
                    message = message.replace("#" + auctionId, "(" + productName + ")");
                }
            }
%>
    <div class="notification <%= isRead ? "" : "unread" %>">
        <strong><%= message %></strong><br/>
        <small><%= sentAt %></small>
    </div>
<%
        }

        if (!hasNotification) {
%>
    <p class="no-notifications">You have no notifications.</p>
<%
        }

    } catch (Exception e) {
        out.println("<p style='color:red;'>Error loading notifications.</p>");
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>

<a href="homepage.jsp">&larr; Back to Home</a>
</body>
</html>
