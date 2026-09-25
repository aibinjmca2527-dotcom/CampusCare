package com.campuscare.servlet;

import com.campuscare.db.DBConnection;
import com.campuscare.util.MailConfig;
import com.campuscare.util.SimpleSmtpMail;
import java.io.IOException;
import java.security.SecureRandom;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/ForgotPasswordServlet")
public class ForgotPasswordServlet extends HttpServlet {

    private static final String CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Please enter your registered email address.");
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
            return;
        }

        MailConfig mailConfig = MailConfig.load(getServletContext());
        if (!mailConfig.isEnabled()) {
            request.setAttribute("error", "Password reset email is not configured. Contact your administrator.");
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement find = conn.prepareStatement(
                    "SELECT id, full_name, role, is_banned FROM users WHERE email = ?");
            find.setString(1, email.trim());
            ResultSet rs = find.executeQuery();

            if (!rs.next()) {
                request.setAttribute("success",
                        "If that email is registered, a new password has been sent.");
                request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
                return;
            }

            if (rs.getInt("is_banned") == 1) {
                request.setAttribute("error", "Your account has been banned. You cannot reset your password.");
                request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
                return;
            }

            if ("admin".equals(rs.getString("role"))) {
                request.setAttribute("error", "Admin password reset is not available here. Contact system admin.");
                request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
                return;
            }

            String newPassword = generatePassword(10);
            PreparedStatement update = conn.prepareStatement("UPDATE users SET password = ? WHERE email = ?");
            update.setString(1, newPassword);
            update.setString(2, email.trim());
            update.executeUpdate();

            String name = rs.getString("full_name");
            String body = "Hello " + name + ",\n\n"
                    + "Your CampusCare password has been reset.\n\n"
                    + "New password: " + newPassword + "\n\n"
                    + "Please sign in and change your password from your profile page.\n\n"
                    + "— CampusCare";

            SimpleSmtpMail.send(mailConfig, email.trim(),
                    "CampusCare – Your new password", body);

            // ✅ Email sent — send user to login page with success message
            request.getSession().setAttribute("successMsg",
                "A new password has been sent to your email. Please sign in.");
            response.sendRedirect(request.getContextPath() + "/login.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Could not send reset email: " + e.getMessage());
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
        }
    }

    private String generatePassword(int length) {
        SecureRandom random = new SecureRandom();
        StringBuilder sb = new StringBuilder(length);
        for (int i = 0; i < length; i++) {
            sb.append(CHARS.charAt(random.nextInt(CHARS.length())));
        }
        return sb.toString();
    }
}
