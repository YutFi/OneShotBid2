<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>OneShotBid - Sign Up</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: Arial, sans-serif;
            background-color: #1a1a40;
            display: flex;
            justify-content: center;
            align-items: center;
            height: auto;
            padding: 50px 0;
        }

        .signup-box {
            background-color: #2c2f4a;
            width: 500px;
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0 0 15px rgba(0, 0, 0, 0.5);
            color: #fff;
        }

        .signup-box .logo {
            text-align: center;
            font-size: 24px;
            margin-bottom: 10px;
        }

        .signup-box h2 {
            text-align: center;
            margin-bottom: 25px;
        }

        .signup-box input[type="text"],
        .signup-box input[type="email"],
        .signup-box input[type="password"],
        .signup-box input[type="date"],
        .signup-box input[type="tel"] {
            width: 100%;
            padding: 10px;
            margin: 8px 0;
            border: none;
            border-radius: 4px;
            font-size: 14px;
        }

        .signup-box button {
            width: 100%;
            padding: 10px;
            background-color: #003366;
            border: none;
            color: white;
            font-weight: bold;
            border-radius: 4px;
            cursor: pointer;
            font-size: 15px;
            margin-top: 15px;
        }

        .signup-box .extra {
            text-align: center;
            margin-top: 15px;
            font-size: 13px;
            color: #ccc;
        }

        .signup-box .extra a {
            color: #ccc;
            text-decoration: none;
        }

        .signup-box .extra a:hover {
            text-decoration: underline;
        }

        .name-row {
            display: flex;
            gap: 10px;
        }

        .name-row input {
            flex: 1;
            margin: 8px 0;
            padding: 10px;
            border: none;
            border-radius: 4px;
            font-size: 14px;
        }
    </style>
    <link rel="stylesheet" href="css/modern.css">
</head>
<body>

<div class="signup-box">
    <div class="logo">🔨 💰 📦</div>
    <h2>OneShotBid - Sign Up</h2>

    <form action="SignupServlet" method="post">
        <div class="name-row">
            <input type="text" name="user_fname" placeholder="First Name" required>
            <input type="text" name="user_lname" placeholder="Last Name" required>
        </div>
        <div class="name-row">
            <input type="text" name="username" placeholder="Username" required>
            <input type="email" name="user_email" placeholder="Email" required>
        </div>
        <div class="name-row">
            <input type="password" name="password" placeholder="Password" required>
            <input type="password" name="confirm_password" placeholder="Confirm Password" required>
        </div>
        <div class="name-row">
            <input type="date" name="birthday" placeholder="Birthday" required>
            <input type="tel" name="phone" placeholder="Phone Number" required>
        </div>
        <div class="name-row">
            <input type="text" name="address" placeholder="Address" required>
            <input type="text" name="street" placeholder="Street" required>
        </div>
        <div class="name-row">
            <input type="text" name="city" placeholder="City" required>
            <input type="text" name="state" placeholder="State" required>
        </div>
        <div class="name-row">
            <input type="text" name="postcode" placeholder="Postcode" required>
            <input type="text" name="country" placeholder="Country" required>
        </div>
        <button type="submit">Create Account</button>
    </form>

    <div class="extra">
        Already have an account?
        <a href="login.jsp">Log in</a>
    </div>
</div>

</body>
</html>
