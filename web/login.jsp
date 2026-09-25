<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login – CampusCare</title>
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
        <h3>Welcome Back</h3>
        <p class="subtitle">Sign in to your CampusCare account</p>

        <c:if test="${not empty error}">
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <c:out value="${error}"/></div>
        </c:if>
        <c:if test="${not empty success}">
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> <c:out value="${success}"/></div>
        </c:if>
        <c:if test="${not empty sessionScope.successMsg}">
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> <c:out value="${sessionScope.successMsg}"/></div>
            <% session.removeAttribute("successMsg"); %>
        </c:if>

        <form action="${pageContext.request.contextPath}/LoginServlet" method="post">
            <div class="form-group">
                <label class="form-label">Email Address</label>
                <input type="email" name="email" id="loginEmail" class="form-control" placeholder="you@college.com" required autocomplete="email">
            </div>
            <div class="form-group">
                <label class="form-label">Password</label>
                <div class="input-password-wrap">
                    <input type="password" name="password" id="loginPassword" class="form-control" placeholder="Enter your password" required autocomplete="current-password">
                    <button type="button" class="password-toggle-btn" onclick="togglePassword('loginPassword', this)" tabindex="-1">
                        <i class="fas fa-eye"></i>
                    </button>
                </div>
            </div>
            <p class="auth-forgot-link"><a href="forgot-password.jsp">Forgot password?</a></p>
            <button type="submit" class="btn btn-primary" style="width:100%;padding:.9rem;font-size:1rem;">
                <i class="fas fa-sign-in-alt"></i> Sign In
            </button>
        </form>

        <p class="auth-footer-text">Don't have an account? <a href="register.jsp">Register here</a></p>
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
</script>
</body>
</html>
