-- =============================================================================
-- CampusCare - Database Schema Definition
-- Database: campuscare_db
-- Version: 1.0.0
-- =============================================================================

CREATE DATABASE IF NOT EXISTS campuscare_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE campuscare_db;

-- -----------------------------------------------------------------------------
-- Clean up existing tables (ordered to respect foreign key constraints)
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS issues;
DROP TABLE IF EXISTS technicians;
DROP TABLE IF EXISTS users;

-- -----------------------------------------------------------------------------
-- Table: users
-- Stores registered students, faculty members, and administrators.
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
-- Table: technicians
-- Stores on-campus maintenance personnel categorized by trade.
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
-- Table: issues
-- Stores student and faculty issue reports, tracking status, technician assignments,
-- administrator remarks, and resolution satisfaction ratings.
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
