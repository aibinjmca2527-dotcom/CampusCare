<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    String userName = String.valueOf(session.getAttribute("userName"));
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Submit Request – CampusCare</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body>
<div class="app-shell">
<jsp:include page="includes/user-nav.jsp"/>
<div class="app-main">
<main class="app-page">
    <div class="page-header">
        <div>
            <h1>New Service Request</h1>
            <p>Provide clear details so our team can respond quickly</p>
        </div>
        <div class="page-header-actions">
            <a href="${pageContext.request.contextPath}/user-dashboard.jsp" class="btn btn-outline">
                <i class="fas fa-arrow-left"></i> Back
            </a>
        </div>
    </div>
    <div class="app-content-centered">
        <div class="card">
            <div class="card-header"><i class="fas fa-file-alt"></i> Request Details</div>
            <div class="card-body">
                <c:if test="${not empty error}">
                    <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <c:out value="${error}"/></div>
                </c:if>

                <form action="${pageContext.request.contextPath}/ReportIssueServlet" method="post" enctype="multipart/form-data">
                    <div class="form-group">
                        <label class="form-label">Title / Brief Summary <span style="color:#dc2626">*</span></label>
                        <input type="text" name="title" class="form-control" placeholder="e.g. Broken projector in Room 302" required>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">Category <span style="color:#dc2626">*</span></label>
                            <select name="category" class="form-control" required>
                                <option value="">-- Select --</option>
                                <option value="IT &amp; Network">IT &amp; Network</option>
                                <option value="Electrical">Electrical</option>
                                <option value="Plumbing">Plumbing</option>
                                <option value="Infrastructure">Infrastructure</option>
                                <option value="Cleanliness">Cleanliness</option>
                                <option value="Other">Other</option>
                            </select>
                        </div>
                        <div class="form-group" style="grid-column: 1 / -1;">
                            <label class="form-label">Location Details <span style="color:#dc2626">*</span></label>
                            <input type="text" name="location" class="form-control" placeholder="Building, floor, room (e.g. Library 2nd Floor)" required>
                        </div>
                    </div>
                    <!-- Description is now OPTIONAL -->
                    <div class="form-group">
                        <label class="form-label">Description <span style="color:var(--text-muted);font-weight:400;font-size:.8rem;">(optional)</span></label>
                        <textarea name="description" class="form-control" rows="5"
                            placeholder="Describe the issue in detail (optional — but helps us respond faster)..."></textarea>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Photo Evidence <span style="color:var(--text-muted);font-weight:400;font-size:.8rem;">(optional)</span></label>
                        <label for="imageUpload" class="file-upload-box" id="dropArea">
                            <i class="fas fa-cloud-upload-alt"></i>
                            <div style="font-weight:600;margin-bottom:.35rem;">Click to upload image</div>
                            <div style="font-size:.85rem;color:var(--text-secondary);">JPG or PNG, max 10MB</div>
                            <span id="fileNameDisplay" class="file-name-badge"></span>
                        </label>
                        <input type="file" id="imageUpload" name="image" accept="image/jpeg,image/png,image/jpg" style="display:none;">
                    </div>
                    <div class="form-actions">
                        <a href="${pageContext.request.contextPath}/user-dashboard.jsp" class="btn btn-outline">Cancel</a>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-paper-plane"></i> Submit Request
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</main>
</div>
</div>
<script>
document.getElementById('imageUpload').addEventListener('change', function() {
    var badge = document.getElementById('fileNameDisplay');
    var area = document.getElementById('dropArea');
    if (this.files && this.files.length > 0) {
        badge.textContent = this.files[0].name;
        badge.classList.add('visible');
        area.classList.add('has-file');
    } else {
        badge.classList.remove('visible');
        area.classList.remove('has-file');
    }
});
</script>
</body>
</html>
