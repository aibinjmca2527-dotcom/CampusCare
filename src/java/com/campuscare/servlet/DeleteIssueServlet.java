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

@WebServlet("/DeleteIssueServlet")
public class DeleteIssueServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        if (session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        String issueIdStr = request.getParameter("issueId");

        if (issueIdStr != null && !issueIdStr.isEmpty()) {
            try (Connection conn = DBConnection.getConnection()) {
                // Ensure the issue belongs to the logged-in user
                PreparedStatement pst = conn.prepareStatement("DELETE FROM issues WHERE id = ? AND user_id = ?");
                pst.setInt(1, Integer.parseInt(issueIdStr));
                pst.setInt(2, userId);
                
                int deleted = pst.executeUpdate();
                if (deleted > 0) {
                    session.setAttribute("successMsg", "Request deleted successfully.");
                } else {
                    session.setAttribute("errorMsg", "Failed to delete request. It may not exist or you do not have permission.");
                }
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("errorMsg", "An error occurred while deleting the request.");
            }
        }

        response.sendRedirect(request.getContextPath() + "/my-complaints.jsp");
    }
}
