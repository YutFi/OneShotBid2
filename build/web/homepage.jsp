<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="bean.User" %>
<%
    User user = (User) session.getAttribute("user");
    boolean isLoggedIn = (user != null);
    if (!isLoggedIn) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Limited Edition Auctions</title>
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
      position: relative;
    }

    .left-icons {
      position: absolute;
      left: 40px;
      display: flex;
      align-items: center;
    }

    .left-icons a {
      color: #ffd700;
      text-decoration: none;
      font-size: 20px;
      margin-right: 10px;
    }

    header h1 {
      margin: 0 auto;
      font-size: 24px;
    }

    nav a {
      color: white;
      text-decoration: none;
      margin: 0 15px;
      font-weight: bold;
    }

    .hero {
      background: linear-gradient(to bottom, rgba(255, 255, 255, 0.1), rgba(255, 255, 255, 0.2)),
                  url('https://images.unsplash.com/photo-1518972559570-1ecb7c133f20?auto=format&fit=crop&w=1400&q=80') no-repeat center center/cover;
      height: 320px;
      display: flex;
      align-items: center;
      justify-content: center;
      text-align: center;
      padding: 0 20px;
    }

    .hero-content {
      background: rgba(255, 255, 255, 0.7);
      padding: 20px 30px;
      border-radius: 12px;
      box-shadow: 0 6px 15px rgba(0, 0, 0, 0.1);
    }

    .hero-content h1 {
      font-size: 38px;
      color: #1a1a40;
      margin-bottom: 10px;
    }

    .hero-content p {
      font-size: 18px;
      color: #333;
      margin: 0;
    }

    .section-title {
      text-align: center;
      margin-top: 30px;
      font-size: 32px;
      color: #1a1a40;
    }

    .auction-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
      gap: 20px;
      padding: 30px 40px;
    }

    .auction-card {
      background: #f0f7ff;
      border: 2px solid #b8c4f7;
      border-radius: 12px;
      box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
      overflow: hidden;
      text-align: center;
      padding: 15px;
      transition: transform 0.2s ease, box-shadow 0.2s ease;
    }

    .auction-card:hover {
      transform: translateY(-6px);
      box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
    }

    .auction-card img {
      object-fit: cover;
      border-radius: 8px;
      display: block;
      margin: 0 auto 10px;
      width: 200px;
      height: 150px;
    }

    .auction-card h3 {
      margin: 10px 0;
      color: #2e3a68;
    }

    .auction-card p {
      margin: 0;
      color: #333;
      font-size: 14px;
    }

    .join-btn {
      display: inline-block;
      margin: 15px 0;
      background-color: #ff6a00;
      color: white;
      padding: 10px 20px;
      border: none;
      border-radius: 8px;
      cursor: pointer;
      font-weight: bold;
      text-decoration: none;
      transition: background-color 0.2s ease;
    }

    .join-btn:hover {
      background-color: #e05a00;
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
    <div class="left-icons">
        <a href="notifications.jsp" title="Notifications">&#128276;</a>
    </div>
    <h1>OneShotBid</h1>
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

<div class="hero">
  <div class="hero-content">
    <h1>Join the Auction</h1>
    <p>Discover Limited Edition Collectibles & Rare Finds</p>
  </div>
</div>

<h2 class="section-title">Live Auctions</h2>

<div class="auction-grid">
  <div class="auction-card">
    <img src="https://i.etsystatic.com/50421444/r/il/0211ae/5766794532/il_1588xN.5766794532_2t8x.jpg" alt="Auction 1" />
    <h3>Tree of Life Liberté Égalitè Fraternitè 1999</h3>
    <p>Highest Bidder: sam45</p>
    <p>Current Bid: $1350.00</p>
    <a class="join-btn" href="auctions.jsp?auctionId=1">JOIN AUCTION</a>
  </div>

  <div class="auction-card">
    <img src="https://i.etsystatic.com/28602508/r/il/544a10/6916795827/il_1588xN.6916795827_no5s.jpg" alt="Auction 2" />
    <h3>Vintage Mars Olympic 1992 Albertville</h3>
    <p>Highest Bidder: techlover</p>
    <p>Current Bid: $1800.00</p>
    <a class="join-btn" href="auctions.jsp?auctionId=2">JOIN AUCTION</a>
  </div>

  <div class="auction-card">
    <img src="https://i.etsystatic.com/58073376/r/il/7b7a88/6805140432/il_1588xN.6805140432_dss9.jpg" alt="Auction 3" />
    <h3>Vintage Marlboro Racing Leather Jacket</h3>
    <p>Highest Bidder: ali99</p>
    <p>Current Bid: $852.07</p>
    <a class="join-btn" href="auctions.jsp?auctionId=3">JOIN AUCTION</a>
  </div>

  <div class="auction-card">
    <img src="https://i.etsystatic.com/24255634/r/il/d6aa98/3462768651/il_1588xN.3462768651_togi.jpg" alt="Auction 4" />
    <h3>USSR Watch RAKETA</h3>
    <p>Highest Bidder: bidboss</p>
    <p>Current Bid: $389.00</p>
    <a class="join-btn" href="auctions.jsp?auctionId=4">JOIN AUCTION</a>
  </div>
</div>

<footer>
  &copy; 2025 OneShotBid. All Rights Reserved.
</footer>

</body>
</html>
