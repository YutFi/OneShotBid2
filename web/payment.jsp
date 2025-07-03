<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, util.DBConnector, bean.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int paymentId = Integer.parseInt(request.getParameter("paymentId"));
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
%>
<!DOCTYPE html>
<html>
<head>
    <title>Make a Payment - OneShotBid</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #eef5ff;
            padding: 30px;
        }
        h2 {
            color: #1a1a40;
            margin-bottom: 20px;
        }
        .payment-box {
            border: 1px solid #ccc;
            padding: 20px;
            background: #fff;
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.05);
        }
        label {
            font-weight: bold;
        }
        .info {
            margin-bottom: 15px;
        }
        .info p {
            margin: 5px 0;
        }
        select, button {
            padding: 8px;
            width: 100%;
            border-radius: 5px;
            border: 1px solid #bbb;
            margin-bottom: 20px;
        }
        button {
            background-color: #28a745;
            color: white;
            border: none;
            font-size: 16px;
            cursor: pointer;
        }
        button:hover {
            background-color: #218838;
        }
        a {
            text-decoration: none;
            color: #007bff;
            display: inline-block;
            margin-top: 10px;
        }
    </style>
</head>
<body>

<h2>Confirm Your Payment</h2>

<div class="payment-box">
<%
    try {
        conn = DBConnector.getConnection();
        String sql = "SELECT p.Payment_ID, p.Amount_Paid, a.Auction_ID, pr.Product_Name, u.User_Email, u.User_Nphone, u.User_address " +
                     "FROM Payments p " +
                     "JOIN Auctions a ON p.Auction_ID = a.Auction_ID " +
                     "JOIN Products pr ON a.Product_ID = pr.Product_ID " +
                     "JOIN Users u ON p.User_ID = u.User_ID " +
                     "WHERE p.Payment_ID = ?";
        ps = conn.prepareStatement(sql);
        ps.setInt(1, paymentId);
        rs = ps.executeQuery();

        if (rs.next()) {
%>
    <div class="info">
        <p><strong>Product:</strong> <%= rs.getString("Product_Name") %></p>
        <p><strong>Auction ID:</strong> <%= rs.getInt("Auction_ID") %></p>
        <p><strong>Amount Due:</strong> RM <%= rs.getDouble("Amount_Paid") %></p>
        <p><strong>Your Email:</strong> <%= rs.getString("User_Email") %></p>
        <p><strong>Phone:</strong> <%= rs.getString("User_Nphone") %></p>
        <p><strong>Shipping Address:</strong> <%= rs.getString("User_address") %></p>
    </div>

    <form action="MakePaymentServlet" method="post">
        <input type="hidden" name="paymentId" value="<%= paymentId %>">
        <label for="method">Choose Payment Method:</label>
        <select name="paymentMethod" required>
            <option value="">-- Select Method --</option>
            <option value="bank">Bank Transfer</option>
            <option value="credit">Credit Card</option>
            <option value="cash">Cash on Delivery</option>
        </select>
        <button type="submit">Pay Now</button>
    </form>
<%
        } else {
            out.println("<p style='color:red;'>Payment not found.</p>");
        }
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error loading payment data.</p>");
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
</div>

<a href="dashboard.jsp">&larr; Back to Dashboard</a>

</body>
</html>
