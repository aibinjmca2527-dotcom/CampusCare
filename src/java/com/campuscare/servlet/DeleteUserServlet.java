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

@WebServlet("/DeleteUserServlet")
public class DeleteUserServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        if (session.getAttribute("userId") == null || !"admin".equals(session.getAttribute("userRole"))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int adminId = (Integer) session.getAttribute("userId");
        String userIdStr = request.getParameter("userId");

        if (userIdStr == null || userIdStr.trim().isEmpty()) {
            session.setAttribute("errorMsg", "Invalid user ID.");
            response.sendRedirect(request.getContextPath() + "/admin-users.jsp");
            return;
        }

        try {
            int targetUserId = Integer.parseInt(userIdStr);

            if (targetUserId == adminId) {
                session.setAttribute("errorMsg", "You cannot delete your own admin account.");
                response.sendRedirect(request.getContextPath() + "/admin-users.jsp");
                return;
            }

            try (Connection conn = DBConnection.getConnection()) {
                PreparedStatement check = conn.prepareStatement("SELECT role FROM users WHERE id = ?");
                check.setInt(1, targetUserId);
                var rs = check.executeQuery();

                if (!rs.next()) {
                    session.setAttribute("errorMsg", "User not found.");
                    response.sendRedirect(request.getContextPath() + "/admin-users.jsp");
                    return;
                }

                if ("admin".equals(rs.getString("role"))) {
                    session.setAttribute("errorMsg", "Admin accounts cannot be deleted.");
                    response.sendRedirect(request.getContextPath() + "/admin-users.jsp");
                    return;
                }

                PreparedStatement delete = conn.prepareStatement("DELETE FROM users WHERE id = ? AND role = 'user'");
                delete.setInt(1, targetUserId);
                int rows = delete.executeUpdate();

                if (rows > 0) {
                    session.setAttribute("successMsg", "User deleted successfully.");
                } else {
                    session.setAttribute("errorMsg", "Failed to delete user.");
                }
            }
        } catch (NumberFormatException e) {
            session.setAttribute("errorMsg", "Invalid user ID.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "Server error: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin-users.jsp");
    }
}
