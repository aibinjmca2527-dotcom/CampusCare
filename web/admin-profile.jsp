<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.campuscare.db.DBConnection" %>
<%
    if (session.getAttribute("userId") == null || !"admin".equals(session.getAttribute("userRole"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    int userId = (Integer) session.getAttribute("userId");
    String fullName = "", email = "";
    String profileImage = (String) session.getAttribute("profileImage");
    try (Connection conn = DBConnection.getConnection()) {
        PreparedStatement pst = conn.prepareStatement(
            "SELECT full_name, email, profile_image FROM users WHERE id = ?");
        pst.setInt(1, userId);
        ResultSet rs = pst.executeQuery();
        if (rs.next()) {
            fullName = rs.getString("full_name");
            email    = rs.getString("email");
            if (profileImage == null) profileImage = rs.getString("profile_image");
        }
    } catch (Exception e) { e.printStackTrace(); }
    String initial = fullName.isEmpty() ? "A" : fullName.substring(0, 1).toUpperCase();
    String ctx = request.getContextPath();
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Profile – CampusCare</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body>
<div class="app-shell">
<jsp:include page="includes/admin-nav.jsp"/>
<div class="app-main">
<main class="app-page">
    <div class="page-header">
        <h1>Admin Profile</h1>
        <p>Update your name, password, and profile photo</p>
    </div>
    <div class="app-content-centered">
        <div class="card">
            <div class="card-header"><i class="fas fa-user-shield"></i> Account Settings</div>
            <div class="card-body">
                <c:if test="${not empty sessionScope.profileError}">
                    <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <c:out value="${sessionScope.profileError}"/></div>
                    <% session.removeAttribute("profileError"); %>
                </c:if>
                <c:if test="${not empty sessionScope.profileSuccess}">
                    <div class="alert alert-success"><i class="fas fa-check-circle"></i> <c:out value="${sessionScope.profileSuccess}"/></div>
                    <% session.removeAttribute("profileSuccess"); %>
                </c:if>

                <form action="<%= ctx %>/UpdateProfileServlet" method="post" enctype="multipart/form-data">
                    <div class="profile-photo-row">
                        <div class="profile-photo-click-wrap" title="Click to change photo">
                            <% if (profileImage != null && !profileImage.trim().isEmpty()) { %>
                            <img src="<%= ctx %>/uploads/<%= profileImage %>" alt="Profile" class="profile-preview-img">
                            <% } else { %>
                            <div class="profile-preview-initial"><%= initial %></div>
                            <% } %>
                            <div class="profile-photo-overlay"><i class="fas fa-camera"></i></div>
                        </div>
                        <div class="form-group" style="flex:1;">
                            <label class="form-label">Profile Photo</label>
                            <input type="file" name="profilePhoto" id="profilePhotoInput" class="form-control" accept="image/jpeg,image/png,image/jpg">
                            <small class="form-hint">JPG or PNG, max 5MB — or click your photo above</small>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Full Name <span style="color:#dc2626">*</span></label>
                        <input type="text" name="fullName" class="form-control" value="<%= fullName %>" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Email</label>
                        <input type="email" class="form-control" value="<%= email %>" disabled>
                    </div>
                    <hr class="form-divider">
                    <p class="form-section-title"><i class="fas fa-lock" style="color:var(--brand-primary);margin-right:.4rem;"></i>Change Password <span style="font-weight:400;color:var(--text-muted);font-size:.85rem;">(optional)</span></p>
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">New Password</label>
                            <div class="input-password-wrap">
                                <input type="password" name="newPassword" id="newPassword" class="form-control"
                                    placeholder="Min 6 chars, 1 uppercase, 1 digit"
                                    minlength="6"
                                    pattern="(?=.*[A-Z])(?=.*\d).{6,}"
                                    title="At least 6 characters, one uppercase letter, and one digit"
                                    oninput="checkPasswordStrength(this, 'pwHint')">
                                <button type="button" class="password-toggle-btn" onclick="togglePassword('newPassword', this)" tabindex="-1"><i class="fas fa-eye"></i></button>
                            </div>
                            <div id="pwHint" style="margin-top:.45rem;font-size:.8rem;"></div>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Confirm Password</label>
                            <div class="input-password-wrap">
                                <input type="password" name="confirmPassword" id="confirmPassword" class="form-control" placeholder="Confirm new password" minlength="6">
                                <button type="button" class="password-toggle-btn" onclick="togglePassword('confirmPassword', this)" tabindex="-1"><i class="fas fa-eye"></i></button>
                            </div>
                        </div>
                    </div>
                    <div class="form-actions">
                        <a href="<%= ctx %>/admin-dashboard.jsp" class="btn btn-outline">Cancel</a>
                        <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Save Changes</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</main>
</div>
</div>
<script>
function togglePassword(id, btn) {
    var input = document.getElementById(id);
    var icon = btn.querySelector('i');
    if (input.type === 'password') {
        input.type = 'text';
        icon.classList.replace('fa-eye', 'fa-eye-slash');
    } else {
        input.type = 'password';
        icon.classList.replace('fa-eye-slash', 'fa-eye');
    }
}
function checkPasswordStrength(input, hintId) {
    var val = input.value;
    var hint = document.getElementById(hintId);
    if (!hint) return;
    var hasLen   = val.length >= 6;
    var hasUpper = /[A-Z]/.test(val);
    var hasDigit = /[0-9]/.test(val);
    if (val.length === 0) { hint.innerHTML = ''; return; }
    var rules = [
        { ok: hasLen,   text: 'At least 6 characters' },
        { ok: hasUpper, text: 'One uppercase letter (A-Z)' },
        { ok: hasDigit, text: 'One digit (0-9)' }
    ];
    var html = '<div style="display:flex;flex-wrap:wrap;gap:.3rem .75rem;">';
    rules.forEach(function(r) {
        html += '<span style="color:' + (r.ok ? '#16a34a' : '#dc2626') + ';">' +
            '<i class="fas fa-' + (r.ok ? 'check' : 'times') + '" style="font-size:.7rem;"></i> ' +
            r.text + '</span>';
    });
    html += '</div>';
    hint.innerHTML = html;
}
document.querySelector('.profile-photo-click-wrap').addEventListener('click', function() {
    document.getElementById('profilePhotoInput').click();
});
document.getElementById('profilePhotoInput').addEventListener('change', function() {
    var file = this.files[0];
    if (!file) return;
    var reader = new FileReader();
    reader.onload = function(e) {
        var wrap = document.querySelector('.profile-photo-click-wrap');
        var existing = wrap.querySelector('img, .profile-preview-initial');
        if (existing) existing.remove();
        var img = document.createElement('img');
        img.src = e.target.result;
        img.alt = 'Profile';
        img.className = 'profile-preview-img';
        wrap.insertBefore(img, wrap.querySelector('.profile-photo-overlay'));
    };
    reader.readAsDataURL(file);
});
</script>
</body>
</html>
