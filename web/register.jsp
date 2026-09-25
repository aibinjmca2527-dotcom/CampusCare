<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    if (session.getAttribute("justRegistered") != null) {
        session.removeAttribute("justRegistered");
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Account – CampusCare</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body class="auth-body">
<script>
window.onpageshow = function(event) {
    if (event.persisted) {
        window.location.reload();
    }
};
</script>

<div class="auth-layout">
    <a href="index.jsp" class="auth-logo">
        <span class="auth-logo-icon"><i class="fas fa-leaf"></i></span>
        CampusCare
    </a>

    <div class="auth-card-center auth-card-register">
        <h3>Create Account</h3>
        <p class="subtitle">Join CampusCare and start reporting issues</p>

        <c:if test="${not empty error}">
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <c:out value="${error}"/></div>
        </c:if>

        <form action="${pageContext.request.contextPath}/RegisterServlet" method="post">
            <div class="form-group">
                <label class="form-label">Full Name <span style="color:#dc2626">*</span></label>
                <input type="text" name="fullName" class="form-control" placeholder="Your full name" required autocomplete="name">
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Email <span style="color:#dc2626">*</span></label>
                    <input type="email" name="email" class="form-control" placeholder="you@college.com" required autocomplete="email">
                </div>
                <div class="form-group">
                    <label class="form-label">Phone</label>
                    <input type="tel" name="phone" class="form-control" placeholder="+91 99999 00000" autocomplete="tel">
                </div>
            </div>
            <div class="form-group">
                <label class="form-label">Department <span style="color:#dc2626">*</span></label>
                <select name="department" class="form-control" required>
                    <option value="">-- Select Department --</option>
                    <option value="MCA">MCA</option>
                    <option value="BCA">BCA</option>
                    <option value="BSc Computer Science">BSc Computer Science</option>
                    <option value="BSc Mathematics">BSc Mathematics</option>
                    <option value="Engineering">Engineering</option>
                    <option value="Arts &amp; Science">Arts &amp; Science</option>
                    <option value="Faculty">Faculty</option>
                    <option value="Staff">Staff</option>
                    <option value="Other">Other</option>
                </select>
            </div>
            <div class="form-group">
                <label class="form-label">Password <span style="color:#dc2626">*</span></label>
                <div class="input-password-wrap">
                    <input type="password" name="password" id="regPassword" class="form-control"
                        placeholder="Min 6 chars, 1 uppercase, 1 digit"
                        required minlength="6"
                        pattern="(?=.*[A-Z])(?=.*\d).{6,}"
                        title="At least 6 characters, one uppercase letter, and one digit"
                        autocomplete="new-password"
                        oninput="checkPasswordStrength(this, 'regPwHint')">
                    <button type="button" class="password-toggle-btn" onclick="togglePassword('regPassword', this)" tabindex="-1">
                        <i class="fas fa-eye"></i>
                    </button>
                </div>
                <div id="regPwHint" style="margin-top:.45rem;font-size:.8rem;"></div>
            </div>
            <button type="submit" class="btn btn-primary" style="width:100%;padding:.9rem;font-size:1rem;">
                <i class="fas fa-user-plus"></i> Create Account
            </button>
        </form>

        <p class="auth-footer-text">Already have an account? <a href="login.jsp">Sign in</a></p>
    </div>

    <p class="auth-back-home"><a href="index.jsp"><i class="fas fa-arrow-left"></i> Back to Home</a></p>
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
</script>
</body>
</html>
