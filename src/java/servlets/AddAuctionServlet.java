package servlets;

import jakarta.servlet.*;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.*;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.*;

import util.DBConnector;
import bean.User;

@WebServlet("/AddAuctionServlet")
@MultipartConfig
public class AddAuctionServlet extends HttpServlet {


    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Check user session
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        int sellerId = user.getUserId(); // ✅ Corrected to match Java convention

        // Read form data
        String itemName = request.getParameter("itemName");
        String description = request.getParameter("description");
        int editionCount = Integer.parseInt(request.getParameter("editionCount"));
        BigDecimal minBid = new BigDecimal(request.getParameter("minBid"));
        String startTimeStr = request.getParameter("startTime");
        String endTimeStr = request.getParameter("endTime");

        // Handle image
        Part imagePart = request.getPart("itemImage");
        String originalFileName = Paths.get(imagePart.getSubmittedFileName()).getFileName().toString();

        // Sanitize filename to avoid directory traversal attacks
        originalFileName = originalFileName.replaceAll("[^a-zA-Z0-9\\.\\-_]", "_");
        // Unique prefix so two uploads with the same file name never collide
        originalFileName = System.currentTimeMillis() + "_" + originalFileName;

        // Save image file
        File uploadDir = new File(util.DBConnector.imageDir());
        if (!uploadDir.exists()) uploadDir.mkdirs();

        File file = new File(uploadDir, originalFileName);
        try (InputStream input = imagePart.getInputStream()) {
            Files.copy(input, file.toPath());
        } catch (IOException ex) {
            ex.printStackTrace();
            request.setAttribute("error", "Image upload failed: " + ex.getMessage());
            request.getRequestDispatcher("manage-auction.jsp").forward(request, response);
            return;
        }

        // Insert into DB
        try (Connection conn = DBConnector.getConnection()) {

            // Insert into Products table
            String insertProduct = "INSERT INTO Products (Product_Name, Product_Decs, Edition_Count, Image_URL, Start_Bid_Price, Seller_ID) VALUES (?, ?, ?, ?, ?, ?)";
            PreparedStatement psProduct = conn.prepareStatement(insertProduct, Statement.RETURN_GENERATED_KEYS);
            psProduct.setString(1, itemName);
            psProduct.setString(2, description);
            psProduct.setInt(3, editionCount);
            psProduct.setString(4, originalFileName); // just filename
            psProduct.setBigDecimal(5, minBid);
            psProduct.setInt(6, sellerId);
            psProduct.executeUpdate();

            // Get generated product ID
            ResultSet rs = psProduct.getGeneratedKeys();
            int productId = -1;
            if (rs.next()) {
                productId = rs.getInt(1);
            }
            rs.close();
            psProduct.close();

            // Insert into Auctions table
            String insertAuction = "INSERT INTO Auctions (Start_Time, End_Time, Status, Product_ID) VALUES (?, ?, ?, ?)";
            PreparedStatement psAuction = conn.prepareStatement(insertAuction);

            // Convert to Timestamp
            Timestamp startTimestamp = Timestamp.valueOf(startTimeStr.replace("T", " ") + ":00");
            Timestamp endTimestamp = Timestamp.valueOf(endTimeStr.replace("T", " ") + ":00");

            psAuction.setTimestamp(1, startTimestamp);
            psAuction.setTimestamp(2, endTimestamp);
            psAuction.setString(3, "pending");
            psAuction.setInt(4, productId);
            psAuction.executeUpdate();
            psAuction.close();

            response.sendRedirect("manage-auction.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("manage-auction.jsp").forward(request, response);
        }
    }
}
