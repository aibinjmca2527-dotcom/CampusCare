<%
    String navCtx = request.getContextPath();
    String navUri = request.getRequestURI();
    String navUserName = String.valueOf(session.getAttribute("userName"));
    String navAdminProfileImage = (String) session.getAttribute("profileImage");
    String navInitial = (navUserName == null || navUserName.isEmpty() || "null".equals(navUserName))
            ? "A" : navUserName.substring(0, 1).toUpperCase();
    boolean issuesActive     = navUri != null && navUri.endsWith("admin-dashboard.jsp");
    boolean usersActive      = navUri != null && navUri.endsWith("admin-users.jsp");
    boolean techActive       = navUri != null && navUri.endsWith("admin-technicians.jsp");
    boolean profileActive    = navUri != null && navUri.endsWith("admin-profile.jsp");
%>
<!-- Mobile top bar -->
<div class="mobile-topbar">
    <button class="mobile-menu-btn" id="sidebarToggle" aria-label="Toggle menu">
        <i class="fas fa-bars"></i>
    </button>
    <a href="<%= navCtx %>/admin-dashboard.jsp" class="mobile-topbar-brand">
        <i class="fas fa-shield-alt"></i> CampusCare
    </a>
</div>
<div class="sidebar-overlay" id="sidebarOverlay"></div>

<aside class="app-sidebar" id="appSidebar">
    <a href="<%= navCtx %>/admin-dashboard.jsp" class="sidebar-brand">
        <i class="fas fa-shield-alt"></i>
        <span>CampusCare</span>
        <span class="admin-tag">Admin</span>
    </a>
    <nav class="sidebar-nav">
        <div class="sidebar-section-label">Management</div>
        <a href="<%= navCtx %>/admin-dashboard.jsp" class="sidebar-link<%= issuesActive ? " active" : "" %>">
            <i class="fas fa-tasks"></i> Issue Management
        </a>
        <a href="<%= navCtx %>/admin-users.jsp" class="sidebar-link<%= usersActive ? " active" : "" %>">
            <i class="fas fa-users-cog"></i> User Management
        </a>
        <a href="<%= navCtx %>/admin-technicians.jsp" class="sidebar-link<%= techActive ? " active" : "" %>">
            <i class="fas fa-hard-hat"></i> Technicians
        </a>
        <div class="sidebar-section-label" style="margin-top:.5rem;">Account</div>
        <a href="<%= navCtx %>/admin-profile.jsp" class="sidebar-link<%= profileActive ? " active" : "" %>">
            <i class="fas fa-user-circle"></i> My Profile
        </a>
    </nav>
    <div class="sidebar-footer">
        <a href="<%= navCtx %>/admin-profile.jsp" class="sidebar-user sidebar-user-link" title="Edit Profile">
            <% if (navAdminProfileImage != null && !navAdminProfileImage.trim().isEmpty()) { %>
            <img src="<%= navCtx %>/uploads/<%= navAdminProfileImage %>" alt="Profile" class="sidebar-avatar-img">
            <% } else { %>
            <span class="sidebar-avatar"><%= navInitial %></span>
            <% } %>
            <div class="sidebar-user-info">
                <strong><%= navUserName %></strong>
                <span>Administrator</span>
            </div>
            <i class="fas fa-chevron-right sidebar-user-arrow"></i>
        </a>
        <a href="<%= navCtx %>/LogoutServlet" class="sidebar-link sidebar-logout">
            <i class="fas fa-sign-out-alt"></i> Logout
        </a>
    </div>
</aside>

<script>
(function(){
    var btn = document.getElementById('sidebarToggle');
    var sidebar = document.getElementById('appSidebar');
    var overlay = document.getElementById('sidebarOverlay');
    if(btn && sidebar && overlay){
        btn.addEventListener('click',function(){
            sidebar.classList.toggle('open');
            overlay.classList.toggle('open');
        });
        overlay.addEventListener('click',function(){
            sidebar.classList.remove('open');
            overlay.classList.remove('open');
        });
    }
})();
</script>
