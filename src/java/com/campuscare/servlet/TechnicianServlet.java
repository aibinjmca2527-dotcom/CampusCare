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

@WebServlet("/TechnicianServlet")
public class TechnicianServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        if (session.getAttribute("userId") == null || !"admin".equals(session.getAttribute("userRole"))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "";

        switch (action) {
            case "add":
                addTechnician(request, response, session);
                break;
            case "edit":
                editTechnician(request, response, session);
                break;
            case "delete":
                deleteTechnician(request, response, session);
                break;
            default:
                session.setAttribute("errorMsg", "Invalid action.");
                response.sendRedirect(request.getContextPath() + "/admin-technicians.jsp");
        }
    }

    private void addTechnician(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws IOException {
        String name = request.getParameter("name");
        String category = request.getParameter("category");
        String phone = request.getParameter("phone_number");
        String activeStr = request.getParameter("active");

        if (name == null || name.trim().isEmpty()
                || category == null || category.trim().isEmpty()
                || phone == null || phone.trim().isEmpty()) {
            session.setAttribute("errorMsg", "Name, category and phone number are required.");
            response.sendRedirect(request.getContextPath() + "/admin-technicians.jsp");
            return;
        }

        if (!name.trim().matches("^[a-zA-Z\\s]{2,50}$")) {
            session.setAttribute("errorMsg", "Name must contain only letters and spaces (min 2 characters).");
            response.sendRedirect(request.getContextPath() + "/admin-technicians.jsp");
            return;
        }

        if (!phone.trim().matches("^\\+?[0-9\\s]{10,}$")) {
            session.setAttribute("errorMsg", "Phone number must be at least 10 digits (no letters).");
            response.sendRedirect(request.getContextPath() + "/admin-technicians.jsp");
            return;
        }

        int active = "1".equals(activeStr) ? 1 : 0;

        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement pst = conn.prepareStatement(
                    "INSERT INTO technicians (name, category, phone_number, active) VALUES (?, ?, ?, ?)");
            pst.setString(1, name.trim());
            pst.setString(2, category.trim());
            pst.setString(3, phone.trim());
            pst.setInt(4, active);
            pst.executeUpdate();
            session.setAttribute("successMsg", "Technician added successfully.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "Failed to add technician: " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/admin-technicians.jsp");
    }

    private void editTechnician(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws IOException {
        String idStr = request.getParameter("techId");
        String name = request.getParameter("name");
        String category = request.getParameter("category");
        String phone = request.getParameter("phone_number");
        String activeStr = request.getParameter("active");

        if (idStr == null || name == null || name.trim().isEmpty()
                || category == null || category.trim().isEmpty()
                || phone == null || phone.trim().isEmpty()) {
            session.setAttribute("errorMsg", "All fields are required for editing.");
            response.sendRedirect(request.getContextPath() + "/admin-technicians.jsp");
            return;
        }

        if (!name.trim().matches("^[a-zA-Z\\s]{2,50}$")) {
            session.setAttribute("errorMsg", "Name must contain only letters and spaces (min 2 characters).");
            response.sendRedirect(request.getContextPath() + "/admin-technicians.jsp");
            return;
        }

        if (!phone.trim().matches("^\\+?[0-9\\s]{10,}$")) {
            session.setAttribute("errorMsg", "Phone number must be at least 10 digits (no letters).");
            response.sendRedirect(request.getContextPath() + "/admin-technicians.jsp");
            return;
        }

        int active = "1".equals(activeStr) ? 1 : 0;

        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement pst = conn.prepareStatement(
                    "UPDATE technicians SET name = ?, category = ?, phone_number = ?, active = ? WHERE id = ?");
            pst.setString(1, name.trim());
            pst.setString(2, category.trim());
            pst.setString(3, phone.trim());
            pst.setInt(4, active);
            pst.setInt(5, Integer.parseInt(idStr));
            pst.executeUpdate();
            session.setAttribute("successMsg", "Technician updated successfully.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "Failed to update technician: " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/admin-technicians.jsp");
    }

    private void deleteTechnician(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws IOException {
        String idStr = request.getParameter("techId");
        if (idStr == null) {
            session.setAttribute("errorMsg", "Invalid technician ID.");
            response.sendRedirect(request.getContextPath() + "/admin-technicians.jsp");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            // Unassign from issues first
            PreparedStatement unassign = conn.prepareStatement(
                    "UPDATE issues SET assigned_technician_id = NULL WHERE assigned_technician_id = ?");
            unassign.setInt(1, Integer.parseInt(idStr));
            unassign.executeUpdate();

            PreparedStatement pst = conn.prepareStatement("DELETE FROM technicians WHERE id = ?");
            pst.setInt(1, Integer.parseInt(idStr));
            pst.executeUpdate();
            session.setAttribute("successMsg", "Technician deleted successfully.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "Failed to delete technician: " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/admin-technicians.jsp");
    }

    /* GET – used to fetch technicians by category as JSON for the auto-suggest */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        if (session.getAttribute("userId") == null || !"admin".equals(session.getAttribute("userRole"))) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String category = request.getParameter("category");
        if (category == null || category.trim().isEmpty()) {
            response.setContentType("application/json");
            response.getWriter().write("[]");
            return;
        }

        response.setContentType("application/json;charset=UTF-8");
        StringBuilder json = new StringBuilder("[");
        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement pst = conn.prepareStatement(
                    "SELECT id, name, phone_number FROM technicians WHERE category = ? AND active = 1 ORDER BY name");
            pst.setString(1, category.trim());
            ResultSet rs = pst.executeQuery();
            boolean first = true;
            while (rs.next()) {
                if (!first) json.append(",");
                json.append("{")
                    .append("\"id\":").append(rs.getInt("id")).append(",")
                    .append("\"name\":\"").append(escapeJson(rs.getString("name"))).append("\",")
                    .append("\"phone\":\"").append(escapeJson(rs.getString("phone_number"))).append("\"")
                    .append("}");
                first = false;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        json.append("]");
        response.getWriter().write(json.toString());
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
    }
}
