<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, util.DBConnector" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Browse Auctions</title>
  <link href="https://fonts.googleapis.com/css2?family=Roboto&display=swap" rel="stylesheet" />
  <style>
    body {
      font-family: 'Roboto', sans-serif;
      margin: 0;
      background: linear-gradient(to bottom right, #dce7ff, #f0f4ff);
      color: #333;
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
      margin-right: 15px;
      font-size: 14px;
    }

    nav a:hover {
      color: #ffffff;
    }

    main {
      max-width: 1200px;
      margin: 30px auto;
      padding: 20px;
    }

    .auction-list {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
      gap: 30px;
    }

    .auction-item {
      background-color: #f0f7ff;
      padding: 20px;
      border-radius: 12px;
      box-shadow: 0 6px 12px rgba(0, 0, 0, 0.05);
      transition: transform 0.3s ease;
    }

    .auction-item:hover {
      transform: translateY(-5px);
    }

    .auction-item img {
      width: 100%;
      height: 180px;
      object-fit: cover;
      border-radius: 8px;
      margin-bottom: 15px;
    }

    .auction-item h3 {
      margin: 0 0 10px;
      color: #1a1a40;
    }

    .auction-item p {
      margin: 5px 0;
      font-size: 14px;
    }

    .auction-item a {
      display: inline-block;
      margin-top: 10px;
      padding: 10px 16px;
      background-color: #ff6a00;
      color: white;
      text-decoration: none;
      border-radius: 8px;
      font-weight: bold;
      transition: background-color 0.3s ease;
    }

    .auction-item a:hover {
      background-color: #e05a00;
    }

    footer {
      text-align: center;
      padding: 12px;
      background-color: #d8def5;
      font-size: 13px;
      color: #333;
      margin-top: 40px;
    }
  </style>
</head>
<body>

  <header>
    <h1>Ongoing Auctions</h1>
    <nav>
      <a href="homepage.jsp">Home</a>
      <a href="dashboard.jsp">My Account</a>
    </nav>
  </header>

  <main>
    <section class="auction-list">
      <%
        try (Connection conn = DBConnector.getConnection()) {
          String sql = 
    "SELECT a.Auction_ID, a.Start_Time, a.End_Time, a.Status, " +
    "p.Product_ID, p.Product_Name, p.Image_URL " +
    "FROM Auctions a " +
    "JOIN Products p ON a.Product_ID = p.Product_ID " +
    "WHERE a.Status IN ('pending', 'active')";


          PreparedStatement ps = conn.prepareStatement(sql);
          ResultSet rs = ps.executeQuery();

          while (rs.next()) {
              int auctionId = rs.getInt("Auction_ID");
              String productName = rs.getString("Product_Name");
              String imageFileName = rs.getString("Image_URL");
              String status = rs.getString("Status");

              // Default fallback image if missing
              String imagePath = (imageFileName != null && !imageFileName.isEmpty()) 
                  ? "image/" + imageFileName 
                  : "assets/default.jpg"; // Make sure default exists
      %>
      <div class="auction-item">
        <img src="image/<%= rs.getString("Image_URL") %>" alt="Image" />
        <h3><%= productName %></h3>
        <p>Status: 
          <strong style="color: <%= status.equals("active") ? "green" : "orange" %>;">
            <%= status.equals("active") ? "Open" : "Pending" %>
          </strong>
        </p>
        <p>
          <a href="product.jsp?id=<%= auctionId %>">View Auction</a>
        </p>
      </div>
      <%
          }
        } catch (Exception e) {
          out.println("<p style='color:red;'>Error loading auctions: " + e.getMessage() + "</p>");
        }
      %>
    </section>
  </main>

  <footer>
    &copy; 2025 OneShotBid. All Rights Reserved.
  </footer>

</body>
</html>
