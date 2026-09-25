package com.campuscare.servlet;

import com.campuscare.db.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/AdminUserStatusServlet")
public class AdminUserStatusServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        if (session.getAttribute("userId") == null || !"admin".equals(session.getAttribute("userRole"))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String userIdStr = request.getParameter("userId");
        String action = request.getParameter("action"); // "ban" or "unban"

        if (userIdStr == null || action == null) {
            session.setAttribute("errorMsg", "Invalid request parameters.");
            response.sendRedirect(request.getContextPath() + "/admin-users.jsp");
            return;
        }

        int userId = Integer.parseInt(userIdStr);
        int isBanned = "ban".equals(action) ? 1 : 0;

        try (Connection conn = DBConnection.getConnection()) {
            // Prevent banning admins just to be safe
            PreparedStatement check = conn.prepareStatement("SELECT role FROM users WHERE id = ?");
            check.setInt(1, userId);
            var rs = check.executeQuery();
            if (rs.next() && "admin".equals(rs.getString("role"))) {
                session.setAttribute("errorMsg", "Cannot ban administrator accounts.");
                response.sendRedirect(request.getContextPath() + "/admin-users.jsp");
                return;
            }

            PreparedStatement pst = conn.prepareStatement("UPDATE users SET is_banned = ? WHERE id = ?");
            pst.setInt(1, isBanned);
            pst.setInt(2, userId);
            pst.executeUpdate();
            
            session.setAttribute("successMsg", "User status updated successfully.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "Failed to update user status: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin-users.jsp");
    }
}
