<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.campuscare.db.DBConnection" %>
<%
    if (session.getAttribute("userId") == null || !"admin".equals(session.getAttribute("userRole"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    String ctx = request.getContextPath();
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    int totalTech = 0, activeTech = 0, inactiveTech = 0;
    try (Connection conn = DBConnection.getConnection()) {
        ResultSet rs = conn.createStatement().executeQuery("SELECT active, COUNT(*) as cnt FROM technicians GROUP BY active");
        while (rs.next()) {
            int cnt = rs.getInt("cnt");
            totalTech += cnt;
            if (rs.getInt("active") == 1) activeTech += cnt;
            else inactiveTech += cnt;
        }
    } catch (Exception e) { e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Technician Management – CampusCare</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body>
<div class="app-shell">
<jsp:include page="includes/admin-nav.jsp"/>
<div class="app-main">
<main class="app-page">

    <div class="page-header">
        <div>
            <h1>Technician Management</h1>
            <p>Add and manage technicians for each issue category</p>
        </div>
        <div class="page-header-actions">
            <button type="button" class="btn btn-primary" onclick="openAddModal()">
                <i class="fas fa-plus"></i> Add Technician
            </button>
        </div>
    </div>

    <div class="app-content">
        <c:if test="${not empty sessionScope.successMsg}">
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> <c:out value="${sessionScope.successMsg}"/></div>
            <% session.removeAttribute("successMsg"); %>
        </c:if>
        <c:if test="${not empty sessionScope.errorMsg}">
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <c:out value="${sessionScope.errorMsg}"/></div>
            <% session.removeAttribute("errorMsg"); %>
        </c:if>

        <!-- Metrics -->
        <div class="metrics-strip">
            <div class="metric-pill">
                <div class="icon-wrap teal"><i class="fas fa-hard-hat"></i></div>
                <div><div class="label">Total</div><div class="value"><%= totalTech %></div></div>
            </div>
            <div class="metric-pill">
                <div class="icon-wrap green"><i class="fas fa-check-circle"></i></div>
                <div><div class="label">Active</div><div class="value"><%= activeTech %></div></div>
            </div>
            <div class="metric-pill">
                <div class="icon-wrap amber"><i class="fas fa-pause-circle"></i></div>
                <div><div class="label">Inactive</div><div class="value"><%= inactiveTech %></div></div>
            </div>
        </div>

        <!-- Technicians Table -->
        <div class="card">
            <div class="card-header"><i class="fas fa-hard-hat"></i> All Technicians</div>
            <div class="table-wrap">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Category</th>
                            <th>Phone</th>
                            <th>Status</th>
                            <th style="text-align:right;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try (Connection conn = DBConnection.getConnection()) {
                                ResultSet rs = conn.createStatement().executeQuery(
                                    "SELECT * FROM technicians ORDER BY category, name");
                                boolean hasData = false;
                                while (rs.next()) {
                                    hasData = true;
                                    int tid = rs.getInt("id");
                                    String tname = rs.getString("name");
                                    String tcat = rs.getString("category");
                                    String tphone = rs.getString("phone_number");
                                    boolean tactive = rs.getInt("active") == 1;
                                    String tnameSafe = tname.replace("\\","\\\\").replace("'","\\'");
                                    String tcatSafe = tcat.replace("\\","\\\\").replace("'","\\'");
                                    String tphoneSafe = tphone.replace("\\","\\\\").replace("'","\\'");
                        %>
                        <tr>
                            <td><span class="ref-id">#<%= String.format("%04d", tid) %></span></td>
                            <td style="font-weight:600;"><%= tname %></td>
                            <td><span class="status-badge status-progress"><%= tcat %></span></td>
                            <td>
                                <a href="tel:<%= tphone %>" style="color:var(--brand-primary);font-weight:600;">
                                    <i class="fas fa-phone" style="font-size:.8rem;margin-right:.3rem;"></i><%= tphone %>
                                </a>
                            </td>
                            <td>
                                <% if (tactive) { %>
                                <span class="tech-status-active">Active</span>
                                <% } else { %>
                                <span class="tech-status-inactive">Inactive</span>
                                <% } %>
                            </td>
                            <td style="text-align:right;">
                                <div style="display:flex;justify-content:flex-end;gap:.5rem;">
                                    <button type="button" class="btn btn-outline btn-sm"
                                        onclick="openEditModal(<%= tid %>, '<%= tnameSafe %>', '<%= tcatSafe %>', '<%= tphoneSafe %>', <%= tactive ? 1 : 0 %>)">
                                        <i class="fas fa-edit"></i> Edit
                                    </button>
                                    <form id="deleteTechForm_<%= tid %>" action="<%= ctx %>/TechnicianServlet" method="post" style="display:inline;">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="techId" value="<%= tid %>">
                                        <button type="button" class="btn btn-danger btn-sm" onclick="openDeleteModal(<%= tid %>)">
                                            <i class="fas fa-trash-alt"></i>
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                        <%
                                }
                                if (!hasData) {
                        %>
                        <tr><td colspan="6">
                            <div class="empty-state">
                                <i class="fas fa-hard-hat"></i>
                                <h3>No technicians yet</h3>
                                <p>Click "Add Technician" to get started.</p>
                                <button type="button" class="btn btn-primary" onclick="openAddModal()">
                                    <i class="fas fa-plus"></i> Add Technician
                                </button>
                            </div>
                        </td></tr>
                        <%
                                }
                            } catch (Exception e) {
                                out.println("<tr><td colspan='6'>Error: " + e.getMessage() + "</td></tr>");
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>
</div>
</div>

<!-- Add Technician Modal -->
<div class="modal-overlay" id="addModal">
    <div class="modal-content">
        <div class="modal-header">
            <h3><i class="fas fa-plus" style="color:var(--brand-primary);margin-right:.5rem;"></i> Add Technician</h3>
            <button type="button" class="modal-close" onclick="closeModal('addModal')"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
            <div id="addErrorMsg" class="alert alert-error" style="display:none; margin-bottom:1rem; padding:0.5rem; font-size:0.85rem;"><i class="fas fa-exclamation-circle"></i> <span></span></div>
            <form action="<%= ctx %>/TechnicianServlet" method="post" onsubmit="return validateTechForm('add')">
                <input type="hidden" name="action" value="add">
                <div class="form-group">
                    <label class="form-label">Technician Name <span style="color:#dc2626">*</span></label>
                    <input type="text" name="name" id="addName" class="form-control" placeholder="e.g. Ramesh Kumar" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Category <span style="color:#dc2626">*</span></label>
                    <select name="category" class="form-control" required>
                        <option value="">-- Select Category --</option>
                        <option value="IT &amp; Network">IT &amp; Network</option>
                        <option value="Electrical">Electrical</option>
                        <option value="Plumbing">Plumbing</option>
                        <option value="Infrastructure">Infrastructure</option>
                        <option value="Cleanliness">Cleanliness</option>
                        <option value="Other">Other</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Phone Number <span style="color:#dc2626">*</span></label>
                    <input type="tel" name="phone_number" id="addPhone" class="form-control" placeholder="+91 98765 00000" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Status</label>
                    <select name="active" class="form-control">
                        <option value="1">Active</option>
                        <option value="0">Inactive</option>
                    </select>
                </div>
                <div class="form-actions" style="border:none;padding-top:0;margin-top:0;">
                    <button type="button" class="btn btn-outline" onclick="closeModal('addModal')">Cancel</button>
                    <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Add Technician</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Edit Technician Modal -->
<div class="modal-overlay" id="editModal">
    <div class="modal-content">
        <div class="modal-header">
            <h3><i class="fas fa-edit" style="color:var(--brand-primary);margin-right:.5rem;"></i> Edit Technician</h3>
            <button type="button" class="modal-close" onclick="closeModal('editModal')"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
            <div id="editErrorMsg" class="alert alert-error" style="display:none; margin-bottom:1rem; padding:0.5rem; font-size:0.85rem;"><i class="fas fa-exclamation-circle"></i> <span></span></div>
            <form action="<%= ctx %>/TechnicianServlet" method="post" onsubmit="return validateTechForm('edit')">
                <input type="hidden" name="action" value="edit">
                <input type="hidden" name="techId" id="editTechId">
                <div class="form-group">
                    <label class="form-label">Technician Name <span style="color:#dc2626">*</span></label>
                    <input type="text" name="name" id="editName" class="form-control" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Category <span style="color:#dc2626">*</span></label>
                    <select name="category" id="editCategory" class="form-control" required>
                        <option value="IT &amp; Network">IT &amp; Network</option>
                        <option value="Electrical">Electrical</option>
                        <option value="Plumbing">Plumbing</option>
                        <option value="Infrastructure">Infrastructure</option>
                        <option value="Cleanliness">Cleanliness</option>
                        <option value="Other">Other</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Phone Number <span style="color:#dc2626">*</span></label>
                    <input type="tel" name="phone_number" id="editPhone" class="form-control" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Status</label>
                    <select name="active" id="editActive" class="form-control">
                        <option value="1">Active</option>
                        <option value="0">Inactive</option>
                    </select>
                </div>
                <div class="form-actions" style="border:none;padding-top:0;margin-top:0;">
                    <button type="button" class="btn btn-outline" onclick="closeModal('editModal')">Cancel</button>
                    <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Save Changes</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Delete Technician Modal -->
<div class="modal-overlay" id="deleteModal">
    <div class="modal-content">
        <div class="modal-header">
            <h3><i class="fas fa-exclamation-triangle" style="color:#dc2626;margin-right:.5rem;"></i> Delete Technician</h3>
            <button type="button" class="modal-close" onclick="closeModal('deleteModal')"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
            <p style="margin-bottom:1rem;color:var(--text-main);">
                Are you sure you want to permanently delete this technician? This action cannot be undone.
            </p>
            <div class="form-actions" style="border:none;padding-top:0;margin-top:1.5rem; display:flex; gap:1rem; justify-content:flex-end;">
                <button type="button" class="btn btn-outline" onclick="closeModal('deleteModal')">Cancel</button>
                <button type="button" class="btn btn-primary" style="background:#dc2626; border-color:#dc2626;" onclick="confirmDelete()">Yes, delete</button>
            </div>
        </div>
    </div>
</div>

<script>
var techToDelete = null;

function openDeleteModal(id) {
    techToDelete = id;
    document.getElementById('deleteModal').classList.add('open');
}
function confirmDelete() {
    if (techToDelete) {
        document.getElementById('deleteTechForm_' + techToDelete).submit();
    }
}
function validateTechForm(type) {
    var name = document.getElementById(type + 'Name').value;
    var phone = document.getElementById(type + 'Phone').value;
    var errorDiv = document.getElementById(type + 'ErrorMsg');
    var errorSpan = errorDiv.querySelector('span');

    var nameRegex = /^[a-zA-Z\s]{2,50}$/;
    var phoneRegex = /^\+?[0-9\s]{10,}$/;

    if (!nameRegex.test(name.trim())) {
        errorSpan.textContent = " Name must contain only letters and spaces.";
        errorDiv.style.display = "block";
        return false;
    }
    if (!phoneRegex.test(phone.trim())) {
        errorSpan.textContent = " Phone number must be at least 10 digits (no letters).";
        errorDiv.style.display = "block";
        return false;
    }
    errorDiv.style.display = "none";
    return true;
}
function openAddModal() {
    document.getElementById('addErrorMsg').style.display = 'none';
    document.getElementById('addModal').classList.add('open');
}
function openEditModal(id, name, category, phone, active) {
    document.getElementById('editErrorMsg').style.display = 'none';
    document.getElementById('editTechId').value = id;
    document.getElementById('editName').value = name;
    document.getElementById('editCategory').value = category;
    document.getElementById('editPhone').value = phone;
    document.getElementById('editActive').value = active;
    document.getElementById('editModal').classList.add('open');
}
function closeModal(id) {
    document.getElementById(id).classList.remove('open');
}
document.querySelectorAll('.modal-overlay').forEach(function(el) {
    el.addEventListener('click', function(e) {
        if (e.target === el) el.classList.remove('open');
    });
});
</script>
</body>
</html>
