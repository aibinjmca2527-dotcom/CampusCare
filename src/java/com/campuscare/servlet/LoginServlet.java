package com.campuscare.servlet;

import com.campuscare.db.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (email == null || email.trim().isEmpty() || password == null || password.isEmpty()) {
            request.setAttribute("error", "Email and password are required.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement pst = conn.prepareStatement(
                    "SELECT id, full_name, email, password, role, profile_image, is_banned FROM users WHERE email = ?");
            pst.setString(1, email.trim());
            ResultSet rs = pst.executeQuery();

            if (rs.next() && password.equals(rs.getString("password"))) {
                if (rs.getInt("is_banned") == 1) {
                    request.setAttribute("error", "Your account has been banned. Please contact the administrator.");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                    return;
                }

                HttpSession session = request.getSession(true);
                session.setAttribute("userId", rs.getInt("id"));
                session.setAttribute("userName", rs.getString("full_name"));
                session.setAttribute("userEmail", rs.getString("email"));
                session.setAttribute("userRole", rs.getString("role"));
                session.setAttribute("profileImage", rs.getString("profile_image"));

                if ("admin".equals(rs.getString("role"))) {
                    response.sendRedirect(request.getContextPath() + "/admin-dashboard.jsp");
                } else {
                    response.sendRedirect(request.getContextPath() + "/user-dashboard.jsp");
                }
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error. Please try again.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        request.setAttribute("error", "Invalid email or password.");
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }
}
