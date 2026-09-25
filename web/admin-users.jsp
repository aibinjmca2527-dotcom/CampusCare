<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.campuscare.db.DBConnection" %>
<%
    if (session.getAttribute("userId") == null || !"admin".equals(session.getAttribute("userRole"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    int adminId = (Integer) session.getAttribute("userId");
    String ctx = request.getContextPath();
    int totalAccounts = 0, regularUsers = 0, adminCount = 0;
    try (Connection conn = DBConnection.getConnection()) {
        ResultSet rs = conn.createStatement().executeQuery("SELECT role, COUNT(*) as c FROM users GROUP BY role");
        while (rs.next()) {
            int count = rs.getInt("c");
            totalAccounts += count;
            if ("admin".equals(rs.getString("role"))) adminCount += count;
            else regularUsers += count;
        }
    } catch (Exception e) { e.printStackTrace(); }
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Management – CampusCare Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body>
<div class="app-shell">
<jsp:include page="includes/admin-nav.jsp"/>
<div class="app-main">
<main class="app-page">
    <div class="page-header">
        <h1>User Management</h1>
        <p>All registered CampusCare accounts</p>
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

        <div class="metrics-strip">
            <div class="metric-pill">
                <div class="icon-wrap navy"><i class="fas fa-users"></i></div>
                <div><div class="label">Total Accounts</div><div class="value"><%= totalAccounts %></div></div>
            </div>
            <div class="metric-pill">
                <div class="icon-wrap blue"><i class="fas fa-user-graduate"></i></div>
                <div><div class="label">Students / Staff</div><div class="value"><%= regularUsers %></div></div>
            </div>
            <div class="metric-pill">
                <div class="icon-wrap green"><i class="fas fa-user-shield"></i></div>
                <div><div class="label">Administrators</div><div class="value"><%= adminCount %></div></div>
            </div>
        </div>

        <div class="card">
            <div class="card-header"><i class="fas fa-users"></i> Registered Users</div>
            <div class="table-wrap">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Department</th>
                            <th>Phone</th>
                            <th>Role</th>
                            <th>Issues</th>
                            <th>Joined</th>
                            <th style="text-align:right;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try (Connection conn = DBConnection.getConnection()) {
                                String sql = "SELECT u.id, u.full_name, u.email, u.department, u.phone, u.role, u.is_banned, u.created_at, " +
                                    "(SELECT COUNT(*) FROM issues WHERE user_id = u.id) as issue_count " +
                                    "FROM users u ORDER BY u.created_at DESC";
                                ResultSet rs = conn.createStatement().executeQuery(sql);
                                boolean hasData = false;
                                while (rs.next()) {
                                    hasData = true;
                                    int uid = rs.getInt("id");
                                    String uRole = rs.getString("role");
                                    String uPhone = rs.getString("phone");
                        %>
                        <tr>
                            <td><span class="ref-id">#<%= String.format("%04d", uid) %></span></td>
                            <td style="font-weight:600;"><%= rs.getString("full_name") %></td>
                            <td style="color:var(--text-secondary);font-size:.88rem;"><%= rs.getString("email") %></td>
                            <td><%= rs.getString("department") != null ? rs.getString("department") : "—" %></td>
                            <td style="color:var(--text-secondary);">
                                <% if (uPhone != null && !uPhone.trim().isEmpty()) { %>
                                <a href="tel:<%= uPhone %>" style="color:var(--brand-primary);"><%= uPhone %></a>
                                <% } else { %>—<% } %>
                            </td>
                            <td>
                                <% if (rs.getInt("is_banned") == 1) { %>
                                    <span class="role-badge banned" style="margin-right: 4px;">BANNED</span>
                                <% } %>
                                <span class="role-badge <%= uRole %>"><%= uRole.toUpperCase() %></span>
                            </td>
                            <td style="text-align:center;font-weight:600;color:var(--brand-primary);"><%= rs.getInt("issue_count") %></td>
                            <td style="color:var(--text-secondary);"><%= rs.getTimestamp("created_at").toString().substring(0, 10) %></td>
                            <td style="text-align:right;">
                                <% if ("admin".equals(uRole)) { %>
                                <span style="font-size:.8rem;color:var(--text-muted);padding:.3rem .6rem;background:#f1f5f9;border-radius:var(--radius-xs);">Protected</span>
                                <% } else if (uid == adminId) { %>
                                <span style="font-size:.8rem;color:var(--text-muted);padding:.3rem .6rem;background:#f1f5f9;border-radius:var(--radius-xs);">You</span>
                                <% } else { %>
                                <form id="banUserForm_<%= uid %>" action="<%= ctx %>/AdminUserStatusServlet" method="post" style="display:inline;">
                                    <input type="hidden" name="userId" value="<%= uid %>">
                                    <input type="hidden" name="action" value="<%= rs.getInt("is_banned") == 1 ? "unban" : "ban" %>">
                                    <button type="button" class="btn btn-outline btn-sm" style="margin-right:4px;" onclick="openBanModal(<%= uid %>, <%= rs.getInt("is_banned") == 1 ? "'unban'" : "'ban'" %>, '<%= rs.getString("full_name").replace("'","\\'") %>')">
                                        <%= rs.getInt("is_banned") == 1 ? "<i class='fas fa-user-check' style='color:var(--brand-primary);'></i>" : "<i class='fas fa-ban' style='color:#dc2626;'></i>" %>
                                    </button>
                                </form>
                                <form id="deleteUserForm_<%= uid %>" action="<%= ctx %>/DeleteUserServlet" method="post" style="display:inline;">
                                    <input type="hidden" name="userId" value="<%= uid %>">
                                    <button type="button" class="btn btn-danger btn-sm" onclick="openDeleteUserModal(<%= uid %>, '<%= rs.getString("full_name").replace("'","\\'") %>')">
                                        <i class="fas fa-trash-alt"></i>
                                    </button>
                                </form>
                                <% } %>
                            </td>
                        </tr>
                        <%
                                }
                                if (!hasData) {
                        %>
                        <tr><td colspan="9">
                            <div class="empty-state">
                                <i class="fas fa-users"></i>
                                <h3>No users registered yet</h3>
                            </div>
                        </td></tr>
                        <%
                                }
                            } catch (Exception e) {
                                out.println("<tr><td colspan='9'>Error: " + e.getMessage() + "</td></tr>");
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

<!-- Ban User Modal -->
<div class="modal-overlay" id="banUserModal">
    <div class="modal-content">
        <div class="modal-header">
            <h3><i class="fas fa-user-shield" style="color:var(--brand-primary);margin-right:.5rem;"></i> Manage User Access</h3>
            <button type="button" class="modal-close" onclick="closeModal('banUserModal')"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
            <p style="margin-bottom:1rem;color:var(--text-main);" id="banUserMsg"></p>
            <div class="form-actions" style="border:none;padding-top:0;margin-top:1.5rem; display:flex; gap:1rem; justify-content:flex-end;">
                <button type="button" class="btn btn-outline" onclick="closeModal('banUserModal')">Cancel</button>
                <button type="button" class="btn btn-primary" id="banConfirmBtn" onclick="confirmBanUser()">Confirm</button>
            </div>
        </div>
    </div>
</div>

<!-- Delete User Modal -->
<div class="modal-overlay" id="deleteUserModal">
    <div class="modal-content">
        <div class="modal-header">
            <h3><i class="fas fa-exclamation-triangle" style="color:#dc2626;margin-right:.5rem;"></i> Delete User</h3>
            <button type="button" class="modal-close" onclick="closeModal('deleteUserModal')"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
            <p style="margin-bottom:1rem;color:var(--text-main);" id="deleteUserMsg"></p>
            <div class="form-actions" style="border:none;padding-top:0;margin-top:1.5rem; display:flex; gap:1rem; justify-content:flex-end;">
                <button type="button" class="btn btn-outline" onclick="closeModal('deleteUserModal')">Cancel</button>
                <button type="button" class="btn btn-primary" style="background:#dc2626; border-color:#dc2626;" onclick="confirmDeleteUser()">Yes, delete</button>
            </div>
        </div>
    </div>
</div>

<script>
var targetUserId = null;

function openBanModal(id, action, name) {
    targetUserId = id;
    var msg = (action === 'ban') ? 'Ban user ' + name + '?' : 'Unban user ' + name + '?';
    document.getElementById('banUserMsg').innerText = msg;
    var btn = document.getElementById('banConfirmBtn');
    if (action === 'ban') {
        btn.style.background = '#dc2626'; btn.style.borderColor = '#dc2626'; btn.innerText = 'Yes, ban user';
    } else {
        btn.style.background = 'var(--brand-primary)'; btn.style.borderColor = 'var(--brand-primary)'; btn.innerText = 'Yes, unban user';
    }
    document.getElementById('banUserModal').classList.add('open');
}
function confirmBanUser() {
    if (targetUserId) {
        document.getElementById('banUserForm_' + targetUserId).submit();
    }
}

function openDeleteUserModal(id, name) {
    targetUserId = id;
    document.getElementById('deleteUserMsg').innerText = 'Delete user ' + name + '? This cannot be undone.';
    document.getElementById('deleteUserModal').classList.add('open');
}
function confirmDeleteUser() {
    if (targetUserId) {
        document.getElementById('deleteUserForm_' + targetUserId).submit();
    }
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
