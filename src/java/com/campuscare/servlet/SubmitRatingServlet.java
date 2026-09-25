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

@WebServlet("/SubmitRatingServlet")
public class SubmitRatingServlet extends HttpServlet {

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
        String ratingStr = request.getParameter("rating");
        String feedback = request.getParameter("feedback");
        String redirect = request.getParameter("redirect");

        if (issueIdStr == null || ratingStr == null || feedback == null) {
            session.setAttribute("errorMsg", "Invalid rating data.");
            if ("dashboard".equals(redirect)) response.sendRedirect(request.getContextPath() + "/user-dashboard.jsp");
            else response.sendRedirect(request.getContextPath() + "/my-complaints.jsp");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            // Update the issue with the user rating, ensuring the issue belongs to the logged-in user
            PreparedStatement pst = conn.prepareStatement(
                    "UPDATE issues SET user_rating = ?, user_feedback = ? WHERE id = ? AND user_id = ? AND status = 'Resolved'");
            pst.setInt(1, Integer.parseInt(ratingStr));
            pst.setString(2, feedback.trim());
            pst.setInt(3, Integer.parseInt(issueIdStr));
            pst.setInt(4, userId);
            
            int updated = pst.executeUpdate();
            
            if (updated > 0) {
                session.setAttribute("successMsg", "Thank you for your feedback!");
            } else {
                session.setAttribute("errorMsg", "Failed to submit rating. The issue might not be resolved yet.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "An error occurred while saving your feedback.");
        }

        if ("dashboard".equals(redirect)) {
            response.sendRedirect(request.getContextPath() + "/user-dashboard.jsp");
        } else {
            response.sendRedirect(request.getContextPath() + "/my-complaints.jsp");
        }
    }
}
