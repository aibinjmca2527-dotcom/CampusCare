<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.campuscare.db.DBConnection" %>
<%
    int resolvedCount = 0, totalIssues = 0, pendingCount = 0, inProgressCount = 0, registeredUsers = 0;
    try (Connection conn = DBConnection.getConnection()) {
        if (conn != null) {
            Statement st = conn.createStatement();
            ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM issues WHERE status = 'Resolved'");
            if (rs.next()) resolvedCount = rs.getInt(1);
            rs = st.executeQuery("SELECT COUNT(*) FROM issues");
            if (rs.next()) totalIssues = rs.getInt(1);
            rs = st.executeQuery("SELECT COUNT(*) FROM issues WHERE status = 'Pending'");
            if (rs.next()) pendingCount = rs.getInt(1);
            rs = st.executeQuery("SELECT COUNT(*) FROM issues WHERE status = 'In Progress'");
            if (rs.next()) inProgressCount = rs.getInt(1);
            rs = st.executeQuery("SELECT COUNT(*) FROM users WHERE role = 'user'");
            if (rs.next()) registeredUsers = rs.getInt(1);
        }
    } catch (Exception e) { e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CampusCare – Smart Campus Issue Reporting</title>
    <meta name="description" content="CampusCare connects students and staff with facility teams. Report campus issues, track status in real time.">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body class="index-page">

<header class="site-header">
    <div class="site-header-inner">
        <a href="index.jsp" class="site-brand">
            <span class="site-brand-icon"><i class="fas fa-leaf"></i></span>
            CampusCare
        </a>
        <ul class="site-nav">
            <% if (session.getAttribute("userId") != null) { %>
                <% if ("admin".equals(session.getAttribute("userRole"))) { %>
                    <li><a href="admin-dashboard.jsp">Dashboard</a></li>
                <% } else { %>
                    <li><a href="user-dashboard.jsp">Dashboard</a></li>
                <% } %>
                <li><a href="LogoutServlet">Logout</a></li>
            <% } else { %>
                <li><a href="login.jsp">Login</a></li>
                <li><a href="register.jsp" class="btn btn-nav">Get Started</a></li>
            <% } %>
        </ul>
    </div>
</header>

<section class="landing-hero">
    <div class="landing-hero-inner">
        <div>
            <div class="landing-badge"><i class="fas fa-leaf"></i> Smart Campus Issue Platform</div>
            <h1>Report Campus Issues <span>Professionally</span></h1>
            <p>CampusCare connects students and staff with facility teams. Submit issues with photos, track status in real time, and keep your campus safe and functional.</p>
            <div class="landing-actions">
                <a href="register.jsp" class="btn btn-primary"><i class="fas fa-user-plus"></i> Create Free Account</a>
                <a href="login.jsp" class="btn btn-outline" style="color:white;border-color:rgba(255,255,255,.4);">
                    <i class="fas fa-sign-in-alt"></i> Sign In
                </a>
            </div>
        </div>
        <div class="landing-hero-card">
            <h3><i class="fas fa-chart-line" style="color:var(--brand-primary);margin-right:.5rem;"></i> Live Platform Statistics</h3>
            <p style="font-size:.85rem;color:var(--text-secondary);margin-bottom:1.25rem;">Real-time counts from the campus database</p>
            <div class="landing-stat-row">
                <div class="landing-stat"><div class="num"><%= resolvedCount %></div><div class="lbl">Issues Resolved</div></div>
                <div class="landing-stat"><div class="num"><%= totalIssues %></div><div class="lbl">Total Reported</div></div>
                <div class="landing-stat"><div class="num"><%= pendingCount %></div><div class="lbl">Pending</div></div>
                <div class="landing-stat"><div class="num"><%= inProgressCount %></div><div class="lbl">In Progress</div></div>
            </div>
            <div class="landing-stat-row" style="margin-top:1rem;">
                <div class="landing-stat" style="grid-column:span 2;">
                    <div class="num"><%= registeredUsers %></div>
                    <div class="lbl">Registered Campus Users</div>
                </div>
            </div>
        </div>
    </div>
</section>

<section class="section section-alt" style="background:var(--bg-body); border-top:1px solid var(--border-color);">
    <div class="section-header">
        <span class="section-tag">Tutorial</span>
        <h2>See How CampusCare Works</h2>
        <p>A quick 1-minute walkthrough of reporting and resolving issues.</p>
    </div>
    <div style="max-width:800px; margin: 0 auto; text-align:center; padding: 0 1rem;">
        <style>
            .video-wrapper { position: relative; border-radius: 12px; overflow: hidden; box-shadow: 0 10px 30px rgba(0,0,0,0.1); background: #000; }
            .video-overlay { position: absolute; top: 0; left: 0; width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: rgba(0,0,0,0.2); cursor: pointer; transition: all 0.3s ease; }
            .video-overlay:hover { background: rgba(0,0,0,0.1); }
            .play-btn-custom { width: 80px; height: 80px; background: var(--brand-primary); border-radius: 50%; display: flex; align-items: center; justify-content: center; box-shadow: 0 8px 25px rgba(22,163,74,0.4); color: white; font-size: 2.2rem; padding-left: 6px; transition: transform 0.3s ease; }
            .video-overlay:hover .play-btn-custom { transform: scale(1.1); background: var(--brand-dark); }
        </style>
        <div class="video-wrapper">
            <video id="tutorialVideo" width="100%" preload="none" poster="${pageContext.request.contextPath}/images/video-thumbnail.jpg" style="display:block; width:100%;">
                <source src="${pageContext.request.contextPath}/videos/tutorial.mp4" type="video/mp4">
                Your browser does not support the video tag.
            </video>
            <div id="videoOverlay" class="video-overlay" onclick="playTutorialVideo()">
                <div class="play-btn-custom">
                    <i class="fas fa-play"></i>
                </div>
            </div>
        </div>
        <script>
            function playTutorialVideo() {
                var video = document.getElementById('tutorialVideo');
                var overlay = document.getElementById('videoOverlay');
                video.controls = true;
                video.play();
                overlay.style.display = 'none';
            }
        </script>
    </div>
</section>

<section class="section">
    <div class="section-header">
        <span class="section-tag">Features</span>
        <h2>Built for Modern Campuses</h2>
        <p>Everything you need to report, manage, and resolve facility issues in one professional portal.</p>
    </div>
    <div class="features-grid">
        <div class="feature-card">
            <div class="feature-icon green"><i class="fas fa-clipboard-list"></i></div>
            <h3>Easy Issue Reporting</h3>
            <p>Submit issues with description, location, and photo evidence in under a minute.</p>
        </div>
        <div class="feature-card">
            <div class="feature-icon teal"><i class="fas fa-bell"></i></div>
            <h3>Real-Time Tracking</h3>
            <p>Monitor status from Pending through In Progress to Resolved with clear indicators.</p>
        </div>
        <div class="feature-card">
            <div class="feature-icon blue"><i class="fas fa-user-shield"></i></div>
            <h3>Admin Console</h3>
            <p>Administrators review requests, update status, and add official resolution notes.</p>
        </div>
        <div class="feature-card">
            <div class="feature-icon amber"><i class="fas fa-camera"></i></div>
            <h3>Photo Evidence</h3>
            <p>Attach images so teams understand the problem before dispatching help.</p>
        </div>
        <div class="feature-card">
            <div class="feature-icon purple"><i class="fas fa-hard-hat"></i></div>
            <h3>Technician Assignment</h3>
            <p>Admins can auto-assign qualified technicians to issues by category with one click.</p>
        </div>
        <div class="feature-card">
            <div class="feature-icon teal"><i class="fas fa-chart-pie"></i></div>
            <h3>Issue Analytics</h3>
            <p>View totals, pending, in-progress, and resolved counts at a glance.</p>
        </div>
    </div>
</section>

<section class="section section-alt" style="background:var(--bg-body);">
    <div class="section-header">
        <span class="section-tag">How It Works</span>
        <h2>Three Simple Steps</h2>
        <p>From registration to resolution — a clear workflow everyone can follow.</p>
    </div>
    <div class="steps-row">
        <div class="step-card">
            <div class="step-num">1</div>
            <i class="fas fa-user-plus" style="font-size:2rem;color:var(--text-muted);margin-bottom:1rem;display:block;"></i>
            <h3>Register</h3>
            <p>Create your account with your college email and department.</p>
        </div>
        <div class="step-card">
            <div class="step-num">2</div>
            <i class="fas fa-edit" style="font-size:2rem;color:var(--text-muted);margin-bottom:1rem;display:block;"></i>
            <h3>Report</h3>
            <p>Describe the issue, set location and category, and attach a photo.</p>
        </div>
        <div class="step-card">
            <div class="step-num">3</div>
            <i class="fas fa-tasks" style="font-size:2rem;color:var(--text-muted);margin-bottom:1rem;display:block;"></i>
            <h3>Track</h3>
            <p>Follow progress and read admin responses until the issue is resolved.</p>
        </div>
    </div>
</section>

<footer class="site-footer">
    <p><strong>CampusCare</strong> – Smart Issue Reporting System &nbsp;|&nbsp; MCA Project &copy; 2026</p>
</footer>

</body>
</html>
