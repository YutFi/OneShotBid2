package servlets;

import bean.User;
import util.DBConnector;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/SignupServlet")
public class SignupServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String fname = request.getParameter("user_fname");
        String lname = request.getParameter("user_lname");
        String username = request.getParameter("username");
        String email = request.getParameter("user_email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirm_password");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String street = request.getParameter("street");
        String city = request.getParameter("city");
        String state = request.getParameter("state");
        String postcode = request.getParameter("postcode");
        String country = request.getParameter("country");

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match!");
            request.getRequestDispatcher("signup.jsp").forward(request, response);
            return;
        }

        try (Connection conn = DBConnector.getConnection()) {
            String sql = "INSERT INTO Users (User_Frame, User_Lname, Username, User_Email, Password, User_Nphone, User_address, User_Street, User_City, User_State, User_Postcode) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement stmt = conn.prepareStatement(sql);

            stmt.setString(1, fname);
            stmt.setString(2, lname);
            stmt.setString(3, username);
            stmt.setString(4, email);
            stmt.setString(5, password); // For production, hash the password!
            stmt.setString(6, phone);
            stmt.setString(7, address);
            stmt.setString(8, street);
            stmt.setString(9, city);
            stmt.setString(10, state);
            stmt.setString(11, postcode);

            int rowsInserted = stmt.executeUpdate();
            if (rowsInserted > 0) {
                response.sendRedirect("login.jsp");
            } else {
                request.setAttribute("error", "Signup failed. Please try again.");
                request.getRequestDispatcher("signup.jsp").forward(request, response);
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("signup.jsp").forward(request, response);
        }
    }
}
