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

@WebServlet("/UpdateProfileServlet")
@MultipartConfig(maxFileSize = 5242880)
public class UpdateProfileServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // MUST set encoding before getParameter() on multipart forms
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        if (session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        boolean isAdmin = "admin".equals(session.getAttribute("userRole"));
        String redirectPage = isAdmin ? "/admin-profile.jsp" : "/profile.jsp";

        int userId = (Integer) session.getAttribute("userId");
        String fullName = request.getParameter("fullName");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (fullName == null || fullName.trim().isEmpty()) {
            session.setAttribute("profileError", "Full name is required.");
            response.sendRedirect(request.getContextPath() + redirectPage);
            return;
        }

        if (newPassword != null && !newPassword.isEmpty()) {
            if (!isPasswordStrong(newPassword)) {
                session.setAttribute("profileError",
                    "Password must be at least 6 characters and include at least one uppercase letter and one digit.");
                response.sendRedirect(request.getContextPath() + redirectPage);
                return;
            }
            if (!newPassword.equals(confirmPassword)) {
                session.setAttribute("profileError", "Passwords do not match.");
                response.sendRedirect(request.getContextPath() + redirectPage);
                return;
            }
        }

        String profileImage = (String) session.getAttribute("profileImage");
        Part photoPart = request.getPart("profilePhoto");
        if (photoPart != null && photoPart.getSize() > 0) {
            String submitted = photoPart.getSubmittedFileName();
            if (submitted != null && !submitted.trim().isEmpty()) {
                String ext = "";
                int dot = submitted.lastIndexOf('.');
                if (dot >= 0) {
                    ext = submitted.substring(dot).toLowerCase();
                }
                if (!".jpg".equals(ext) && !".jpeg".equals(ext) && !".png".equals(ext)) {
                    session.setAttribute("profileError", "Profile photo must be JPG or PNG.");
                    response.sendRedirect(request.getContextPath() + redirectPage);
                    return;
                }
                profileImage = "profile_" + UUID.randomUUID().toString().replace("-", "") + ext;
                File uploadDir = UploadUtil.getUploadDirectory(getServletContext());
                photoPart.write(new File(uploadDir, profileImage).getAbsolutePath());
            }
        }

        try (Connection conn = DBConnection.getConnection()) {
            String sql;
            if (newPassword != null && !newPassword.isEmpty()) {
                sql = "UPDATE users SET full_name = ?, password = ?, profile_image = ? WHERE id = ?";
            } else {
                sql = "UPDATE users SET full_name = ?, profile_image = ? WHERE id = ?";
            }

            PreparedStatement pst = conn.prepareStatement(sql);
            pst.setString(1, fullName.trim());
            if (newPassword != null && !newPassword.isEmpty()) {
                pst.setString(2, newPassword);
                pst.setString(3, profileImage);
                pst.setInt(4, userId);
            } else {
                pst.setString(2, profileImage);
                pst.setInt(3, userId);
            }
            pst.executeUpdate();

            session.setAttribute("userName", fullName.trim());
            session.setAttribute("profileImage", profileImage);
            session.setAttribute("profileSuccess", "Profile updated successfully.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("profileError", "Update failed: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + redirectPage);
    }

    /** Returns true if password has ≥6 chars, ≥1 uppercase letter, ≥1 digit. */
    private boolean isPasswordStrong(String password) {
        if (password == null || password.length() < 6) return false;
        boolean hasUpper = false, hasDigit = false;
        for (char c : password.toCharArray()) {
            if (Character.isUpperCase(c)) hasUpper = true;
            if (Character.isDigit(c))     hasDigit = true;
        }
        return hasUpper && hasDigit;
    }
}
