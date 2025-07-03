<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, java.math.BigDecimal, bean.User, util.DBConnector" %>
<%
    int auctionId = 0;
    try {
        auctionId = Integer.parseInt(request.getParameter("id"));
    } catch (Exception e) {
        response.sendRedirect("auctions.jsp");
        return;
    }

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    String productName = "", description = "", imageUrl = "", status = "";
    int edition = 0;
    BigDecimal startBid = BigDecimal.ZERO;
    Timestamp startTime = null, endTime = null;
    int productId = 0;

    List<Map<String, Object>> bids = new ArrayList<>();
    BigDecimal currentHighest = BigDecimal.ZERO;

    User user = (User) session.getAttribute("user");
    boolean isLoggedIn = (user != null);
    boolean showPaymentButton = false;
    int winningUserId = -1;

    try {
        conn = DBConnector.getConnection();

        // Fetch auction + product details
        String sql = "SELECT a.*, p.* FROM Auctions a JOIN Products p ON a.Product_ID = p.Product_ID WHERE a.Auction_ID = ?";
        ps = conn.prepareStatement(sql);
        ps.setInt(1, auctionId);
        rs = ps.executeQuery();
        if (rs.next()) {
            productName = rs.getString("Product_Name");
            description = rs.getString("Product_Decs");
            imageUrl = rs.getString("Image_URL");
            edition = rs.getInt("Edition_Count");
            startBid = rs.getBigDecimal("Start_Bid_Price");
            startTime = rs.getTimestamp("Start_Time");
            endTime = rs.getTimestamp("End_Time");
            status = rs.getString("Status");
            productId = rs.getInt("Product_ID");
        } else {
            response.sendRedirect("auctions.jsp");
            return;
        }
        rs.close();
        ps.close();

        // Get bid history
        sql = "SELECT b.Bid_Amount, b.Bid_Time, u.Username FROM Bids b JOIN Users u ON b.User_ID = u.User_ID WHERE b.Auction_ID = ? ORDER BY b.Bid_Time DESC";
        ps = conn.prepareStatement(sql);
        ps.setInt(1, auctionId);
        rs = ps.executeQuery();
        while (rs.next()) {
            Map<String, Object> bid = new HashMap<>();
            bid.put("amount", rs.getBigDecimal("Bid_Amount"));
            bid.put("time", rs.getTimestamp("Bid_Time"));
            bid.put("user", rs.getString("Username"));
            bids.add(bid);
        }

        if (!bids.isEmpty()) {
            currentHighest = (BigDecimal) bids.get(0).get("amount");
        } else {
            currentHighest = startBid;
        }

        rs.close();
        ps.close();

        // Determine winner if auction ended
        if ("ended".equalsIgnoreCase(status)) {
            sql = "SELECT User_ID FROM Bids WHERE Auction_ID = ? ORDER BY Bid_Amount DESC FETCH FIRST ROW ONLY";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, auctionId);
            rs = ps.executeQuery();
            if (rs.next()) {
                winningUserId = rs.getInt("User_ID");
                showPaymentButton = (isLoggedIn && user.getUserId() == winningUserId);
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<p style='color:red;'>Error loading product details.</p>");
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (ps != null) ps.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title><%= productName %> - OneShotBid</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Roboto', sans-serif;
            background: linear-gradient(to bottom right, #dce7ff, #f0f4ff);
            margin: 0;
        }

        header, footer {
            background-color: #1a1a40;
            color: white;
            padding: 20px 40px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        nav a {
            color: #ffd700;
            margin-right: 15px;
            text-decoration: none;
        }

        main {
            max-width: 900px;
            margin: 30px auto;
            padding: 20px;
            background: #f0f7ff;
            border-radius: 12px;
            box-shadow: 0 6px 12px rgba(0, 0, 0, 0.05);
        }

        h2 {
            color: #1a1a40;
        }

        .product-detail {
            display: flex;
            gap: 30px;
            align-items: flex-start;
        }

        .product-detail img {
            max-width: 250px;
            height: auto;
            border-radius: 12px;
            object-fit: cover;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }

        .product-info p {
            margin: 8px 0;
            font-size: 15px;
        }

        .bidding-section {
            margin-top: 30px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
            background: #fff;
        }

        th, td {
            padding: 10px;
            text-align: left;
            border-bottom: 1px solid #ccc;
            font-size: 14px;
        }

        .error {
            color: red;
        }

        input, button {
            padding: 10px;
            margin: 10px 0;
            font-size: 15px;
            border-radius: 8px;
            border: 1px solid #ccc;
        }

        button {
            background-color: #ff6a00;
            color: white;
            font-weight: bold;
            border: none;
            cursor: pointer;
        }

        button:hover {
            background-color: #e05a00;
        }
    </style>
</head>
<body>
<header>
    <div style="display: flex; align-items: center; gap: 20px;">
        <a href="notifications.jsp" title="Notifications" style="text-decoration: none; font-size: 20px;">🔔</a>
        <h1>Product Details</h1>
    </div>
    <nav>
        <a href="homepage.jsp">Home</a>
        <a href="auctions.jsp">Auctions</a>
        <% if (isLoggedIn) { %>
            <a href="dashboard.jsp">My Account</a>
            <a href="logout.jsp">Logout</a>
        <% } else { %>
            <a href="login.jsp">Login</a>
        <% } %>
    </nav>
</header>

<main>
    <div class="product-detail">
        <img src="image/<%= imageUrl %>" alt="Product Image">
        <div class="product-info">
            <h2><%= productName %></h2>
            <p><strong>Description:</strong> <%= description %></p>
            <p><strong>Edition:</strong> <%= edition %></p>
            <p><strong>Start Bid:</strong> RM <%= startBid %></p>
            <p><strong>Status:</strong> <%= status %></p>
            <p><strong>Start Time:</strong> <%= startTime %></p>
            <p><strong>End Time:</strong> <%= endTime %></p>
            <p><strong>Current Highest Bid:</strong> RM <%= currentHighest %></p>
        </div>
    </div>

    <div class="bidding-section">
        <h2>Bidding History</h2>
        <table>
            <tr><th>User</th><th>Amount (RM)</th><th>Time</th></tr>
            <% for (Map<String, Object> bid : bids) { %>
                <tr>
                    <td><%= bid.get("user") %></td>
                    <td><%= bid.get("amount") %></td>
                    <td><%= bid.get("time") %></td>
                </tr>
            <% } %>
        </table>
    </div>

    <% if (isLoggedIn && "active".equalsIgnoreCase(status)) { %>
        <div class="bidding-section">
            <h2>Place a Bid</h2>
            <form action="PlaceBidServlet" method="post">
                <input type="hidden" name="auctionId" value="<%= auctionId %>">
                <input type="number" name="bidAmount" step="0.01" min="0" placeholder="Enter your bid (RM)" required>
                <button type="submit">Submit Bid</button>
            </form>
            <% if (request.getAttribute("error") != null) { %>
                <p class="error"><%= request.getAttribute("error") %></p>
            <% } else if (request.getParameter("success") != null) { %>
                <p style="color:green;">Bid placed successfully!</p>
            <% } %>
        </div>
    <% } else if (!isLoggedIn) { %>
        <p style="color:red;">You must <a href="login.jsp">log in</a> to place a bid.</p>
    <% } else if ("ended".equalsIgnoreCase(status)) { %>
        <p style="color:gray;">This auction has ended.</p>
    <% } %>

    <% if (showPaymentButton) { %>
        <div class="bidding-section">
            <h2>Complete Your Payment</h2>
            <form action="MakePaymentServlet" method="post">
                <input type="hidden" name="auctionId" value="<%= auctionId %>">
                <input type="hidden" name="amount" value="<%= currentHighest %>">
                <button type="submit">Make a Payment</button>
            </form>
        </div>
    <% } %>
</main>

<footer>
    &copy; 2025 OneShotBid. All Rights Reserved.
</footer>
</body>
</html>
