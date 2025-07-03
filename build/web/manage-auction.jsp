<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, bean.User, util.DBConnector" %>
<%
    if (session == null || session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    User user = (User) session.getAttribute("user");
    int userId = user.getUserId();
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Manage Auctions - OneShotBid</title>
  <link href="https://fonts.googleapis.com/css2?family=Roboto&display=swap" rel="stylesheet" />
  <style>
    body {
      margin: 0;
      font-family: 'Roboto', sans-serif;
      background: linear-gradient(to bottom right, #dce7ff, #f0f4ff);
    }
    header {
      background-color: #1a1a40;
      color: white;
      padding: 20px 40px;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    header h1 { margin: 0; font-size: 24px; }
    nav a {
      color: white;
      text-decoration: none;
      margin: 0 15px;
      font-weight: bold;
    }
    .container {
      padding: 30px 40px;
    }
    h2 {
      text-align: center;
      margin-bottom: 20px;
      font-size: 32px;
      color: #1a1a40;
    }
    form {
      background: #f0f7ff;
      padding: 25px;
      border-radius: 12px;
      box-shadow: 0 6px 12px rgba(0, 0, 0, 0.05);
      margin-bottom: 40px;
    }
    label {
      font-weight: bold;
      display: block;
      margin-top: 10px;
      color: #2e3a68;
    }
    input, textarea, button {
      margin: 8px 0;
      padding: 10px;
      width: 100%;
      box-sizing: border-box;
      border-radius: 8px;
      border: 1px solid #ccc;
      font-size: 14px;
    }
    button {
      background-color: #ff6a00;
      color: white;
      font-weight: bold;
      border: none;
      cursor: pointer;
    }
    button:hover { background-color: #e05a00; }
    table {
      width: 100%;
      border-collapse: collapse;
      background: white;
      border-radius: 12px;
      overflow: hidden;
      box-shadow: 0 4px 12px rgba(0,0,0,0.05);
    }
    table, th, td { border: 1px solid #ccc; }
    th { background-color: #e6ecf9; color: #1a1a40; }
    th, td { padding: 12px; text-align: center; font-size: 14px; }
    img { max-width: 100px; border-radius: 6px; }

    .footer {
      text-align: center;
      padding: 12px;
      background-color: #d8def5;
      font-size: 13px;
      color: #333;
      margin-top: 40px;
    }

    .error {
      color: red;
      font-size: 14px;
      margin-bottom: 15px;
    }

    .action-buttons {
      text-align: center;
      padding: 0;
      background: none;
      box-shadow: none;
    }

    .button-stack {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 6px;
      padding: 0;
      margin: 0;
      background: none;
    }

    .button-stack form {
      margin: 0;
      padding: 0;
      background: none;
    }
    
    select {
    font-size: 13px;
    padding: 5px;
    border-radius: 6px;
    border: 1px solid #999;
    background-color: white;
    }


    .edit-btn, .delete-btn {
      width: 70px;
      padding: 4px 0;
      font-size: 13px;
      border: none;
      border-radius: 6px;
      cursor: pointer;
      font-weight: bold;
      color: white;
      background: none;
    }

    .edit-btn {
      background-color: #2a7de1;
    }
    .edit-btn:hover {
      background-color: #1c5fb1;
    }

    .delete-btn {
      background-color: #d11a2a;
    }
    .delete-btn:hover {
      background-color: #a50f1f;
    }

    .success {
      color: green;
      font-weight: bold;
      text-align: center;
      margin-bottom: 20px;
    }
  </style>
</head>
<body>
  <header>
    <h1>OneShotBid</h1>
    <nav>
      <a href="homepage.jsp">Home</a> |
      <a href="auctions.jsp">Auctions</a> |
      <a href="dashboard.jsp">My Account</a> |
      <a href="logout.jsp">Log Out</a>
    </nav>
  </header>

  <div class="container">
    <h2>Manage Your Auction Items</h2>

    <% if (request.getAttribute("error") != null) { %>
      <div class="error"><%= request.getAttribute("error") %></div>
    <% } %>

    <form action="AddAuctionServlet" method="post" enctype="multipart/form-data">
      <label for="itemName">Item Name:</label>
      <input type="text" name="itemName" id="itemName" required>

      <label for="description">Item Description:</label>
      <textarea name="description" id="description" required></textarea>

      <label for="editionCount">Edition Count:</label>
      <input type="number" name="editionCount" id="editionCount" min="1" required>

      <label for="itemImage">Item Image:</label>
      <input type="file" name="itemImage" id="itemImage" accept="image/*" required>

      <label for="startTime">Starting Bid Time:</label>
      <input type="datetime-local" name="startTime" id="startTime" required>

      <label for="endTime">Ending Bid Time:</label>
      <input type="datetime-local" name="endTime" id="endTime" required>

      <label for="minBid">Minimum Starting Bid (RM):</label>
      <input type="number" name="minBid" id="minBid" min="1" required>

      <button type="submit">Add Auction Item</button>
    </form>

    <h2>Your Auction Listings</h2>

    <% if ("true".equals(request.getParameter("updated"))) { %>
      <div class="success">Auction updated successfully!</div>
    <% } %>

    <table>
      <tr>
        <th>Item</th>
        <th>Description</th>
        <th>Edition</th>
        <th>Image</th>
        <th>Start Time</th>
        <th>End Time</th>
        <th>Status</th>
        <th>Min Bid (RM)</th>
        <th>Action</th>
      </tr>
      <%
        try {
            conn = DBConnector.getConnection();
            String sql = "SELECT p.Product_ID, p.Product_Name, p.Product_Decs, p.Edition_Count, p.Image_URL, p.Start_Bid_Price, a.Start_Time, a.End_Time, a.Status, a.Auction_ID " +
                         "FROM Products p JOIN Auctions a ON p.Product_ID = a.Product_ID " +
                         "WHERE p.Seller_ID = ? ORDER BY a.Start_Time DESC";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            while (rs.next()) {
      %>
        <tr>
          <td><%= rs.getString("Product_Name") %></td>
          <td><%= rs.getString("Product_Decs") %></td>
          <td><%= rs.getInt("Edition_Count") %></td>
          <td><img src="image/<%= rs.getString("Image_URL") %>" alt="Image"></td>
          <td><%= rs.getTimestamp("Start_Time") %></td>
          <td><%= rs.getTimestamp("End_Time") %></td>
          <td><%= rs.getString("Status") %></td>
          <td>RM <%= rs.getBigDecimal("Start_Bid_Price") %></td>
          <td class="action-buttons">
            <div class="button-stack">
                <form action="UpdateStatusServlet" method="post" style="margin-top: 5px;">
                    <input type="hidden" name="auctionId" value="<%= rs.getInt("Auction_ID") %>">
                    <select name="status" onchange="this.form.submit()" style="padding: 4px; border-radius: 6px;">
                    <option value="pending" <%= "pending".equals(rs.getString("Status")) ? "selected" : "" %>>Pending</option>
                    <option value="active" <%= "active".equals(rs.getString("Status")) ? "selected" : "" %>>Active</option>
                    <option value="ended" <%= "ended".equals(rs.getString("Status")) ? "selected" : "" %>>Ended</option>
                    </select>
            </form>
              <form action="EditAuctionServlet" method="get">
                <input type="hidden" name="auctionId" value="<%= rs.getInt("Auction_ID") %>">
                <button type="submit" class="edit-btn">Edit</button>
              </form>
              <form action="DeleteAuctionServlet" method="post" onsubmit="return confirm('Are you sure to delete this auction?');">
    <input type="hidden" name="auctionId" value="<%= rs.getInt("Auction_ID") %>">
    <button type="submit" class="delete-btn">Delete</button>
</form>
            </div>
          </td>
        </tr>
      <%
            }
        } catch (Exception ex) {
            out.println("<tr><td colspan='9'>Error loading auctions.</td></tr>");
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
      %>
    </table>
  </div>

  <div class="footer">
    &copy; 2025 OneShotBid. All Rights Reserved.
  </div>
</body>
</html>
