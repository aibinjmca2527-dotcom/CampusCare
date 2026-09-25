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

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String department = request.getParameter("department");
        String password = request.getParameter("password");

        if (fullName == null || fullName.trim().isEmpty()
                || email == null || email.trim().isEmpty()
                || department == null || department.trim().isEmpty()
                || password == null || password.isEmpty()) {
            request.setAttribute("error", "Please fill all required fields.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Validate Full Name: Letters and spaces only, min 2 chars
        if (!fullName.trim().matches("^[a-zA-Z\\s]{2,50}$")) {
            request.setAttribute("error", "Full Name must contain only letters and spaces (min 2 characters).");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Validate Phone (if provided): Numbers only, optional '+', typically 10-15 digits
        if (phone != null && !phone.trim().isEmpty() && !phone.trim().matches("^\\+?[0-9]{10,15}$")) {
            request.setAttribute("error", "Phone number must contain only numbers and optional leading '+' (10-15 digits).");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Password strength: min 6 chars, at least 1 uppercase, at least 1 digit
        if (!isPasswordStrong(password)) {
            request.setAttribute("error",
                "Password must be at least 6 characters and include at least one uppercase letter and one digit.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement check = conn.prepareStatement("SELECT id FROM users WHERE email = ?");
            check.setString(1, email.trim());
            if (check.executeQuery().next()) {
                request.setAttribute("error", "An account with this email already exists.");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }

            PreparedStatement insert = conn.prepareStatement(
                    "INSERT INTO users (full_name, email, password, phone, role, department) VALUES (?, ?, ?, ?, 'user', ?)");
            insert.setString(1, fullName.trim());
            insert.setString(2, email.trim());
            insert.setString(3, password);
            insert.setString(4, phone != null ? phone.trim() : null);
            insert.setString(5, department.trim());
            insert.executeUpdate();

            request.getSession().setAttribute("successMsg", "Account created. Please sign in.");
            request.getSession().setAttribute("justRegistered", true);
            response.sendRedirect(request.getContextPath() + "/login.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Registration failed: " + e.getMessage());
            request.getRequestDispatcher("register.jsp").forward(request, response);
        }
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

