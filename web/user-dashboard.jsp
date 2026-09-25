<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.campuscare.db.DBConnection" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    if ("admin".equals(session.getAttribute("userRole"))) {
        response.sendRedirect(request.getContextPath() + "/admin-dashboard.jsp");
        return;
    }
    int userId = (Integer) session.getAttribute("userId");
    String userName = String.valueOf(session.getAttribute("userName"));

    int totalIssues = 0, pendingIssues = 0, inProgressIssues = 0, resolvedIssues = 0;
    try (Connection conn = DBConnection.getConnection()) {
        PreparedStatement pst = conn.prepareStatement("SELECT status, COUNT(*) as count FROM issues WHERE user_id = ? GROUP BY status");
        pst.setInt(1, userId);
        ResultSet rs = pst.executeQuery();
        while (rs.next()) {
            String status = rs.getString("status");
            int count = rs.getInt("count");
            totalIssues += count;
            if ("Pending".equals(status)) pendingIssues += count;
            else if ("In Progress".equals(status)) inProgressIssues += count;
            else if ("Resolved".equals(status)) resolvedIssues += count;
        }

        // Check for unrated resolved issues
        PreparedStatement pst2 = conn.prepareStatement(
            "SELECT id, title FROM issues WHERE user_id = ? AND status = 'Resolved' AND (user_rating = 0 OR user_rating IS NULL) ORDER BY updated_at DESC LIMIT 1"
        );
        pst2.setInt(1, userId);
        ResultSet rs2 = pst2.executeQuery();
        if (rs2.next()) {
            request.setAttribute("unratedIssueId", rs2.getInt("id"));
            request.setAttribute("unratedIssueTitle", rs2.getString("title"));
        }
    } catch (Exception e) { e.printStackTrace(); }
%>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Dashboard – CampusCare</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        .star-rating {
            display: flex;
            flex-direction: row-reverse;
            justify-content: flex-end;
            gap: 0.5rem;
        }
        .star-rating input[type="radio"] {
            display: none;
        }
        .star-rating label {
            font-size: 2rem;
            color: #d1d5db;
            cursor: pointer;
            transition: color 0.2s ease;
        }
        .star-rating input[type="radio"]:checked ~ label,
        .star-rating label:hover,
        .star-rating label:hover ~ label {
            color: #f59e0b;
        }
    </style>
</head>
<body>
<div class="app-shell">
<jsp:include page="includes/user-nav.jsp"/>
<div class="app-main">
<main class="app-page">
    <div class="page-header">
        <div>
            <h1>Overview</h1>
            <p>Welcome back, <%= userName %></p>
        </div>
        <div class="page-header-actions">
            <a href="${pageContext.request.contextPath}/report-issue.jsp" class="btn btn-primary">
                <i class="fas fa-plus-circle"></i> New Request
            </a>
        </div>
    </div>
    <div class="app-content">
        <c:if test="${not empty sessionScope.successMsg}">
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> <c:out value="${sessionScope.successMsg}"/></div>
            <% session.removeAttribute("successMsg"); %>
        </c:if>

        <div class="metrics-strip">
            <div class="metric-pill">
                <div class="icon-wrap navy"><i class="fas fa-folder-open"></i></div>
                <div><div class="label">Total Submitted</div><div class="value"><%= totalIssues %></div></div>
            </div>
            <div class="metric-pill">
                <div class="icon-wrap amber"><i class="fas fa-clock"></i></div>
                <div><div class="label">Pending</div><div class="value"><%= pendingIssues %></div></div>
            </div>
            <div class="metric-pill">
                <div class="icon-wrap blue"><i class="fas fa-spinner"></i></div>
                <div><div class="label">In Progress</div><div class="value"><%= inProgressIssues %></div></div>
            </div>
            <div class="metric-pill">
                <div class="icon-wrap green"><i class="fas fa-check-circle"></i></div>
                <div><div class="label">Resolved</div><div class="value"><%= resolvedIssues %></div></div>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <span><i class="fas fa-list"></i> Recent Requests</span>
                <a href="${pageContext.request.contextPath}/my-complaints.jsp" style="font-size:.85rem;font-weight:500;">View all &rarr;</a>
            </div>
            <div class="table-wrap">
                <table class="data-table">
                    <thead>
                        <tr><th>Title</th><th>Category</th><th>Date</th><th>Status</th></tr>
                    </thead>
                    <tbody>
                            <%
                                try (Connection conn = DBConnection.getConnection()) {
                                    PreparedStatement pst = conn.prepareStatement(
                                        "SELECT * FROM issues WHERE user_id = ? ORDER BY created_at DESC LIMIT 5");
                                    pst.setInt(1, userId);
                                    ResultSet rs = pst.executeQuery();
                                    boolean hasIssues = false;
                                    while (rs.next()) {
                                        hasIssues = true;
                                        String status = rs.getString("status");
                                        String statusClass = status.toLowerCase();
                                        if ("In Progress".equals(status)) statusClass = "progress";
                                        if ("Assigned".equals(status)) statusClass = "assigned";
                            %>
                            <tr>
                                <td>
                                    <div class="issue-row-title"><%= rs.getString("title") %></div>
                                    <div class="issue-row-meta"><i class="fas fa-map-marker-alt"></i> <%= rs.getString("location") %></div>
                                </td>
                                <td><%= rs.getString("category") %></td>
                                <td style="color:var(--text-secondary);"><%= rs.getTimestamp("created_at").toString().substring(0, 10) %></td>
                                <td><span class="status-badge status-<%= statusClass %>"><%= status %></span></td>
                            </tr>
                            <%
                                    }
                                    if (!hasIssues) {
                            %>
                            <tr><td colspan="4">
                                <div class="empty-state">
                                    <i class="fas fa-inbox"></i>
                                    <h3>No requests yet</h3>
                                    <p>Submit your first campus issue to get started.</p>
                                    <a href="${pageContext.request.contextPath}/report-issue.jsp" class="btn btn-outline">Submit Request</a>
                                </div>
                            </td></tr>
                            <%
                                    }
                                } catch (Exception e) {
                                    out.println("<tr><td colspan='4'>Error: " + e.getMessage() + "</td></tr>");
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</main>
</div>
</div>

<% if (request.getAttribute("unratedIssueId") != null) { %>
<!-- Auto Rating Modal -->
<div class="modal-overlay open" id="autoRatingModal">
    <div class="modal-content">
        <div class="modal-header">
            <h3><i class="fas fa-star" style="color:#f59e0b;margin-right:.5rem;"></i> Rate Resolution</h3>
            <button type="button" class="modal-close" onclick="closeAutoRatingModal()"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
            <p style="margin-bottom:1rem;color:var(--text-secondary);">
                Your request "<strong><%= request.getAttribute("unratedIssueTitle") %></strong>" was recently marked as resolved! Please take a moment to rate the service.
            </p>
            <form action="${pageContext.request.contextPath}/SubmitRatingServlet" method="post">
                <input type="hidden" name="issueId" value="<%= request.getAttribute("unratedIssueId") %>">
                <input type="hidden" name="redirect" value="dashboard">
                <div class="form-group">
                    <label class="form-label">Rating (1 to 5 Stars)</label>
                    <div class="star-rating">
                        <input type="radio" id="sstar5" name="rating" value="5" required />
                        <label for="sstar5" title="5 stars"><i class="fas fa-star"></i></label>
                        <input type="radio" id="sstar4" name="rating" value="4" />
                        <label for="sstar4" title="4 stars"><i class="fas fa-star"></i></label>
                        <input type="radio" id="sstar3" name="rating" value="3" />
                        <label for="sstar3" title="3 stars"><i class="fas fa-star"></i></label>
                        <input type="radio" id="sstar2" name="rating" value="2" />
                        <label for="sstar2" title="2 stars"><i class="fas fa-star"></i></label>
                        <input type="radio" id="sstar1" name="rating" value="1" />
                        <label for="sstar1" title="1 star"><i class="fas fa-star"></i></label>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label">Feedback Comments (Optional)</label>
                    <textarea name="feedback" class="form-control" rows="3" placeholder="Tell us how the technician did..."></textarea>
                </div>
                <div class="form-actions" style="display:flex;justify-content:flex-end;gap:1rem;margin-top:1.5rem;">
                    <button type="button" class="btn btn-outline" onclick="closeAutoRatingModal()">Skip for now</button>
                    <button type="submit" class="btn btn-primary">Submit Rating</button>
                </div>
            </form>
        </div>
    </div>
</div>
<script>
function closeAutoRatingModal() {
    document.getElementById('autoRatingModal').classList.remove('open');
}
</script>
<% } %>

</body>
</html>
