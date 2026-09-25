package com.campuscare.model;

public class Issue {
    private int id;
    private int userId;
    private String title;
    private String category;
    private String description;
    private String location;
    private String imagePath;
    private String status;
    private String adminRemark;
    private Integer assignedTechnicianId;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
    public String getImagePath() { return imagePath; }
    public void setImagePath(String imagePath) { this.imagePath = imagePath; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getAdminRemark() { return adminRemark; }
    public void setAdminRemark(String adminRemark) { this.adminRemark = adminRemark; }
    public Integer getAssignedTechnicianId() { return assignedTechnicianId; }
    public void setAssignedTechnicianId(Integer assignedTechnicianId) { this.assignedTechnicianId = assignedTechnicianId; }
}
