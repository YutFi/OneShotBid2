<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, bean.User, util.DBConnector" %>
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
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>User Dashboard - OneShotBid</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Roboto', sans-serif;
            background: linear-gradient(to bottom right, #dce7ff, #f0f4ff);
            margin: 0;
            padding: 0;
        }
        header {
            background-color: #1a1a40;
            color: white;
            padding: 20px 40px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        header h1 {
            margin: 0;
            font-size: 24px;
        }
        nav a {
            color: #ffd700;
            text-decoration: none;
            margin-left: 15px;
            font-size: 14px;
            font-weight: bold;
        }
        nav a:hover {
            color: #ffffff;
        }
        main {
            padding: 20px 40px;
            max-width: 1000px;
            margin: auto;
        }
        .account-details {
            display: flex;
            align-items: center;
            background-color: #f0f7ff;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.05);
            margin-bottom: 25px;
        }
        .account-details img {
            width: 70px;
            height: 70px;
            border-radius: 50%;
            margin-right: 20px;
            border: 2px solid #063970;
        }
        .account-info h2 {
            margin: 0;
            color: #1a1a40;
            font-size: 20px;
        }
        .account-info p {
            margin: 4px 0;
            font-size: 13px;
            color: #555;
        }
        .membership-badge {
            background-color: #ffd700;
            color: #000;
            padding: 3px 10px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: bold;
        }
        .dashboard-section {
            background-color: #f0f7ff;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.05);
            margin-bottom: 20px;
        }
        .dashboard-section h2 {
            color: #1a1a40;
            margin-bottom: 12px;
            font-size: 18px;
            border-bottom: 1px solid #dde3f4;
            padding-bottom: 6px;
        }
        ul {
            list-style-type: none;
            padding: 0;
        }
        li {
            padding: 8px 0;
            font-size: 14px;
            border-bottom: 1px solid #e0e0e0;
        }
        li:last-child {
            border-bottom: none;
        }
        button {
            padding: 6px 12px;
            background-color: #28a745;
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 13px;
            cursor: pointer;
        }
        button:hover {
            background-color: #218838;
        }
        footer {
            text-align: center;
            padding: 12px;
            background-color: #d8def5;
            font-size: 13px;
            color: #333;
        }
    </style>
</head>
<body>

<header>
    <h1>My Account</h1>
    <nav>
        <a href="homepage.jsp">Home</a>
        <a href="manage-auction.jsp">Manage Auctions</a>
        <a href="logout.jsp">Log Out</a>
    </nav>
</header>

<main>
    <!-- Profile Section -->
    <section class="account-details">
        <img src="https://i.pinimg.com/736x/69/78/19/69781905dd57ba144ab71ca4271ab294.jpg" alt="Profile">
        <div class="account-info">
            <h2><%= user.getUserFname() %> <%= user.getUserLname() %></h2>
            <p>📧 <%= user.getEmail() %></p>
            <p>📍 Malaysia</p>
            <span class="membership-badge">
                <%= user.getIsAdmin() ? "🛠 Admin" : "💎 Premium Member" %>
            </span>
        </div>
    </section>

    <!-- Active Bids -->
    <section class="dashboard-section">
        <h2>My Active Bids</h2>
        <ul>
        <%
            try {
                conn = DBConnector.getConnection();
                String sql = "SELECT DISTINCT p.Product_Name, a.Auction_ID, " +
                             "(SELECT MAX(Bid_Amount) FROM Bids WHERE Auction_ID = a.Auction_ID) AS HighestBid, " +
                             "(SELECT MAX(Bid_Amount) FROM Bids WHERE Auction_ID = a.Auction_ID AND User_ID = ?) AS YourBid " +
                             "FROM Auctions a JOIN Products p ON a.Product_ID = p.Product_ID " +
                             "WHERE a.Status = 'active' AND EXISTS (SELECT 1 FROM Bids WHERE Auction_ID = a.Auction_ID AND User_ID = ?)";
                ps = conn.prepareStatement(sql);
                ps.setInt(1, user.getUserId());
                ps.setInt(2, user.getUserId());
                rs = ps.executeQuery();
                while (rs.next()) {
        %>
            <li>🎯 <%= rs.getString("Product_Name") %> – Current: RM<%= rs.getDouble("HighestBid") %> – Your: RM<%= rs.getDouble("YourBid") %></li>
        <%
                }
                rs.close(); ps.close();
            } catch (Exception e) {
                out.println("<li>Error loading active bids.</li>");
            }
        %>
        </ul>
    </section>

    <!-- Auction History -->
    <section class="dashboard-section">
        <h2>My Auction History</h2>
        <ul>
        <%
            try {
                String historySql = "SELECT p.Product_Name, a.Auction_ID, " +
                                    "(SELECT MAX(Bid_Amount) FROM Bids WHERE Auction_ID = a.Auction_ID) AS FinalBid, " +
                                    "(SELECT MAX(Bid_Amount) FROM Bids WHERE Auction_ID = a.Auction_ID AND User_ID = ?) AS YourBid " +
                                    "FROM Auctions a JOIN Products p ON a.Product_ID = p.Product_ID " +
                                    "WHERE a.Status = 'ended' AND EXISTS (SELECT 1 FROM Bids WHERE Auction_ID = a.Auction_ID AND User_ID = ?)";
                ps = conn.prepareStatement(historySql);
                ps.setInt(1, user.getUserId());
                ps.setInt(2, user.getUserId());
                rs = ps.executeQuery();
                while (rs.next()) {
                    double your = rs.getDouble("YourBid");
                    double finalBid = rs.getDouble("FinalBid");
                    String result = (your == finalBid) ? "✅ Won" : "❌ Lost";
        %>
            <li>📦 <%= rs.getString("Product_Name") %> – Final: RM<%= finalBid %> – <%= result %></li>
        <%
                }
                rs.close(); ps.close();
            } catch (Exception e) {
                out.println("<li>Error loading history.</li>");
            }
        %>
        </ul>
    </section>

    <!-- Items I've Won (Unpaid) -->
    <section class="dashboard-section">
        <h2>Items I've Won (Unpaid)</h2>
        <ul>
        <%
            try {
                String winSql = "SELECT pay.Payment_ID, p.Product_Name, pay.Amount_Paid " +
                                "FROM Payments pay JOIN Auctions a ON pay.Auction_ID = a.Auction_ID " +
                                "JOIN Products p ON a.Product_ID = p.Product_ID " +
                                "WHERE pay.User_ID = ? AND pay.Payment_status = 'pending'";
                ps = conn.prepareStatement(winSql);
                ps.setInt(1, user.getUserId());
                rs = ps.executeQuery();
                while (rs.next()) {
        %>
            <li>🏆 <%= rs.getString("Product_Name") %> – Amount: RM<%= rs.getDouble("Amount_Paid") %>
                <form action="payment.jsp" method="get" style="display:inline;">
                     <input type="hidden" name="paymentId" value="<%= rs.getInt("Payment_ID") %>">
                     <input type="hidden" name="amount" value="<%= rs.getDouble("Amount_Paid") %>">
                     <input type="hidden" name="productName" value="<%= rs.getString("Product_Name") %>">
                     <button type="submit">Make Payment</button>
                </form>
            </li>
        <%
                }
            } catch (Exception e) {
                out.println("<li>Error loading won items.</li>");
            } finally {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            }
        %>
        </ul>
    </section>
</main>

<footer>
    &copy; 2025 OneShotBid. All Rights Reserved.
</footer>
</body>
</html>
