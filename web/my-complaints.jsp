<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.campuscare.db.DBConnection" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    int userId = (Integer) session.getAttribute("userId");
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
    <title>Request History – CampusCare</title>
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
            <h1>Request History</h1>
            <p>Full log of all issues you have submitted</p>
        </div>
        <div class="page-header-actions">
            <a href="${pageContext.request.contextPath}/report-issue.jsp" class="btn btn-primary">
                <i class="fas fa-plus"></i> New Request
            </a>
        </div>
    </div>
    <div class="app-content">
        <div class="card">
            <div class="card-header"><i class="fas fa-history"></i> All Your Requests</div>
            <div class="table-wrap">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Issue</th>
                            <th>Category</th>
                            <th>Status</th>
                            <th>Admin Response</th>
                            <th>Date</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try (Connection conn = DBConnection.getConnection()) {
                                PreparedStatement pst = conn.prepareStatement(
                                    "SELECT i.*, t.name as tech_name, t.phone_number as tech_phone " +
                                    "FROM issues i LEFT JOIN technicians t ON i.assigned_technician_id = t.id " +
                                    "WHERE i.user_id = ? ORDER BY i.created_at DESC");
                                pst.setInt(1, userId);
                                ResultSet rs = pst.executeQuery();
                                boolean hasIssues = false;
                                while (rs.next()) {
                                    hasIssues = true;
                                    int issueId = rs.getInt("id");
                                    String status = rs.getString("status");
                                    String statusClass = status.toLowerCase();
                                    if ("In Progress".equals(status)) statusClass = "progress";
                                    if ("Assigned".equals(status)) statusClass = "assigned";
                                    String imagePath = rs.getString("image_path");
                                    String remark = rs.getString("admin_remark");
                                    String techName = rs.getString("tech_name");
                                    String techPhone = rs.getString("tech_phone");
                                    int userRating = rs.getInt("user_rating");
                                    String userFeedback = rs.getString("user_feedback");
                        %>
                        <tr>
                            <td><span class="ref-id">#<%= String.format("%04d", issueId) %></span></td>
                            <td>
                                <div class="issue-row-title"><%= rs.getString("title") %></div>
                                <div class="issue-row-meta"><i class="fas fa-map-marker-alt"></i> <%= rs.getString("location") %></div>
                            </td>
                            <td><%= rs.getString("category") %></td>
                            <td><span class="status-badge status-<%= statusClass %>"><%= status %></span></td>
                            <td>
                                <% if (techName != null) { %>
                                <div style="font-size:.82rem;margin-bottom:.3rem;color:var(--brand-dark);font-weight:600;">
                                    <i class="fas fa-hard-hat" style="color:var(--brand-primary);"></i> <%= techName %>
                                </div>
                                <% } %>
                                <% if (remark != null && !remark.trim().isEmpty()) { %>
                                <div class="admin-remark-box"><%= remark %></div>
                                <% } else if (techName == null) { %>
                                <span class="text-muted">Awaiting response</span>
                                <% } %>
                                <% if ("Resolved".equals(status)) { 
                                       if (userRating == 0) { %>
                                    <div style="margin-top:.5rem;">
                                        <button type="button" class="btn btn-primary btn-sm" onclick="openRatingModal(<%= issueId %>)">
                                            <i class="fas fa-star"></i> Rate Resolution
                                        </button>
                                    </div>
                                    <% } else { %>
                                    <div style="margin-top:.5rem; font-size:.85rem; color:var(--brand-primary);">
                                        <i class="fas fa-star"></i> <%= userRating %>/5 - Rated
                                    </div>
                                    <% } 
                                   } %>
                            </td>
                            <td style="color:var(--text-secondary);"><%= rs.getTimestamp("created_at").toString().substring(0, 10) %></td>
                            <td>
                                <div style="display:flex; gap:0.5rem; flex-direction:column;">
                                    <% if (imagePath != null && !imagePath.trim().isEmpty()) { %>
                                    <button type="button" class="btn btn-outline btn-sm" onclick="openImageModal('<%= ctx %>/uploads/<%= imagePath %>')">
                                        <i class="fas fa-image"></i> View Photo
                                    </button>
                                    <% } %>
                                    <% if ("Pending".equals(status)) { %>
                                    <form id="deleteIssueForm_<%= issueId %>" action="<%= ctx %>/DeleteIssueServlet" method="post">
                                        <input type="hidden" name="issueId" value="<%= issueId %>">
                                        <button type="button" class="btn btn-outline btn-sm" style="color:#dc2626; border-color:#dc2626; width:100%;" onclick="openDeleteIssueModal(<%= issueId %>)">
                                            <i class="fas fa-trash-alt"></i> Delete
                                        </button>
                                    </form>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                        <%
                                }
                                if (!hasIssues) {
                        %>
                        <tr><td colspan="7">
                            <div class="empty-state">
                                <i class="fas fa-inbox"></i>
                                <h3>No history yet</h3>
                                <p>You haven't submitted any requests.</p>
                                <a href="${pageContext.request.contextPath}/report-issue.jsp" class="btn btn-primary">Submit First Request</a>
                            </div>
                        </td></tr>
                        <%
                                }
                            } catch (Exception e) {
                                out.println("<tr><td colspan='7'>Error: " + e.getMessage() + "</td></tr>");
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

<div class="modal-overlay" id="imageModal">
    <div class="modal-content modal-lg">
        <div class="modal-header">
            <h3><i class="fas fa-image" style="color:var(--brand-primary);margin-right:.5rem;"></i> Attached Photo</h3>
            <button type="button" class="modal-close" onclick="closeImageModal()"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
            <div class="image-preview-wrap">
                <img id="previewImage" src="" alt="Issue photo" onerror="this.style.display='none'; document.getElementById('imageError').style.display='block';">
                <p id="imageError" class="image-error-msg" style="display:none;"><i class="fas fa-exclamation-triangle"></i> Unable to load image.</p>
            </div>
        </div>
    </div>
</div>

</div>

<!-- Rating Modal -->
<div class="modal-overlay" id="ratingModal">
    <div class="modal-content">
        <div class="modal-header">
            <h3><i class="fas fa-star" style="color:#f59e0b;margin-right:.5rem;"></i> Rate Resolution</h3>
            <button type="button" class="modal-close" onclick="closeRatingModal()"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
            <form action="${pageContext.request.contextPath}/SubmitRatingServlet" method="post">
                <input type="hidden" id="ratingIssueId" name="issueId">
                <div class="form-group">
                    <label class="form-label">Rating (1 to 5 Stars)</label>
                    <div class="star-rating">
                        <input type="radio" id="star5" name="rating" value="5" required />
                        <label for="star5" title="5 stars"><i class="fas fa-star"></i></label>
                        <input type="radio" id="star4" name="rating" value="4" />
                        <label for="star4" title="4 stars"><i class="fas fa-star"></i></label>
                        <input type="radio" id="star3" name="rating" value="3" />
                        <label for="star3" title="3 stars"><i class="fas fa-star"></i></label>
                        <input type="radio" id="star2" name="rating" value="2" />
                        <label for="star2" title="2 stars"><i class="fas fa-star"></i></label>
                        <input type="radio" id="star1" name="rating" value="1" />
                        <label for="star1" title="1 star"><i class="fas fa-star"></i></label>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label">Feedback Comments (Optional)</label>
                    <textarea name="feedback" class="form-control" rows="3" placeholder="Tell us how the technician did..."></textarea>
                </div>
                <div class="form-actions" style="display:flex;justify-content:flex-end;gap:1rem;margin-top:1.5rem;">
                    <button type="button" class="btn btn-outline" onclick="closeRatingModal()">Cancel</button>
                    <button type="submit" class="btn btn-primary">Submit Rating</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Delete Issue Modal -->
<div class="modal-overlay" id="deleteIssueModal">
    <div class="modal-content">
        <div class="modal-header">
            <h3><i class="fas fa-exclamation-triangle" style="color:#dc2626;margin-right:.5rem;"></i> Delete Request</h3>
            <button type="button" class="modal-close" onclick="closeDeleteIssueModal()"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
            <p style="margin-bottom:1rem;color:var(--text-main);">
                Are you sure you want to delete this request? This action cannot be undone.
            </p>
            <div class="form-actions" style="display:flex;justify-content:flex-end;gap:1rem;margin-top:1.5rem;border:none;padding-top:0;">
                <button type="button" class="btn btn-outline" onclick="closeDeleteIssueModal()">Cancel</button>
                <button type="button" class="btn btn-primary" style="background:#dc2626;border-color:#dc2626;" onclick="confirmDeleteIssue()">Yes, delete</button>
            </div>
        </div>
    </div>
</div>

<script>
function openImageModal(url) {
    var img = document.getElementById('previewImage');
    var err = document.getElementById('imageError');
    img.style.display = 'block'; err.style.display = 'none';
    img.src = url;
    document.getElementById('imageModal').classList.add('open');
}
function closeImageModal() {
    document.getElementById('imageModal').classList.remove('open');
    document.getElementById('previewImage').src = '';
}
document.getElementById('imageModal').addEventListener('click', function(e) {
    if (e.target === this) closeImageModal();
});

function openRatingModal(issueId) {
    document.getElementById('ratingIssueId').value = issueId;
    document.getElementById('ratingModal').classList.add('open');
}
function closeRatingModal() {
    document.getElementById('ratingModal').classList.remove('open');
}
document.getElementById('ratingModal').addEventListener('click', function(e) {
    if (e.target === this) closeRatingModal();
});

var issueToDelete = null;
function openDeleteIssueModal(id) {
    issueToDelete = id;
    document.getElementById('deleteIssueModal').classList.add('open');
}
function closeDeleteIssueModal() {
    document.getElementById('deleteIssueModal').classList.remove('open');
}
function confirmDeleteIssue() {
    if (issueToDelete) {
        document.getElementById('deleteIssueForm_' + issueToDelete).submit();
    }
}
document.getElementById('deleteIssueModal').addEventListener('click', function(e) {
    if (e.target === this) closeDeleteIssueModal();
});
</script>
</body>
</html>
