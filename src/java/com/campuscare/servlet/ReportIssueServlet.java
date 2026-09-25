package com.campuscare.servlet;

import com.campuscare.db.DBConnection;
import com.campuscare.util.UploadUtil;
import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.UUID;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

@WebServlet("/ReportIssueServlet")
@MultipartConfig(maxFileSize = 10485760)
public class ReportIssueServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        if (session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        String title = request.getParameter("title");
        String category = request.getParameter("category");
        String description = request.getParameter("description");
        String location = request.getParameter("location");

        // Description is now OPTIONAL – only title, category, location are required
        if (title == null || title.trim().isEmpty()
                || category == null || category.trim().isEmpty()
                || location == null || location.trim().isEmpty()) {
            request.setAttribute("error", "Title, category and location are required.");
            request.getRequestDispatcher("report-issue.jsp").forward(request, response);
            return;
        }

        String imagePath = null;
        Part filePart = request.getPart("image");
        if (filePart != null && filePart.getSize() > 0) {
            String submitted = filePart.getSubmittedFileName();
            if (submitted != null && !submitted.trim().isEmpty()) {
                String ext = "";
                int dot = submitted.lastIndexOf('.');
                if (dot >= 0) {
                    ext = submitted.substring(dot).toLowerCase();
                }
                if (!".jpg".equals(ext) && !".jpeg".equals(ext) && !".png".equals(ext)) {
                    request.setAttribute("error", "Only JPG and PNG images are allowed.");
                    request.getRequestDispatcher("report-issue.jsp").forward(request, response);
                    return;
                }
                imagePath = "issue_" + UUID.randomUUID().toString().replace("-", "") + ext;
                File uploadDir = UploadUtil.getUploadDirectory(getServletContext());
                filePart.write(new File(uploadDir, imagePath).getAbsolutePath());
            }
        }

        // Treat empty/null description as null for storage
        String descValue = (description != null && !description.trim().isEmpty()) ? description.trim() : null;

        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement pst = conn.prepareStatement(
                    "INSERT INTO issues (user_id, title, category, description, location, image_path) VALUES (?, ?, ?, ?, ?, ?)");
            pst.setInt(1, userId);
            pst.setString(2, title.trim());
            pst.setString(3, category.trim());
            pst.setString(4, descValue);
            pst.setString(5, location.trim());
            pst.setString(6, imagePath);
            pst.executeUpdate();
            session.setAttribute("successMsg", "Your request was submitted successfully.");
            response.sendRedirect(request.getContextPath() + "/my-complaints.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Failed to submit request: " + e.getMessage());
            request.getRequestDispatcher("report-issue.jsp").forward(request, response);
        }
    }
}
