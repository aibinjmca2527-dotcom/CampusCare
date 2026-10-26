-- =============================================================================
-- CampusCare - Complete Database Setup (Schema + Seed Data)
-- Database: campuscare_db
-- Version: 1.0.0
-- =============================================================================

CREATE DATABASE IF NOT EXISTS campuscare_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE campuscare_db;

-- -----------------------------------------------------------------------------
-- Clean up existing tables
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS issues;
DROP TABLE IF EXISTS technicians;
DROP TABLE IF EXISTS users;

-- -----------------------------------------------------------------------------
-- 1. Table: users
-- -----------------------------------------------------------------------------
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(25) DEFAULT NULL,
    role ENUM('user', 'admin') NOT NULL DEFAULT 'user',
    department VARCHAR(100) DEFAULT NULL,
    profile_image VARCHAR(255) DEFAULT NULL,
    is_banned TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_email (email),
    INDEX idx_user_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 2. Table: technicians
-- -----------------------------------------------------------------------------
CREATE TABLE technicians (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    category VARCHAR(100) NOT NULL,
    phone_number VARCHAR(25) NOT NULL,
    active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_tech_category (category),
    INDEX idx_tech_active (active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 3. Table: issues
-- -----------------------------------------------------------------------------
CREATE TABLE issues (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    description TEXT DEFAULT NULL,
    location VARCHAR(255) NOT NULL,
    image_path VARCHAR(255) DEFAULT NULL,
    status ENUM('Pending', 'Assigned', 'In Progress', 'Resolved', 'Rejected') NOT NULL DEFAULT 'Pending',
    admin_remark TEXT DEFAULT NULL,
    assigned_technician_id INT DEFAULT NULL,
    user_rating INT DEFAULT NULL,
    user_feedback TEXT DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_issues_user FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_issues_technician FOREIGN KEY (assigned_technician_id) 
        REFERENCES technicians(id) ON DELETE SET NULL,
    INDEX idx_issues_user (user_id),
    INDEX idx_issues_status (status),
    INDEX idx_issues_category (category),
    INDEX idx_issues_technician (assigned_technician_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- SEED DATA
-- =============================================================================

-- Seed Users (Default Administrator & Students)
INSERT INTO users (id, full_name, email, password, phone, role, department, profile_image, is_banned) VALUES
(1, 'System Administrator', 'admin@campuscare.com', 'admin123', '+91 98765 43210', 'admin', 'Facility Management', NULL, 0),
(2, 'Alex Rivera', 'alex.rivera@campuscare.com', 'user123', '+91 98765 00001', 'user', 'Computer Science', NULL, 0),
(3, 'Priya Sharma', 'priya.sharma@campuscare.com', 'user123', '+91 98765 00002', 'user', 'Electronics & Comm.', NULL, 0),
(4, 'Marcus Vance', 'marcus.vance@campuscare.com', 'user123', '+91 98765 00003', 'user', 'Mechanical Engineering', NULL, 0);

-- Seed Maintenance Technicians
INSERT INTO technicians (id, name, category, phone_number, active) VALUES
(1, 'Robert Miller', 'Electrical', '+91 98765 11001', 1),
(2, 'Suresh Kumar', 'IT & Network', '+91 98765 11002', 1),
(3, 'David Clark', 'Plumbing', '+91 98765 11003', 1),
(4, 'Elena Rostova', 'Infrastructure', '+91 98765 11004', 1),
(5, 'Maria Santos', 'Cleanliness', '+91 98765 11005', 1),
(6, 'James Wilson', 'Other', '+91 98765 11006', 1),
(7, 'Vikram Singh', 'Electrical', '+91 98765 11007', 0);

-- Seed Initial Issues
INSERT INTO issues (id, user_id, title, category, description, location, image_path, status, admin_remark, assigned_technician_id, user_rating, user_feedback) VALUES
(1, 2, 'Flickering Overhead Tube Light', 'Electrical', 'Overhead fluorescent fixture directly above workstations in Lab 301 is continuously flickering, causing severe eye strain.', 'Computer Lab 301, Block B', NULL, 'Resolved', 'Replaced faulty ballast and installed new high-efficiency LED tube.', 1, 5, 'Resolved very swiftly! Excellent work.'),
(2, 2, 'Wi-Fi Access Point Dropping Packets', 'IT & Network', 'Students frequently disconnect during peak afternoon hours. High latency and packet drop noticed near reading pods.', 'Central Library, 2nd Floor East Wing', NULL, 'In Progress', 'Assigned technician to inspect cabling and configure dual-band load balancing.', 2, NULL, NULL),
(3, 3, 'Water Leakage Under Washbasin', 'Plumbing', 'Continuous drip from pipe connector beneath the sink resulting in standing water on restroom floor.', 'Academic Block A, 1st Floor Restroom', NULL, 'Pending', NULL, NULL, NULL, NULL),
(4, 4, 'Damaged Desk Hinge & Broken Bench', 'Infrastructure', 'Two study desks have sheared mounting screws and wobble significantly during use.', 'Mechanical Workshop, Lecture Hall 12', NULL, 'Rejected', 'Duplicate complaint filed earlier; consolidated into facility work order #108.', NULL, NULL, NULL);

ALTER TABLE users AUTO_INCREMENT = 10;
ALTER TABLE technicians AUTO_INCREMENT = 10;
ALTER TABLE issues AUTO_INCREMENT = 10;
