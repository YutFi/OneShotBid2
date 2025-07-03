package servlets;

import bean.User;
import util.DBConnector;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/EditAuctionServlet")
public class EditAuctionServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int auctionId = Integer.parseInt(request.getParameter("auctionId"));
        
        try (Connection conn = DBConnector.getConnection()) {
            String sql = "SELECT p.Product_ID, p.Product_Name, p.Product_Decs, p.Edition_Count, p.Start_Bid_Price, " +
                         "a.Auction_ID, a.Start_Time, a.End_Time " +
                         "FROM Products p JOIN Auctions a ON p.Product_ID = a.Product_ID " +
                         "WHERE a.Auction_ID = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, auctionId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                request.setAttribute("auctionId", auctionId);
                request.setAttribute("productId", rs.getInt("Product_ID"));
                request.setAttribute("itemName", rs.getString("Product_Name"));
                request.setAttribute("description", rs.getString("Product_Decs"));
                request.setAttribute("editionCount", rs.getInt("Edition_Count"));
                request.setAttribute("minBid", rs.getBigDecimal("Start_Bid_Price"));
                request.setAttribute("startTime", rs.getTimestamp("Start_Time"));
                request.setAttribute("endTime", rs.getTimestamp("End_Time"));
                
                request.getRequestDispatcher("edit-auction.jsp").forward(request, response);
            } else {
                response.sendRedirect("manage-auction.jsp?error=Auction+not+found");
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            response.sendRedirect("manage-auction.jsp?error=Database+error");
        }
    }
}
