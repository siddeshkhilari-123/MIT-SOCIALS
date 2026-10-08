-- ====================================================================
-- MIT Socials - Complete Database Initialization Script
-- Database Name: mit_socials
-- Purpose: Complete Schema for MIT Socials College Social Network
-- Supported Roles: STUDENT, CLUB_ADMIN, COLLEGE_ADMIN
-- Leaderboard Categories: OVERALL, SPORTS, CULTURAL, PROFESSIONAL, CREATOR, CONTRIBUTOR
-- ====================================================================

CREATE DATABASE IF NOT EXISTS mit_socials;
USE mit_socials;

-- --------------------------------------------------------------------
-- Drop existing tables in reverse dependency order to prevent FK errors
-- --------------------------------------------------------------------
DROP TABLE IF EXISTS leaderboard;
DROP TABLE IF EXISTS reports;
DROP TABLE IF EXISTS user_badges;
DROP TABLE IF EXISTS badges;
DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS messages;
DROP TABLE IF EXISTS community_posts;
DROP TABLE IF EXISTS community_members;
DROP TABLE IF EXISTS communities;
DROP TABLE IF EXISTS club_posts;
DROP TABLE IF EXISTS club_members;
DROP TABLE IF EXISTS clubs;
DROP TABLE IF EXISTS event_registrations;
DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS cultural_activities;
DROP TABLE IF EXISTS sports;
DROP TABLE IF EXISTS achievements;
DROP TABLE IF EXISTS internships;
DROP TABLE IF EXISTS projects;
DROP TABLE IF EXISTS skills;
DROP TABLE IF EXISTS certificates;
DROP TABLE IF EXISTS mentions;
DROP TABLE IF EXISTS shares;
DROP TABLE IF EXISTS bookmarks;
DROP TABLE IF EXISTS followers;
DROP TABLE IF EXISTS likes;
DROP TABLE IF EXISTS comments;
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS profiles;
DROP TABLE IF EXISTS users;

-- --------------------------------------------------------------------
-- 1. Table: users
-- Roles supported: STUDENT, CLUB_ADMIN, COLLEGE_ADMIN
-- --------------------------------------------------------------------
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    college_email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    student_id VARCHAR(100) NOT NULL UNIQUE,
    full_name VARCHAR(255) NOT NULL,
    branch VARCHAR(100) NOT NULL,
    year VARCHAR(50) NOT NULL,
    division VARCHAR(50) NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'STUDENT',
    points INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_users_college_email (college_email),
    INDEX idx_users_student_id (student_id),
    INDEX idx_users_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 2. Table: profiles
-- --------------------------------------------------------------------
CREATE TABLE profiles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    profile_photo VARCHAR(500) DEFAULT NULL,
    cover_photo VARCHAR(500) DEFAULT NULL,
    bio TEXT DEFAULT NULL,
    branch VARCHAR(100) DEFAULT NULL,
    year VARCHAR(50) DEFAULT NULL,
    division VARCHAR(50) DEFAULT NULL,
    linkedin_url VARCHAR(255) DEFAULT NULL,
    github_url VARCHAR(255) DEFAULT NULL,
    website_url VARCHAR(255) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_profiles_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_profiles_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 3. Table: posts
-- Post Types supported: TEXT, IMAGE, VIDEO
-- --------------------------------------------------------------------
CREATE TABLE posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    caption TEXT DEFAULT NULL,
    post_type VARCHAR(50) NOT NULL DEFAULT 'TEXT',
    media_url VARCHAR(500) DEFAULT NULL,
    likes_count INT DEFAULT 0,
    comments_count INT DEFAULT 0,
    shares_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_posts_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_posts_user_id (user_id),
    INDEX idx_posts_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 4. Table: comments
-- --------------------------------------------------------------------
CREATE TABLE comments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    comment_text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_comments_post_id FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    CONSTRAINT fk_comments_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_comments_post_id (post_id),
    INDEX idx_comments_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 5. Table: likes
-- --------------------------------------------------------------------
CREATE TABLE likes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_likes_user_post (user_id, post_id),
    CONSTRAINT fk_likes_post_id FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    CONSTRAINT fk_likes_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_likes_post_id (post_id),
    INDEX idx_likes_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 6. Table: followers
-- --------------------------------------------------------------------
CREATE TABLE followers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    follower_id INT NOT NULL,
    following_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_followers_pair (follower_id, following_id),
    CONSTRAINT fk_followers_follower FOREIGN KEY (follower_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_followers_following FOREIGN KEY (following_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_followers_follower (follower_id),
    INDEX idx_followers_following (following_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 7. Table: bookmarks
-- --------------------------------------------------------------------
CREATE TABLE bookmarks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    post_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_bookmarks_user_post (user_id, post_id),
    CONSTRAINT fk_bookmarks_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_bookmarks_post_id FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    INDEX idx_bookmarks_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 8. Table: shares
-- --------------------------------------------------------------------
CREATE TABLE shares (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    post_id INT NOT NULL,
    shared_to_platform VARCHAR(100) DEFAULT 'INTERNAL',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_shares_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_shares_post_id FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    INDEX idx_shares_user_id (user_id),
    INDEX idx_shares_post_id (post_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 9. Table: mentions
-- --------------------------------------------------------------------
CREATE TABLE mentions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    mentioned_user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_mentions_post_id FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    CONSTRAINT fk_mentions_user_id FOREIGN KEY (mentioned_user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_mentions_post_id (post_id),
    INDEX idx_mentions_user_id (mentioned_user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 10. Table: certificates
-- --------------------------------------------------------------------
CREATE TABLE certificates (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    issuing_organization VARCHAR(255) NOT NULL,
    issue_date DATE DEFAULT NULL,
    credential_url VARCHAR(500) DEFAULT NULL,
    certificate_image VARCHAR(500) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_certificates_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_certificates_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 11. Table: skills
-- --------------------------------------------------------------------
CREATE TABLE skills (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    skill_name VARCHAR(100) NOT NULL,
    proficiency_level VARCHAR(50) DEFAULT 'Intermediate',
    endorsements_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_skills_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_skills_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 12. Table: projects
-- --------------------------------------------------------------------
CREATE TABLE projects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT DEFAULT NULL,
    technologies_used VARCHAR(255) DEFAULT NULL,
    project_url VARCHAR(500) DEFAULT NULL,
    github_url VARCHAR(500) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_projects_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_projects_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 13. Table: internships
-- --------------------------------------------------------------------
CREATE TABLE internships (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    company_name VARCHAR(255) NOT NULL,
    role_title VARCHAR(255) NOT NULL,
    start_date DATE DEFAULT NULL,
    end_date DATE DEFAULT NULL,
    is_current TINYINT(1) DEFAULT 0,
    description TEXT DEFAULT NULL,
    certificate_url VARCHAR(500) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_internships_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_internships_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 14. Table: achievements
-- --------------------------------------------------------------------
CREATE TABLE achievements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    category VARCHAR(100) DEFAULT NULL,
    description TEXT DEFAULT NULL,
    date_achieved DATE DEFAULT NULL,
    certificate_url VARCHAR(500) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_achievements_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_achievements_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 15. Table: sports
-- Must store: sport, event, year, team, position, result, medal, certificate
-- --------------------------------------------------------------------
CREATE TABLE sports (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    sport VARCHAR(100) NOT NULL,
    event VARCHAR(255) NOT NULL,
    year VARCHAR(50) NOT NULL,
    team VARCHAR(100) DEFAULT NULL,
    position VARCHAR(100) DEFAULT NULL,
    result VARCHAR(100) DEFAULT NULL,
    medal VARCHAR(50) DEFAULT NULL,
    certificate VARCHAR(500) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_sports_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_sports_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 16. Table: cultural_activities
-- Must store: category, event, year, result_win, award, leadership_role
-- --------------------------------------------------------------------
CREATE TABLE cultural_activities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    category VARCHAR(100) NOT NULL,
    event VARCHAR(255) NOT NULL,
    year VARCHAR(50) NOT NULL,
    result_win VARCHAR(100) DEFAULT NULL,
    award VARCHAR(255) DEFAULT NULL,
    leadership_role VARCHAR(100) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_cultural_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_cultural_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 17. Table: events
-- Supported types: technical, sports, cultural, workshop, hackathon, seminar, fest
-- --------------------------------------------------------------------
CREATE TABLE events (
    id INT AUTO_INCREMENT PRIMARY KEY,
    created_by INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    description TEXT DEFAULT NULL,
    venue VARCHAR(255) NOT NULL,
    event_date DATETIME NOT NULL,
    banner_url VARCHAR(500) DEFAULT NULL,
    max_seats INT DEFAULT 0,
    registered_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_events_created_by FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_events_created_by (created_by),
    INDEX idx_events_type (event_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 18. Table: event_registrations
-- --------------------------------------------------------------------
CREATE TABLE event_registrations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    event_id INT NOT NULL,
    user_id INT NOT NULL,
    status VARCHAR(50) DEFAULT 'REGISTERED',
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_event_registrations (event_id, user_id),
    CONSTRAINT fk_event_reg_event FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
    CONSTRAINT fk_event_reg_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_event_reg_event (event_id),
    INDEX idx_event_reg_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 19. Table: clubs
-- Must support: verification (is_verified), members, announcements, achievements
-- --------------------------------------------------------------------
CREATE TABLE clubs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    category VARCHAR(100) NOT NULL,
    description TEXT DEFAULT NULL,
    logo_url VARCHAR(500) DEFAULT NULL,
    banner_url VARCHAR(500) DEFAULT NULL,
    lead_id INT NOT NULL,
    is_verified TINYINT(1) DEFAULT 1,
    achievements TEXT DEFAULT NULL,
    members_count INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_clubs_lead_id FOREIGN KEY (lead_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_clubs_lead_id (lead_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 20. Table: club_members
-- --------------------------------------------------------------------
CREATE TABLE club_members (
    id INT AUTO_INCREMENT PRIMARY KEY,
    club_id INT NOT NULL,
    user_id INT NOT NULL,
    role VARCHAR(50) DEFAULT 'MEMBER',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_club_members (club_id, user_id),
    CONSTRAINT fk_club_mem_club FOREIGN KEY (club_id) REFERENCES clubs(id) ON DELETE CASCADE,
    CONSTRAINT fk_club_mem_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_club_mem_club (club_id),
    INDEX idx_club_mem_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 21. Table: club_posts (Announcements & Updates)
-- --------------------------------------------------------------------
CREATE TABLE club_posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    club_id INT NOT NULL,
    author_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    post_type VARCHAR(50) DEFAULT 'ANNOUNCEMENT',
    media_url VARCHAR(500) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_club_posts_club FOREIGN KEY (club_id) REFERENCES clubs(id) ON DELETE CASCADE,
    CONSTRAINT fk_club_posts_author FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_club_posts_club (club_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 22. Table: communities
-- Must support: posts, comments, upvotes, downvotes, save and report
-- --------------------------------------------------------------------
CREATE TABLE communities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT DEFAULT NULL,
    icon_url VARCHAR(500) DEFAULT NULL,
    creator_id INT NOT NULL,
    members_count INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_communities_creator FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_communities_creator (creator_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 23. Table: community_members
-- --------------------------------------------------------------------
CREATE TABLE community_members (
    id INT AUTO_INCREMENT PRIMARY KEY,
    community_id INT NOT NULL,
    user_id INT NOT NULL,
    role VARCHAR(50) DEFAULT 'MEMBER',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_community_members (community_id, user_id),
    CONSTRAINT fk_comm_mem_comm FOREIGN KEY (community_id) REFERENCES communities(id) ON DELETE CASCADE,
    CONSTRAINT fk_comm_mem_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_comm_mem_comm (community_id),
    INDEX idx_comm_mem_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 24. Table: community_posts
-- --------------------------------------------------------------------
CREATE TABLE community_posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    community_id INT NOT NULL,
    author_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    media_url VARCHAR(500) DEFAULT NULL,
    upvotes INT DEFAULT 0,
    downvotes INT DEFAULT 0,
    comments_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_comm_posts_comm FOREIGN KEY (community_id) REFERENCES communities(id) ON DELETE CASCADE,
    CONSTRAINT fk_comm_posts_author FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_comm_posts_comm (community_id),
    INDEX idx_comm_posts_author (author_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 25. Table: messages
-- --------------------------------------------------------------------
CREATE TABLE messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id INT NOT NULL,
    receiver_id INT NOT NULL,
    message_text TEXT NOT NULL,
    is_read TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_messages_sender FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_messages_receiver FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_messages_sender (sender_id),
    INDEX idx_messages_receiver (receiver_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 26. Table: notifications
-- --------------------------------------------------------------------
CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    actor_id INT DEFAULT NULL,
    type VARCHAR(50) NOT NULL,
    content TEXT NOT NULL,
    target_url VARCHAR(500) DEFAULT NULL,
    is_read TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_notifications_actor FOREIGN KEY (actor_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_notifications_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 27. Table: badges
-- --------------------------------------------------------------------
CREATE TABLE badges (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT NOT NULL,
    icon_url VARCHAR(500) DEFAULT NULL,
    points_reward INT DEFAULT 50,
    requirement_type VARCHAR(100) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 28. Table: user_badges
-- --------------------------------------------------------------------
CREATE TABLE user_badges (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    badge_id INT NOT NULL,
    awarded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_user_badges (user_id, badge_id),
    CONSTRAINT fk_ub_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_ub_badge FOREIGN KEY (badge_id) REFERENCES badges(id) ON DELETE CASCADE,
    INDEX idx_ub_user (user_id),
    INDEX idx_ub_badge (badge_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 29. Table: reports
-- --------------------------------------------------------------------
CREATE TABLE reports (
    id INT AUTO_INCREMENT PRIMARY KEY,
    reporter_id INT NOT NULL,
    target_type VARCHAR(50) NOT NULL,
    target_id INT NOT NULL,
    reason VARCHAR(255) NOT NULL,
    details TEXT DEFAULT NULL,
    status VARCHAR(50) DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_reports_reporter FOREIGN KEY (reporter_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_reports_reporter (reporter_id),
    INDEX idx_reports_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 30. Table: leaderboard
-- Categories supported: OVERALL, SPORTS, CULTURAL, PROFESSIONAL, CREATOR, CONTRIBUTOR
-- --------------------------------------------------------------------
CREATE TABLE leaderboard (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    category VARCHAR(50) NOT NULL,
    points INT DEFAULT 0,
    rank_position INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_leaderboard_category CHECK (category IN ('OVERALL', 'SPORTS', 'CULTURAL', 'PROFESSIONAL', 'CREATOR', 'CONTRIBUTOR')),
    CONSTRAINT uk_leaderboard_user_cat UNIQUE (user_id, category),
    CONSTRAINT fk_leaderboard_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_leaderboard_user (user_id),
    INDEX idx_leaderboard_cat_points (category, points DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================
-- SEED DATA FOR IMMEDIATE TESTING
-- Password for test users below is "Student@123" or "Admin@123"
-- PBKDF2 hash format: salt_hex:hash_hex
-- ====================================================================

-- 1. Users Seed Data
INSERT INTO users (id, college_email, password_hash, student_id, full_name, branch, year, division, role, points) VALUES
(1, 'alex.mit@mit.edu', '3f8a1b9c2d4e6f801234567890abcdef:a1b2c3d4e5f678901234567890abcdef1234567890abcdef1234567890abcdef', 'MIT2024CS001', 'Alex Rivera', 'Computer Engineering', 'Third Year', 'A', 'STUDENT', 250),
(2, 'sarah.mit@mit.edu', '3f8a1b9c2d4e6f801234567890abcdef:a1b2c3d4e5f678901234567890abcdef1234567890abcdef1234567890abcdef', 'MIT2024IT042', 'Sarah Chen', 'Information Technology', 'Third Year', 'B', 'STUDENT', 180),
(3, 'club.admin@mit.edu', '3f8a1b9c2d4e6f801234567890abcdef:a1b2c3d4e5f678901234567890abcdef1234567890abcdef1234567890abcdef', 'MIT2023CS010', 'Rahul Sharma', 'Computer Engineering', 'Fourth Year', 'A', 'CLUB_ADMIN', 320),
(4, 'college.admin@mit.edu', '3f8a1b9c2d4e6f801234567890abcdef:a1b2c3d4e5f678901234567890abcdef1234567890abcdef1234567890abcdef', 'MITADMIN001', 'Prof. H. V. Kulkarni', 'Computer Engineering', 'Faculty', 'N/A', 'COLLEGE_ADMIN', 500);

-- 2. Profiles Seed Data
INSERT INTO profiles (user_id, profile_photo, cover_photo, bio, branch, year, division, linkedin_url, github_url) VALUES
(1, 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80', 'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?auto=format&fit=crop&w=1200&q=80', 'Computer Engineering enthusiast | Tech Club Lead | Passionate about full-stack development and AI.', 'Computer Engineering', 'Third Year', 'A', 'https://linkedin.com/in/alexrivera', 'https://github.com/alexrivera'),
(2, 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80', 'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?auto=format&fit=crop&w=1200&q=80', 'UI/UX Designer & Frontend Developer. Building student-first experiences.', 'Information Technology', 'Third Year', 'B', 'https://linkedin.com/in/sarahchen', 'https://github.com/sarahchen'),
(3, 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80', 'https://images.unsplash.com/photo-1515187029135-18ee286d815b?auto=format&fit=crop&w=1200&q=80', 'Coding Club President | Hackathon Organizer | Open Source Contributor.', 'Computer Engineering', 'Fourth Year', 'A', 'https://linkedin.com/in/rahulsharma', 'https://github.com/rahulsharma'),
(4, 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=400&q=80', 'https://images.unsplash.com/photo-1541829070764-84a7d30dd3f3?auto=format&fit=crop&w=1200&q=80', 'Head of Student Affairs & Innovation Cell at MIT.', 'Computer Engineering', 'Faculty', 'N/A', 'https://linkedin.com/in/hvkulkarni', NULL);

-- 3. Posts Seed Data (TEXT, IMAGE, VIDEO)
INSERT INTO posts (id, user_id, caption, post_type, media_url, likes_count, comments_count, shares_count) VALUES
(1, 1, 'Excited to announce our team won 1st place at the National Campus Hackathon! Thanks to everyone who supported us.', 'IMAGE', 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=800&q=80', 24, 5, 3),
(2, 2, 'Just finished redesigning the MIT Student Portal concept. Feedback welcomed!', 'IMAGE', 'https://images.unsplash.com/photo-1507238691740-187a5b1d37b8?auto=format&fit=crop&w=800&q=80', 18, 2, 1),
(3, 3, 'Reminder: Coding Club Weekly Meetup is tomorrow at 4 PM in Seminar Hall 2. Topic: System Design Basics.', 'TEXT', NULL, 35, 8, 5),
(4, 1, 'Demo snippet of our upcoming Servlet & MySQL project architecture!', 'VIDEO', 'https://www.w3schools.com/html/mov_bbb.mp4', 12, 1, 0);

-- 4. Comments Seed Data
INSERT INTO comments (post_id, user_id, comment_text) VALUES
(1, 2, 'Huge congratulations Alex! Great achievement for MIT!'),
(1, 3, 'Outstanding work team! Proud of you guys.'),
(2, 1, 'The UI color palette looks extremely clean, Sarah!');

-- 5. Likes Seed Data
INSERT INTO likes (post_id, user_id) VALUES
(1, 2),
(1, 3),
(2, 1),
(3, 1),
(3, 2);

-- 6. Followers Seed Data
INSERT INTO followers (follower_id, following_id) VALUES
(1, 2),
(1, 3),
(2, 1),
(3, 1);

-- 7. Bookmarks Seed Data
INSERT INTO bookmarks (user_id, post_id) VALUES
(1, 3),
(2, 1);

-- 8. Shares Seed Data
INSERT INTO shares (user_id, post_id, shared_to_platform) VALUES
(1, 3, 'INTERNAL'),
(2, 1, 'LINKEDIN');

-- 9. Mentions Seed Data
INSERT INTO mentions (post_id, mentioned_user_id) VALUES
(1, 2),
(1, 3);

-- 10. Certificates Seed Data
INSERT INTO certificates (user_id, title, issuing_organization, issue_date, credential_url, certificate_image) VALUES
(1, 'AWS Certified Cloud Practitioner', 'Amazon Web Services', '2024-01-15', 'https://aws.amazon.com/verify/123456', 'https://images.unsplash.com/photo-1607799279861-4dd421887fb3?auto=format&fit=crop&w=600&q=80');

-- 11. Skills Seed Data
INSERT INTO skills (user_id, skill_name, proficiency_level, endorsements_count) VALUES
(1, 'Java Servlets & JSP', 'Advanced', 14),
(1, 'MySQL & Database Design', 'Advanced', 18),
(1, 'Vanilla JavaScript', 'Intermediate', 10),
(2, 'Figma & UI Design', 'Expert', 22);

-- 12. Projects Seed Data
INSERT INTO projects (user_id, title, description, technologies_used, project_url, github_url) VALUES
(1, 'MIT Socials Platform', 'Private college social network built with Core Java, Servlets, and MySQL.', 'Java, Servlets, MySQL, HTML, CSS, JS', 'http://localhost:8080/MIT-SOCIALS', 'https://github.com/alexrivera/mit-socials');

-- 13. Internships Seed Data
INSERT INTO internships (user_id, company_name, role_title, start_date, end_date, is_current, description) VALUES
(1, 'TechCorp Solutions', 'Backend Engineering Intern', '2024-06-01', '2024-08-31', 0, 'Developed RESTful microservices in Java and optimized MySQL database queries.');

-- 14. Achievements Seed Data
INSERT INTO achievements (user_id, title, category, description, date_achieved) VALUES
(1, '1st Rank in Department Coding Contest', 'Technical', 'Awarded first place among 150+ participants in annual coding marathon.', '2024-03-20');

-- 15. Sports Seed Data
-- Required fields: sport, event, year, team, position, result, medal, certificate
INSERT INTO sports (user_id, sport, event, year, team, position, result, medal, certificate) VALUES
(1, 'Basketball', 'Inter-College Annual Sports Fest', '2024', 'MIT Blues', 'Captain', 'Winners', 'Gold', 'https://images.unsplash.com/photo-1546519638-68e109498ffc?auto=format&fit=crop&w=600&q=80'),
(2, 'Badminton', 'State University Championship', '2023', 'MIT Singles', 'Finalist', 'Runner Up', 'Silver', 'https://images.unsplash.com/photo-1521537634581-0ddea2efe2b2?auto=format&fit=crop&w=600&q=80');

-- 16. Cultural Activities Seed Data
-- Required fields: category, event, year, result_win, award, leadership_role
INSERT INTO cultural_activities (user_id, category, event, year, result_win, award, leadership_role) VALUES
(1, 'Drama', 'Persona Cultural Fest', '2024', '1st Place', 'Best Play & Best Actor Trophy', 'Play Director'),
(2, 'Fine Arts', 'Canvas & Color Inter-College Fest', '2024', '1st Place', 'Golden Brush Award', 'Participant');

-- 17. Events Seed Data
-- Supported event types: technical, sports, cultural, workshop, hackathon, seminar, fest
INSERT INTO events (id, created_by, title, event_type, description, venue, event_date, banner_url, max_seats, registered_count) VALUES
(1, 3, 'MIT Hackathon 2024', 'hackathon', '24-hour annual coding hackathon open to all branches.', 'Main Auditorium', '2024-11-15 09:00:00', 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=800&q=80', 200, 45),
(2, 4, 'Persona Annual Cultural Fest', 'fest', '3-day grand cultural festival featuring music, dance, and arts.', 'College Grounds', '2024-12-20 10:00:00', 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=800&q=80', 1000, 320),
(3, 3, 'Full Stack Web Development Workshop', 'workshop', 'Hands-on training on Servlet, JDBC, and SQL best practices.', 'Computer Lab 3', '2024-10-25 14:00:00', 'https://images.unsplash.com/photo-1531403009284-440f080d1e12?auto=format&fit=crop&w=800&q=80', 60, 58);

-- 18. Event Registrations Seed Data
INSERT INTO event_registrations (event_id, user_id, status) VALUES
(1, 1, 'REGISTERED'),
(1, 2, 'REGISTERED'),
(3, 1, 'ATTENDED');

-- 19. Clubs Seed Data
-- Required: verification (is_verified), members, announcements, achievements
INSERT INTO clubs (id, name, category, description, logo_url, banner_url, lead_id, is_verified, achievements, members_count) VALUES
(1, 'Coding Club MIT', 'Technical', 'Official campus programming and competitive coding club.', 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=200&q=80', 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=800&q=80', 3, 1, 'Winner of National Tech Excellence Award 2023', 150),
(2, 'Rotaract Club MIT', 'Social & Cultural', 'Youth organization dedicated to community service and leadership development.', 'https://images.unsplash.com/photo-1582213782179-e0d53f98f2ca?auto=format&fit=crop&w=200&q=80', 'https://images.unsplash.com/photo-1511632765486-a01980e01a18?auto=format&fit=crop&w=800&q=80', 2, 1, 'Organized 10+ Blood Donation & Social Drives', 95);

-- 20. Club Members Seed Data
INSERT INTO club_members (club_id, user_id, role) VALUES
(1, 3, 'ADMIN'),
(1, 1, 'CORE_MEMBER'),
(2, 2, 'ADMIN');

-- 21. Club Posts Seed Data (Announcements)
INSERT INTO club_posts (club_id, author_id, title, content, post_type) VALUES
(1, 3, 'Announcing MIT TechHack 2024', 'Registrations are now live for MIT TechHack 2024. Great cash prizes and mentorship opportunities!', 'ANNOUNCEMENT'),
(2, 2, 'Blood Donation Drive Successful', 'Thank you to all student volunteers who donated blood during our annual drive yesterday.', 'ANNOUNCEMENT');

-- 22. Communities Seed Data
-- Required: posts, comments, upvotes, downvotes, save and report
INSERT INTO communities (id, name, description, icon_url, creator_id, members_count) VALUES
(1, 'AI & Machine Learning Hub', 'Discuss paper implementations, ML models, datasets, and AI news.', 'https://images.unsplash.com/photo-1677442136019-21780ecad995?auto=format&fit=crop&w=200&q=80', 1, 85),
(2, 'Campus Placement Preparation', 'Share interview experiences, aptitude tips, and resume templates.', 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?auto=format&fit=crop&w=200&q=80', 3, 210);

-- 23. Community Members Seed Data
INSERT INTO community_members (community_id, user_id, role) VALUES
(1, 1, 'ADMIN'),
(1, 2, 'MEMBER'),
(2, 3, 'ADMIN'),
(2, 1, 'MEMBER');

-- 24. Community Posts Seed Data
INSERT INTO community_posts (community_id, author_id, title, content, upvotes, downvotes, comments_count) VALUES
(1, 1, 'Best resources to get started with LLMs in 2024', 'Here is a curated list of free courses, papers, and GitHub repositories for mastering Large Language Models.', 42, 1, 6),
(2, 3, 'Top 5 SQL queries asked in Tech Interviews', 'Master these window functions and self-joins before appearing for campus placements!', 65, 0, 12);

-- 25. Messages Seed Data
INSERT INTO messages (sender_id, receiver_id, message_text, is_read) VALUES
(1, 2, 'Hey Sarah, are you attending the System Design session today?', 1),
(2, 1, 'Yes Alex! I will be there by 4 PM.', 1),
(3, 1, 'Alex, please submit your team details for the hackathon by tonight.', 0);

-- 26. Notifications Seed Data
INSERT INTO notifications (user_id, actor_id, type, content, target_url) VALUES
(1, 2, 'LIKE', 'Sarah Chen liked your post.', '/MIT-SOCIALS/post.html?id=1'),
(1, 3, 'COMMENT', 'Rahul Sharma commented on your hackathon victory post.', '/MIT-SOCIALS/post.html?id=1'),
(2, 1, 'FOLLOW', 'Alex Rivera started following you.', '/MIT-SOCIALS/profile.html?id=1');

-- 27. Badges Seed Data
INSERT INTO badges (id, name, description, icon_url, points_reward, requirement_type) VALUES
(1, 'Code Ninja', 'Awarded for publishing 5+ technical projects and winning coding contests.', 'https://img.icons8.com/color/96/code.png', 100, 'PROJECT_COUNT'),
(2, 'Event Champion', 'Awarded for active participation and registration in 3+ campus events.', 'https://img.icons8.com/color/96/trophy.png', 50, 'EVENT_ATTEND'),
(3, 'Campus Pioneer', 'Top contributor with over 200 platform engagement points.', 'https://img.icons8.com/color/96/star.png', 150, 'POINTS_THRESHOLD');

-- 28. User Badges Seed Data
INSERT INTO user_badges (user_id, badge_id) VALUES
(1, 1),
(1, 2),
(1, 3),
(2, 2),
(3, 1);

-- 29. Reports Seed Data
INSERT INTO reports (reporter_id, target_type, target_id, reason, details, status) VALUES
(2, 'POST', 4, 'Spam or Misleading Content', 'Test video URL reported for review.', 'PENDING');

-- 30. Leaderboard Seed Data
-- Categories: OVERALL, SPORTS, CULTURAL, PROFESSIONAL, CREATOR, CONTRIBUTOR
INSERT INTO leaderboard (user_id, category, points, rank_position) VALUES
(1, 'OVERALL', 450, 1),
(1, 'SPORTS', 120, 1),
(1, 'CULTURAL', 150, 1),
(1, 'PROFESSIONAL', 80, 2),
(1, 'CREATOR', 60, 2),
(1, 'CONTRIBUTOR', 40, 3),

(2, 'OVERALL', 380, 2),
(2, 'SPORTS', 90, 2),
(2, 'CULTURAL', 110, 2),
(2, 'PROFESSIONAL', 100, 1),
(2, 'CREATOR', 50, 3),
(2, 'CONTRIBUTOR', 30, 4),

(3, 'OVERALL', 320, 3),
(3, 'SPORTS', 50, 3),
(3, 'CULTURAL', 40, 3),
(3, 'PROFESSIONAL', 70, 3),
(3, 'CREATOR', 110, 1),
(3, 'CONTRIBUTOR', 50, 2),

(4, 'OVERALL', 500, 1),
(4, 'CONTRIBUTOR', 200, 1);

-- ====================================================================
-- 31+. Academic, career and campus visualization tables
-- ====================================================================
DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS grades;
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS jobs;
DROP TABLE IF EXISTS campus_locations;

CREATE TABLE courses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    credits INT NOT NULL DEFAULT 3,
    department VARCHAR(100) DEFAULT NULL,
    semester VARCHAR(50) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE enrollments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    course_id INT NOT NULL,
    semester VARCHAR(50) NOT NULL,
    academic_year VARCHAR(20) DEFAULT NULL,
    UNIQUE KEY uk_enrollment (user_id, course_id, semester),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE grades (
    id INT AUTO_INCREMENT PRIMARY KEY,
    enrollment_id INT NOT NULL UNIQUE,
    grade VARCHAR(10) DEFAULT NULL,
    grade_points DECIMAL(4,2) DEFAULT 0,
    FOREIGN KEY (enrollment_id) REFERENCES enrollments(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE attendance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    enrollment_id INT NOT NULL UNIQUE,
    attended INT NOT NULL DEFAULT 0,
    total INT NOT NULL DEFAULT 0,
    FOREIGN KEY (enrollment_id) REFERENCES enrollments(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE jobs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    posted_by INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    company VARCHAR(255) NOT NULL,
    location VARCHAR(255) DEFAULT NULL,
    job_type VARCHAR(100) DEFAULT 'INTERNSHIP',
    description TEXT,
    apply_url VARCHAR(500) DEFAULT NULL,
    deadline DATE DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (posted_by) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_jobs_deadline(deadline)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE campus_locations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    description TEXT,
    x_pos INT NOT NULL DEFAULT 10,
    y_pos INT NOT NULL DEFAULT 10,
    width INT NOT NULL DEFAULT 140,
    height INT NOT NULL DEFAULT 90,
    icon VARCHAR(20) DEFAULT '🏫'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO courses(code,name,credits,department,semester) VALUES
('CS301','Data Structures and Algorithms',4,'Computer Engineering','Semester 5'),
('CS302','Database Management Systems',4,'Computer Engineering','Semester 5'),
('CS303','Web Technologies',3,'Computer Engineering','Semester 5'),
('CS304','Computer Networks',4,'Computer Engineering','Semester 5'),
('HU301','Professional Communication',2,'Humanities','Semester 5');

INSERT INTO campus_locations(name,category,description,x_pos,y_pos,width,height,icon) VALUES
('Academic Building 1','Academic','Main academic building on the MIT campus.',8,8,170,145,'🏫'),
('Academic Building 2','Academic','Second campus academic building with classrooms and laboratories.',28,8,170,145,'🏫'),
('Academic Building 3','Academic','Third campus academic building for student learning and activities.',48,8,170,145,'🏫'),
('Basketball Court','Sports','Basketball court and training area.',69,11,185,122,'🏀'),
('Student Hostel','Student Life','Student hostel located at the far right beside the campus sports area.',90,8,65,182,'🛏️'),
('Gazebo','Student Life','Outdoor gazebo and student gathering point at the central road fork.',37,66,136,80,'🌳'),
('Main Playground','Sports','Main playground/ground in the lower centre-right of the campus.',52,70,390,176,'🏟️'),
('Swimming Pool','Sports','Swimming pool in the lower-right corner beside the main ground.',85,69,110,145,'🏊');

-- Seed academic records for the first student, if one exists.
INSERT INTO enrollments(user_id,course_id,semester,academic_year)
SELECT u.id,c.id,c.semester,'2026-27' FROM users u CROSS JOIN courses c
WHERE u.id=(SELECT MIN(id) FROM users)
  AND NOT EXISTS (SELECT 1 FROM enrollments e WHERE e.user_id=u.id AND e.course_id=c.id AND e.semester=c.semester);

INSERT INTO grades(enrollment_id,grade,grade_points)
SELECT e.id, CASE MOD(e.id,5) WHEN 0 THEN 'A+' WHEN 1 THEN 'A' WHEN 2 THEN 'B+' WHEN 3 THEN 'A' ELSE 'B' END,
       CASE MOD(e.id,5) WHEN 0 THEN 10 WHEN 1 THEN 9 WHEN 2 THEN 8 WHEN 3 THEN 9 ELSE 7 END
FROM enrollments e LEFT JOIN grades g ON g.enrollment_id=e.id WHERE g.id IS NULL;

INSERT INTO attendance(enrollment_id,attended,total)
SELECT e.id, 42 + MOD(e.id,8), 50 FROM enrollments e LEFT JOIN attendance a ON a.enrollment_id=e.id WHERE a.id IS NULL;

INSERT INTO jobs(posted_by,title,company,location,job_type,description,apply_url,deadline)
SELECT id,'Software Engineering Intern','MIT Industry Partners','Pune','INTERNSHIP','Build web applications with an engineering mentor.','https://example.com/apply','2026-12-15'
FROM users WHERE id=(SELECT MIN(id) FROM users) LIMIT 1;
