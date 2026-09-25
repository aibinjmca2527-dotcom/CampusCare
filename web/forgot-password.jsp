<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password – CampusCare</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body class="auth-body">

<div class="auth-layout">
    <a href="index.jsp" class="auth-logo">
        <span class="auth-logo-icon"><i class="fas fa-leaf"></i></span>
        CampusCare
    </a>

    <div class="auth-card-center">
        <h3>Forgot Password</h3>
        <p class="subtitle">Enter your registered email. We will send a new password.</p>

        <c:if test="${not empty error}">
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <c:out value="${error}"/></div>
            <c:if test="${error == 'Password reset email is not configured. Contact your administrator.'}">
                <div class="alert alert-info" style="margin-top: 0.75rem; text-align: left; font-size: 0.85rem;">
                    <strong>Setup (one time):</strong>
                    <ol style="margin: 0.5rem 0 0 1.1rem; padding: 0;">
                        <li>Copy <code>WEB-INF/email.properties.example</code> to <code>WEB-INF/email.properties</code></li>
                        <li>Set your Gmail, App Password, and <code>mail.enabled=true</code></li>
                        <li>Clean and Build, then redeploy. See <code>WEB-INF/EMAIL_SETUP.txt</code> in the project.</li>
                    </ol>
                </div>
            </c:if>
        </c:if>
        <c:if test="${not empty success}">
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> <c:out value="${success}"/></div>
        </c:if>

        <form id="resetForm" action="${pageContext.request.contextPath}/ForgotPasswordServlet" method="post" onsubmit="return handleSubmit()">
            <div class="form-group">
                <label class="form-label">Registered Email</label>
                <input type="email" name="email" class="form-control" placeholder="you@college.com" required autocomplete="email">
            </div>
            <button type="submit" id="resetBtn" class="btn btn-primary" style="width: 100%; padding: 0.85rem;">
                <i class="fas fa-envelope"></i> Send New Password
            </button>
        </form>

        <p class="auth-footer-text"><a href="login.jsp"><i class="fas fa-arrow-left"></i> Back to Sign In</a></p>
    </div>

    <p class="auth-back-home"><a href="index.jsp"><i class="fas fa-arrow-left"></i> Back to Home</a></p>
</div>

<script>
function handleSubmit() {
    var btn = document.getElementById('resetBtn');
    if (btn.disabled) {
        return false;
    }
    btn.disabled = true;
    btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Sending...';
    btn.style.opacity = '0.75';
    btn.style.cursor = 'not-allowed';
    return true;
}
</script>
</body>
</html>
