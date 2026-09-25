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

@WebServlet("/UpdateStatusServlet")
public class UpdateStatusServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        if (session.getAttribute("userId") == null || !"admin".equals(session.getAttribute("userRole"))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String issueIdStr = request.getParameter("issueId");
        String status = request.getParameter("status");
        String adminRemark = request.getParameter("adminRemark");
        String techIdStr = request.getParameter("assignedTechnicianId");
        String banUser = request.getParameter("banUser");

        if (issueIdStr == null || status == null) {
            session.setAttribute("errorMsg", "Invalid update request.");
            response.sendRedirect(request.getContextPath() + "/admin-dashboard.jsp");
            return;
        }

        // Whitelist allowed statuses
        if (!"Pending".equals(status) && !"In Progress".equals(status)
                && !"Resolved".equals(status) && !"Rejected".equals(status)) {
            session.setAttribute("errorMsg", "Invalid status value.");
            response.sendRedirect(request.getContextPath() + "/admin-dashboard.jsp");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            Integer techId = null;
            if (techIdStr != null && !techIdStr.trim().isEmpty()) {
                try { techId = Integer.parseInt(techIdStr.trim()); } catch (NumberFormatException ignored) {}
            }

            PreparedStatement pst;
            if (techId != null) {
                pst = conn.prepareStatement(
                        "UPDATE issues SET status = ?, admin_remark = ?, assigned_technician_id = ? WHERE id = ?");
                pst.setString(1, status);
                pst.setString(2, adminRemark != null ? adminRemark.trim() : null);
                pst.setInt(3, techId);
                pst.setInt(4, Integer.parseInt(issueIdStr));
            } else {
                pst = conn.prepareStatement(
                        "UPDATE issues SET status = ?, admin_remark = ?, assigned_technician_id = NULL WHERE id = ?");
                pst.setString(1, status);
                pst.setString(2, adminRemark != null ? adminRemark.trim() : null);
                pst.setInt(3, Integer.parseInt(issueIdStr));
            }
            pst.executeUpdate();

            if ("true".equals(banUser)) {
                try (PreparedStatement banPst = conn.prepareStatement(
                        "UPDATE users SET is_banned = 1 WHERE id = (SELECT user_id FROM issues WHERE id = ?)")) {
                    banPst.setInt(1, Integer.parseInt(issueIdStr));
                    banPst.executeUpdate();
                }
            }

            session.setAttribute("successMsg", "Issue updated successfully.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "Update failed: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin-dashboard.jsp");
    }
}
