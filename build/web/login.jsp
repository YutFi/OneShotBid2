<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Login - OneShotBid</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap" rel="stylesheet">
    <style>
        body {
            margin: 0;
            font-family: 'Roboto', sans-serif;
            background-color: #1a1a40;
            color: #ffffff;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }

        .container {
            display: flex;
            width: 600px;
            background-color: #263445;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 8px 16px rgba(0,0,0,0.2);
        }

        .left-side {
            flex: 1;
            background-color: #1e2a38;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            padding: 30px;
        }

        .left-side h1 {
            font-size: 32px;
            color: #ffffff;
            margin: 0;
        }

        .icons {
            font-size: 24px;
            margin-bottom: 20px;
        }

        .icon {
            margin: 0 6px;
        }

        .right-side {
            flex: 1;
            background-color: #263445;
            padding: 40px 30px;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        .right-side input {
            margin-bottom: 20px;
            padding: 12px;
            font-size: 16px;
            border: 1px solid #ccc;
            border-radius: 4px;
            outline: none;
        }

        .right-side button {
            padding: 12px;
            background-color: #063970;
            color: #ffffff;
            border: none;
            border-radius: 4px;
            font-weight: bold;
            font-size: 16px;
            cursor: pointer;
        }

        .right-side button:hover {
            background-color: #052a5f;
        }

        .right-side .links {
            margin-top: 20px;
            font-size: 14px;
            text-align: center;
        }

        .right-side .links a {
            color: #aaa;
            text-decoration: none;
        }

        .right-side .links a:hover {
            color: #ffffff;
        }

        .error-message {
            color: #ff4c4c;
            font-size: 14px;
            margin-bottom: 15px;
            text-align: center;
        }
    </style>
</head>
<body>

<div class="container">
    <div class="left-side">
        <div class="icons">
            <span class="icon">🔨</span>
            <span class="icon">💰</span>
            <span class="icon">📦</span>
        </div>
        <h1>OneShotBid</h1>
    </div>
    <div class="right-side">

        <!-- Display error if login failed -->
        <% if (request.getAttribute("error") != null) { %>
            <p class="error-message"><%= request.getAttribute("error") %></p>
        <% } %>

        <form action="LoginServlet" method="post">
            <input type="text" name="username" placeholder="Username" required>
            <input type="password" name="password" placeholder="Password" required>
            <button type="submit">Log in</button>
        </form>

        <div class="links">
            <a href="#">Forgot your password?</a> -
            <a href="signup.jsp">Sign up?</a>
        </div>
    </div>
</div>

</body>
</html>