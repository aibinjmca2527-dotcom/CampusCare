<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.campuscare.db.DBConnection" %>
<%
    if (session.getAttribute("userId") == null || !"admin".equals(session.getAttribute("userRole"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    String userName = String.valueOf(session.getAttribute("userName"));
    String initial = userName.isEmpty() ? "A" : userName.substring(0, 1).toUpperCase();
    String ctx = request.getContextPath();

    int totalIssues = 0, pendingIssues = 0, progressIssues = 0, resolvedIssues = 0, rejectedIssues = 0;
    StringBuilder catLabels = new StringBuilder();
    StringBuilder catData = new StringBuilder();
    try (Connection conn = DBConnection.getConnection()) {
        Statement st = conn.createStatement();
        ResultSet rs = st.executeQuery("SELECT status, COUNT(*) as count FROM issues GROUP BY status");
        while (rs.next()) {
            int count = rs.getInt("count");
            totalIssues += count;
            String status = rs.getString("status");
            if ("Pending".equals(status)) pendingIssues += count;
            else if ("In Progress".equals(status)) progressIssues += count;
            else if ("Resolved".equals(status)) resolvedIssues += count;
            else if ("Rejected".equals(status)) rejectedIssues += count;
        }
        
        ResultSet rsCat = st.executeQuery("SELECT category, COUNT(*) as count FROM issues GROUP BY category");
        while (rsCat.next()) {
            catLabels.append("'").append(rsCat.getString("category").replace("'","\\'")).append("',");
            catData.append(rsCat.getInt("count")).append(",");
        }
    } catch (Exception e) { e.printStackTrace(); }
    int resolutionRate = totalIssues > 0 ? (resolvedIssues * 100 / totalIssues) : 0;
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
    <title>Issue Management – CampusCare Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
<div class="app-shell">
<jsp:include page="includes/admin-nav.jsp"/>
<div class="app-main">
<main class="app-page">
    <div class="page-header">
        <div>
            <h1>Issue Management</h1>
            <p>Review, update, and assign technicians to campus facility requests</p>
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

        <div class="metrics-strip">
            <div class="metric-pill">
                <div class="icon-wrap navy"><i class="fas fa-database"></i></div>
                <div><div class="label">Total</div><div class="value"><%= totalIssues %></div></div>
            </div>
            <div class="metric-pill">
                <div class="icon-wrap amber"><i class="fas fa-hourglass-half"></i></div>
                <div><div class="label">Pending</div><div class="value"><%= pendingIssues %></div></div>
            </div>
            <div class="metric-pill">
                <div class="icon-wrap blue"><i class="fas fa-tools"></i></div>
                <div><div class="label">In Progress</div><div class="value"><%= progressIssues %></div></div>
            </div>

            <div class="metric-pill">
                <div class="icon-wrap green"><i class="fas fa-check-double"></i></div>
                <div><div class="label">Resolved</div><div class="value"><%= resolvedIssues %></div></div>
            </div>
            <div class="metric-pill">
                <div class="icon-wrap green"><i class="fas fa-percentage"></i></div>
                <div><div class="label">Rate</div><div class="value"><%= resolutionRate %>%</div></div>
            </div>
        </div>

        <div class="content-grid-2" style="margin-bottom: 1.75rem; grid-template-columns: 1fr 1fr;">
            <div class="card">
                <div class="card-header"><i class="fas fa-chart-pie"></i> Status Distribution</div>
                <div class="card-body" style="height: 280px; display: flex; justify-content: center;">
                    <canvas id="statusChart"></canvas>
                </div>
            </div>
            <div class="card">
                <div class="card-header"><i class="fas fa-chart-bar"></i> Issues by Category</div>
                <div class="card-body" style="height: 280px; display: flex; justify-content: center;">
                    <canvas id="categoryChart"></canvas>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="card-header"><i class="fas fa-list-alt"></i> All Campus Issues</div>
            <div class="table-wrap">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Reporter</th>
                            <th>Issue</th>
                            <th>Category</th>
                            <th>Assigned To</th>
                            <th>Status</th>
                            <th>Date</th>
                            <th style="text-align:right;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try (Connection conn = DBConnection.getConnection()) {
                                String sql = "SELECT i.*, u.full_name, u.department, " +
                                    "t.name as tech_name, t.phone_number as tech_phone " +
                                    "FROM issues i " +
                                    "JOIN users u ON i.user_id = u.id " +
                                    "LEFT JOIN technicians t ON i.assigned_technician_id = t.id " +
                                    "ORDER BY FIELD(i.status,'Pending','Assigned','In Progress','Resolved','Rejected'), i.created_at DESC";
                                ResultSet rs = conn.createStatement().executeQuery(sql);
                                boolean hasData = false;
                                while (rs.next()) {
                                    hasData = true;
                                    int issueId = rs.getInt("id");
                                    String status = rs.getString("status");
                                    String statusClass = status.toLowerCase();
                                    if ("In Progress".equals(status)) statusClass = "progress";
                                    if ("Assigned".equals(status)) statusClass = "assigned";
                                    String imagePath = rs.getString("image_path");
                                    String remark = rs.getString("admin_remark");
                                    if (remark == null) remark = "";
                                    remark = remark.replace("\\","\\\\").replace("'","\\'").replace("\n"," ").replace("\r","");
                                    String techName = rs.getString("tech_name");
                                    String techPhone = rs.getString("tech_phone");
                                    String category = rs.getString("category");
                                    String catSafe = category.replace("\\","\\\\").replace("'","\\'");
                                    int assignedTechId = rs.getInt("assigned_technician_id");
                                    int userRating = rs.getInt("user_rating");
                                    String userFeedback = rs.getString("user_feedback");
                                    if (userFeedback == null) userFeedback = "";
                                    String safeFeedback = userFeedback.replace("\\","\\\\").replace("'","\\'").replace("\n"," ").replace("\r","");
                        %>
                        <tr>
                            <td><span class="ref-id">#<%= String.format("%04d", issueId) %></span></td>
                            <td>
                                <div style="font-weight:600;"><%= rs.getString("full_name") %></div>
                                <div class="issue-row-meta"><%= rs.getString("department") %></div>
                            </td>
                            <td>
                                <div class="issue-row-title"><%= rs.getString("title") %></div>
                                <div class="issue-row-meta"><i class="fas fa-map-marker-alt"></i> <%= rs.getString("location") %></div>
                            </td>
                            <td><%= category %></td>
                            <td>
                                <% if (techName != null) { %>
                                <div style="font-weight:600;font-size:.85rem;"><%= techName %></div>
                                <div class="issue-row-meta">
                                    <a href="tel:<%= techPhone %>" style="color:var(--brand-primary);">
                                        <i class="fas fa-phone" style="font-size:.75rem;"></i> <%= techPhone %>
                                    </a>
                                </div>
                                <% } else { %>
                                <span class="text-muted">—</span>
                                <% } %>
                            </td>
                            <td><span class="status-badge status-<%= statusClass %>"><%= status %></span></td>
                            <td style="color:var(--text-secondary)"><%= rs.getTimestamp("created_at").toString().substring(0,10) %></td>
                            <td style="text-align:right;">
                                <div style="display:flex;justify-content:flex-end;gap:.4rem;">
                                    <% if (imagePath != null && !imagePath.trim().isEmpty()) { %>
                                    <button type="button" class="btn btn-outline btn-sm" onclick="event.preventDefault(); event.stopPropagation(); openImageModal('<%= ctx %>/uploads/<%= imagePath %>')" title="View photo">
                                        <i class="fas fa-image"></i>
                                    </button>
                                    <% } %>
                                    
                                    <% if ("Resolved".equals(status)) { %>
                                        <button type="button" class="btn btn-outline btn-sm" style="color:#16a34a; border-color:#16a34a;" onclick="event.preventDefault(); event.stopPropagation(); viewFeedback(<%= userRating %>, '<%= safeFeedback %>')">
                                            <i class="fas fa-star"></i> Feedback
                                        </button>
                                    <% } else { %>
                                        <button type="button" class="btn btn-primary btn-sm"
                                            onclick="openUpdateModal(<%= issueId %>, '<%= status %>', '<%= remark %>', '<%= catSafe %>', <%= assignedTechId %>)">
                                            <i class="fas fa-edit"></i> Update
                                        </button>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                        <%
                                }
                                if (!hasData) {
                        %>
                        <tr><td colspan="8">
                            <div class="empty-state">
                                <i class="fas fa-check-circle"></i>
                                <h3>No issues in the system</h3>
                                <p>All clear — no facility requests to manage.</p>
                            </div>
                        </td></tr>
                        <%
                                }
                            } catch (Exception e) {
                                out.println("<tr><td colspan='8'>Error: " + e.getMessage() + "</td></tr>");
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>
</div>

<!-- Update Issue Modal -->
<div class="modal-overlay" id="updateModal">
    <div class="modal-content modal-lg">
        <div class="modal-header">
            <h3><i class="fas fa-edit" style="color:var(--brand-primary);margin-right:.5rem;"></i> Update Issue</h3>
            <button type="button" class="modal-close" onclick="closeUpdateModal()"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
            <form id="updateIssueForm" action="${pageContext.request.contextPath}/UpdateStatusServlet" method="post">
                <input type="hidden" name="issueId" id="modalIssueId">
                <input type="hidden" name="assignedTechnicianId" id="modalTechId">
                <input type="hidden" name="banUser" id="banUserInput" value="false">
                
                <div class="form-group" style="margin-bottom:1.5rem;">
                <!-- Technician Auto-Suggest -->
                <div id="techSuggestArea" style="display:none;" class="tech-suggestion-area">
                    <div class="label-sm"><i class="fas fa-hard-hat" style="color:var(--brand-primary);"></i> Suggested Technicians for this category</div>
                    <div class="tech-chips" id="techChips"></div>
                </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Status</label>
                    <select name="status" id="modalStatus" class="form-control" required>
                        <option value="Pending">Pending</option>
                        <option value="In Progress">In Progress</option>
                        <option value="Resolved">Resolved</option>
                        <option value="Rejected">Rejected</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Resolution Notes</label>
                    <textarea name="adminRemark" id="modalRemark" class="form-control" rows="4" placeholder="Notes visible to the reporter..."></textarea>
                </div>
                <div class="form-actions" style="border:none;padding-top:0;margin-top:0;">
                    <button type="button" class="btn btn-outline" onclick="closeUpdateModal()">Cancel</button>
                    <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Save Changes</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Image Modal -->
<div class="modal-overlay" id="imageModal">
    <div class="modal-content modal-lg">
        <div class="modal-header">
            <h3><i class="fas fa-image" style="color:var(--brand-primary);margin-right:.5rem;"></i> Photo Evidence</h3>
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

<!-- Custom Feedback Modal -->
<div class="modal-overlay" id="customFeedbackModal">
    <div class="modal-content">
        <div class="modal-header">
            <h3><i class="fas fa-star" style="color:#f59e0b;margin-right:.5rem;"></i> User Feedback</h3>
            <button type="button" class="modal-close" onclick="closeCustomFeedbackModal()"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
            <div style="font-weight:600; color:#16a34a; font-size:1.2rem; margin-bottom:1rem;">
                <i class="fas fa-star"></i> User Rating: <span id="feedbackModalRating"></span> / 5 Stars
            </div>
            <div class="form-group">
                <label class="form-label">User Comments</label>
                <div id="feedbackModalText" style="padding:1rem; background:#f9fafb; border:1px solid var(--border-color); border-radius:var(--radius-sm); font-style:italic; color:var(--text-main);"></div>
            </div>
            <div class="form-actions" style="border:none;padding-top:0;margin-top:1.5rem; justify-content:flex-end;">
                <button type="button" class="btn btn-outline" onclick="closeCustomFeedbackModal()">Close</button>
            </div>
        </div>
    </div>
</div>

<!-- Custom Ban Confirmation Modal -->
<div class="modal-overlay" id="customBanModal">
    <div class="modal-content">
        <div class="modal-header">
            <h3><i class="fas fa-exclamation-triangle" style="color:#dc2626;margin-right:.5rem;"></i> Reject Request</h3>
            <button type="button" class="modal-close" onclick="closeCustomBanModal()"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
            <p style="margin-bottom:1rem;color:var(--text-main);">
                You are about to reject this request. Do you also want to permanently ban this user from submitting future requests to CampusCare?
            </p>
            <div class="form-actions" style="border:none;padding-top:0;margin-top:1.5rem; display:flex; gap:1rem; justify-content:flex-end;">
                <button type="button" class="btn btn-outline" onclick="confirmBan(false)">No, just reject</button>
                <button type="button" class="btn btn-primary" style="background:#dc2626; border-color:#dc2626;" onclick="confirmBan(true)">Yes, reject & ban</button>
            </div>
        </div>
    </div>
</div>

</div>

<script>
var CTX = '<%= ctx %>';
var currentCategory = '';
var selectedTechId = 0;

function viewFeedback(rating, feedback) {
    if (rating === 0) {
        document.getElementById('feedbackModalRating').innerText = "0";
        document.getElementById('feedbackModalText').innerText = "The user has not provided feedback yet.";
    } else {
        document.getElementById('feedbackModalRating').innerText = rating;
        document.getElementById('feedbackModalText').innerText = feedback || "No written feedback provided.";
    }
    document.getElementById('customFeedbackModal').classList.add('open');
}
function closeCustomFeedbackModal() {
    document.getElementById('customFeedbackModal').classList.remove('open');
}

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

function openUpdateModal(id, status, remark, category, currentTechId) {
    document.getElementById('modalIssueId').value = id;
    document.getElementById('modalStatus').value = status;
    document.getElementById('modalRemark').value = remark || '';
    document.getElementById('modalTechId').value = currentTechId || '';
    selectedTechId = currentTechId || 0;
    currentCategory = category;
    document.getElementById('updateModal').classList.add('open');
    loadTechnicians(category, currentTechId);
}
function closeUpdateModal() {
    document.getElementById('updateModal').classList.remove('open');
}
function loadTechnicians(category, currentTechId) {
    if (!category) return;
    fetch(CTX + '/TechnicianServlet?category=' + encodeURIComponent(category))
        .then(function(r){ return r.json(); })
        .then(function(data) {
            var area = document.getElementById('techSuggestArea');
            var chips = document.getElementById('techChips');
            chips.innerHTML = '';
            if (data.length === 0) {
                area.style.display = 'none';
                return;
            }
            area.style.display = 'block';
            data.forEach(function(t) {
                var chip = document.createElement('div');
                chip.className = 'tech-chip' + (t.id == currentTechId ? ' selected' : '');
                chip.style.padding = '0';
                chip.style.overflow = 'hidden';
                chip.innerHTML = '<div class="chip-main" style="padding: 0.4rem 0.75rem; flex-grow: 1; display: flex; align-items: center; gap: 0.4rem;">' +
                    '<i class="fas fa-hard-hat"></i><strong>' + t.name + '</strong></div>' +
                    '<a href="tel:' + t.phone + '" onclick="event.stopPropagation();" style="padding: 0.4rem 0.75rem; border-left: 1px solid rgba(0,0,0,0.1); background: rgba(0,0,0,0.03); color: var(--brand-primary); text-decoration: none; display: flex; align-items: center; gap: 0.3rem;">' +
                    '<i class="fas fa-phone" style="font-size:.75rem;"></i> ' + t.phone + '</a>';
                chip.addEventListener('click', function() {
                    if (chip.classList.contains('selected')) {
                        chip.classList.remove('selected');
                        document.getElementById('modalTechId').value = '';
                        selectedTechId = 0;
                    } else {
                        document.querySelectorAll('.tech-chip').forEach(function(c){ c.classList.remove('selected'); });
                        chip.classList.add('selected');
                        document.getElementById('modalTechId').value = t.id;
                        selectedTechId = t.id;
                    }
                });
                chips.appendChild(chip);
            });
        }).catch(function(){
            document.getElementById('techSuggestArea').style.display = 'none';
        });
}
document.querySelectorAll('.modal-overlay').forEach(function(el) {
    el.addEventListener('click', function(e) {
        if (e.target === el) el.classList.remove('open');
    });
});

// Chart.js Init
document.addEventListener('DOMContentLoaded', function() {
    var ctxStatus = document.getElementById('statusChart');
    if (ctxStatus) {
        new Chart(ctxStatus, {
            type: 'doughnut',
            data: {
                labels: ['Pending', 'In Progress', 'Resolved', 'Rejected'],
                datasets: [{
                    data: [<%= pendingIssues %>, <%= progressIssues %>, <%= resolvedIssues %>, <%= rejectedIssues %>],
                    backgroundColor: ['#fef3c7', '#dbeafe', '#dcfce7', '#fee2e2'],
                    borderColor: ['#b45309', '#1e40af', '#15803d', '#b91c1c'],
                    borderWidth: 1
                }]
            },
            options: { responsive: true, maintainAspectRatio: false }
        });
    }

    var ctxCategory = document.getElementById('categoryChart');
    if (ctxCategory) {
        new Chart(ctxCategory, {
            type: 'bar',
            data: {
                labels: [<%= catLabels.toString() %>],
                datasets: [{
                    label: 'Issues Reported',
                    data: [<%= catData.toString() %>],
                    backgroundColor: 'rgba(22, 163, 74, 0.2)',
                    borderColor: '#16a34a',
                    borderWidth: 1
                }]
            },
            options: { 
                responsive: true, maintainAspectRatio: false,
                scales: { y: { beginAtZero: true, ticks: { stepSize: 1 } } }
            }
        });
    }
});

document.getElementById('updateIssueForm').addEventListener('submit', function(e) {
    var status = document.getElementById('modalStatus').value;
    
    // If the modal hasn't been handled yet and it's rejected, intercept.
    if (status === 'Rejected' && !window.banModalConfirmed) {
        e.preventDefault(); // Stop form submission
        document.getElementById('customBanModal').classList.add('open');
    }
});

function closeCustomBanModal() {
    document.getElementById('customBanModal').classList.remove('open');
}

function confirmBan(banUserChoice) {
    closeCustomBanModal();
    document.getElementById('banUserInput').value = banUserChoice ? "true" : "false";
    window.banModalConfirmed = true; // Flag that user has made a choice
    document.getElementById('updateIssueForm').submit(); // Resubmit the form bypassing the listener
}
</script>
</body>
</html>
