-- =============================================================================
-- CampusCare - Database Seed Data
-- Database: campuscare_db
-- Description: Initial test data including Admin, Students, Technicians, & Issues
-- =============================================================================

USE campuscare_db;

-- -----------------------------------------------------------------------------
-- Seed: users
-- Default Administrator Account:
-- Email:    admin@campuscare.com
-- Password: admin123
-- -----------------------------------------------------------------------------
INSERT INTO users (id, full_name, email, password, phone, role, department, profile_image, is_banned) VALUES
(1, 'System Administrator', 'admin@campuscare.com', 'admin123', '+91 98765 43210', 'admin', 'Facility Management', NULL, 0),
(2, 'Alex Rivera', 'alex.rivera@campuscare.com', 'user123', '+91 98765 00001', 'user', 'Computer Science', NULL, 0),
(3, 'Priya Sharma', 'priya.sharma@campuscare.com', 'user123', '+91 98765 00002', 'user', 'Electronics & Comm.', NULL, 0),
(4, 'Marcus Vance', 'marcus.vance@campuscare.com', 'user123', '+91 98765 00003', 'user', 'Mechanical Engineering', NULL, 0);

-- -----------------------------------------------------------------------------
-- Seed: technicians
-- Categorized campus maintenance staff available for assignment
-- -----------------------------------------------------------------------------
INSERT INTO technicians (id, name, category, phone_number, active) VALUES
(1, 'Robert Miller', 'Electrical', '+91 98765 11001', 1),
(2, 'Suresh Kumar', 'IT & Network', '+91 98765 11002', 1),
(3, 'David Clark', 'Plumbing', '+91 98765 11003', 1),
(4, 'Elena Rostova', 'Infrastructure', '+91 98765 11004', 1),
(5, 'Maria Santos', 'Cleanliness', '+91 98765 11005', 1),
(6, 'James Wilson', 'Other', '+91 98765 11006', 1),
(7, 'Vikram Singh', 'Electrical', '+91 98765 11007', 0); -- Inactive example

-- -----------------------------------------------------------------------------
-- Seed: issues
-- Demonstrating various lifecycle states (Pending, In Progress, Resolved, Rejected)
-- -----------------------------------------------------------------------------
INSERT INTO issues (id, user_id, title, category, description, location, image_path, status, admin_remark, assigned_technician_id, user_rating, user_feedback) VALUES
(1, 2, 'Flickering Overhead Tube Light', 'Electrical', 'Overhead fluorescent fixture directly above workstations in Lab 301 is continuously flickering, causing severe eye strain.', 'Computer Lab 301, Block B', NULL, 'Resolved', 'Replaced faulty ballast and installed new high-efficiency LED tube.', 1, 5, 'Resolved very swiftly! Excellent work.'),
(2, 2, 'Wi-Fi Access Point Dropping Packets', 'IT & Network', 'Students frequently disconnect during peak afternoon hours. High latency and packet drop noticed near reading pods.', 'Central Library, 2nd Floor East Wing', NULL, 'In Progress', 'Assigned technician to inspect cabling and configure dual-band load balancing.', 2, NULL, NULL),
(3, 3, 'Water Leakage Under Washbasin', 'Plumbing', 'Continuous drip from pipe connector beneath the sink resulting in standing water on restroom floor.', 'Academic Block A, 1st Floor Restroom', NULL, 'Pending', NULL, NULL, NULL, NULL),
(4, 4, 'Damaged Desk Hinge & Broken Bench', 'Infrastructure', 'Two study desks have sheared mounting screws and wobble significantly during use.', 'Mechanical Workshop, Lecture Hall 12', NULL, 'Rejected', 'Duplicate complaint filed earlier; consolidated into facility work order #108.', NULL, NULL, NULL);

-- Reset AUTO_INCREMENT counters to follow seeded IDs
ALTER TABLE users AUTO_INCREMENT = 10;
ALTER TABLE technicians AUTO_INCREMENT = 10;
ALTER TABLE issues AUTO_INCREMENT = 10;
