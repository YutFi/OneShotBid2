package servlets;

import bean.User;
import util.DBConnector;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnector.getConnection();

            // NOTE: In real projects, hash passwords instead of storing plain text
            String sql = "SELECT * FROM Users WHERE Username = ? AND Password = ?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            ps.setString(2, password);

            rs = ps.executeQuery();

            if (rs.next()) {
                // User found - create session
                User user = new User();
                user.setUserId(rs.getInt("User_ID")); // fixed method name
                user.setUserFname(rs.getString("User_Frame"));
                user.setUserLname(rs.getString("User_Lname"));
                user.setUsername(rs.getString("Username"));
                user.setEmail(rs.getString("User_Email"));
                user.setIsAdmin(rs.getBoolean("Is_Admin"));

                HttpSession session = request.getSession();
                session.setAttribute("user", user);
                session.setAttribute("username", user.getUsername());

                response.sendRedirect("homepage.jsp");

            } else {
                // Invalid login
                request.setAttribute("error", "Invalid username or password.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Server error. Please try again.");
            request.getRequestDispatcher("login.jsp").forward(request, response);

        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
    }
}
