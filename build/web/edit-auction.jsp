<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.Timestamp" %>
<%
    int auctionId = (int) request.getAttribute("auctionId");
    int productId = (int) request.getAttribute("productId");
    String itemName = (String) request.getAttribute("itemName");
    String description = (String) request.getAttribute("description");
    int editionCount = (int) request.getAttribute("editionCount");
    java.math.BigDecimal minBid = (java.math.BigDecimal) request.getAttribute("minBid");
    Timestamp startTime = (Timestamp) request.getAttribute("startTime");
    Timestamp endTime = (Timestamp) request.getAttribute("endTime");

    String formattedStart = startTime.toLocalDateTime().toString();
    String formattedEnd = endTime.toLocalDateTime().toString();
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Edit Auction - OneShotBid</title>
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
    header h1 {
      margin: 0;
      font-size: 24px;
    }
    nav a {
      color: white;
      text-decoration: none;
      margin: 0 15px;
      font-weight: bold;
    }
    .container {
      max-width: 700px;
      margin: 40px auto;
      background: #f0f7ff;
      padding: 30px 40px;
      border-radius: 12px;
      box-shadow: 0 8px 20px rgba(0,0,0,0.1);
    }
    h2 {
      text-align: center;
      margin-bottom: 20px;
      font-size: 32px;
      color: #1a1a40;
    }
    label {
      font-weight: bold;
      display: block;
      margin-top: 12px;
      color: #2e3a68;
    }
    input, textarea, button {
      margin-top: 8px;
      margin-bottom: 16px;
      padding: 10px;
      width: 100%;
      box-sizing: border-box;
      border-radius: 8px;
      border: 1px solid #ccc;
      font-size: 14px;
    }
    textarea {
      resize: vertical;
    }
    button {
      background-color: #2a7de1;
      color: white;
      font-weight: bold;
      border: none;
      cursor: pointer;
    }
    button:hover {
      background-color: #1c5fb1;
    }
    .back-link {
      display: block;
      margin-top: 20px;
      text-align: center;
      font-size: 14px;
      text-decoration: none;
      color: #2a7de1;
      font-weight: bold;
    }
    .back-link:hover {
      text-decoration: underline;
    }

    .footer {
      text-align: center;
      padding: 12px;
      background-color: #d8def5;
      font-size: 13px;
      color: #333;
      margin-top: 60px;
    }
  </style>
</head>
<body>
  <header>
    <h1>OneShotBid</h1>

  </header>

  <div class="container">
    <h2>Edit Auction Listing</h2>
    <form action="UpdateAuctionServlet" method="post">
      <input type="hidden" name="auctionId" value="<%= auctionId %>">
      <input type="hidden" name="productId" value="<%= productId %>">

      <label>Item Name:</label>
      <input type="text" name="itemName" value="<%= itemName %>" required>

      <label>Item Description:</label>
      <textarea name="description" rows="4" required><%= description %></textarea>

      <label>Edition Count:</label>
      <input type="number" name="editionCount" value="<%= editionCount %>" required>

      <label>Minimum Starting Bid (RM):</label>
      <input type="number" name="minBid" step="0.01" value="<%= minBid %>" required>

      <label>Start Time:</label>
      <input type="datetime-local" name="startTime"
             value="<%= formattedStart.length() > 16 ? formattedStart.substring(0, 16) : formattedStart %>" required>

      <label>End Time:</label>
      <input type="datetime-local" name="endTime"
             value="<%= formattedEnd.length() > 16 ? formattedEnd.substring(0, 16) : formattedEnd %>" required>

      <button type="submit">Update Auction</button>
    </form>

    <a class="back-link" href="manage-auction.jsp">&larr; Back to Manage Auctions</a>
  </div>

  <div class="footer">
    &copy; 2025 OneShotBid. All Rights Reserved.
  </div>
</body>
</html>
