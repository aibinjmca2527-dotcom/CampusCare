<%
    String navCtx = request.getContextPath();
    String navUri = request.getRequestURI();
    String navUserName = String.valueOf(session.getAttribute("userName"));
    String navProfileImage = (String) session.getAttribute("profileImage");
    String navInitial = (navUserName == null || navUserName.isEmpty() || "null".equals(navUserName))
            ? "U" : navUserName.substring(0, 1).toUpperCase();
    boolean overviewActive = navUri != null && navUri.endsWith("user-dashboard.jsp");
    boolean reportActive   = navUri != null && navUri.endsWith("report-issue.jsp");
    boolean historyActive  = navUri != null && navUri.endsWith("my-complaints.jsp");
    boolean profileActive  = navUri != null && navUri.endsWith("profile.jsp");
%>
<!-- Mobile top bar -->
<div class="mobile-topbar">
    <button class="mobile-menu-btn" id="sidebarToggle" aria-label="Toggle menu">
        <i class="fas fa-bars"></i>
    </button>
    <a href="<%= navCtx %>/user-dashboard.jsp" class="mobile-topbar-brand">
        <i class="fas fa-leaf"></i> CampusCare
    </a>
</div>
<div class="sidebar-overlay" id="sidebarOverlay"></div>

<aside class="app-sidebar" id="appSidebar">
    <a href="<%= navCtx %>/user-dashboard.jsp" class="sidebar-brand">
        <i class="fas fa-leaf"></i>
        <span>CampusCare</span>
    </a>
    <nav class="sidebar-nav">
        <div class="sidebar-section-label">Menu</div>
        <a href="<%= navCtx %>/user-dashboard.jsp" class="sidebar-link<%= overviewActive ? " active" : "" %>">
            <i class="fas fa-th-large"></i> Overview
        </a>
        <a href="<%= navCtx %>/report-issue.jsp" class="sidebar-link<%= reportActive ? " active" : "" %>">
            <i class="fas fa-plus-circle"></i> New Request
        </a>
        <a href="<%= navCtx %>/my-complaints.jsp" class="sidebar-link<%= historyActive ? " active" : "" %>">
            <i class="fas fa-history"></i> History
        </a>
        <div class="sidebar-section-label" style="margin-top:.5rem;">Account</div>
        <a href="<%= navCtx %>/profile.jsp" class="sidebar-link<%= profileActive ? " active" : "" %>">
            <i class="fas fa-user-circle"></i> Profile
        </a>
    </nav>
    <div class="sidebar-footer">
        <a href="<%= navCtx %>/profile.jsp" class="sidebar-user sidebar-user-link" title="Go to Profile">
            <% if (navProfileImage != null && !navProfileImage.trim().isEmpty()) { %>
            <img src="<%= navCtx %>/uploads/<%= navProfileImage %>" alt="Profile" class="sidebar-avatar-img">
            <% } else { %>
            <span class="sidebar-avatar"><%= navInitial %></span>
            <% } %>
            <div class="sidebar-user-info">
                <strong><%= navUserName %></strong>
                <span>Student / Staff</span>
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
