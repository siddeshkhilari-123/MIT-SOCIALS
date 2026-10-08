-- ====================================================================
-- MIT Socials Demo Data Pack
-- Non-destructive: adds realistic demo content to an existing schema.
-- Run this AFTER database/mit_socials.sql has been imported.
-- Demo accounts are for display/testing only; do not use real credentials.
-- ====================================================================

USE mit_socials;

-- Use the first existing account as the current/demo viewer.
SET @me = (SELECT MIN(id) FROM users);

-- --------------------------------------------------------------------
-- Demo students for directory, feed, clubs, community and leaderboard
-- --------------------------------------------------------------------
INSERT IGNORE INTO users
(id, college_email, password_hash, student_id, full_name, branch, year, division, role, points)
VALUES
(101,'demo.aarav@mit.edu','demo','MITDEMO101','Aarav Mehta','Computer Engineering','Third Year','A','STUDENT',420),
(102,'demo.isha@mit.edu','demo','MITDEMO102','Isha Patil','Information Technology','Second Year','B','STUDENT',365),
(103,'demo.rohan@mit.edu','demo','MITDEMO103','Rohan Deshmukh','Electronics & Telecommunication','Third Year','C','STUDENT',315),
(104,'demo.ananya@mit.edu','demo','MITDEMO104','Ananya Kulkarni','Computer Engineering','Second Year','A','STUDENT',290),
(105,'demo.vihaan@mit.edu','demo','MITDEMO105','Vihaan Joshi','Mechanical Engineering','Fourth Year','B','STUDENT',255),
(106,'demo.neha@mit.edu','demo','MITDEMO106','Neha Shah','Information Technology','Third Year','A','STUDENT',235);

INSERT IGNORE INTO profiles
(user_id, profile_photo, cover_photo, bio, branch, year, division, linkedin_url, github_url)
VALUES
(101,'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80',NULL,'Full-stack developer, hackathon finalist and campus tech community volunteer.','Computer Engineering','Third Year','A','https://linkedin.com','https://github.com'),
(102,'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=300&q=80',NULL,'UI/UX designer who loves student products, events and creative collaboration.','Information Technology','Second Year','B','https://linkedin.com','https://github.com'),
(103,'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=300&q=80',NULL,'Sports committee volunteer and robotics enthusiast.','Electronics & Telecommunication','Third Year','C','https://linkedin.com','https://github.com'),
(104,'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?auto=format&fit=crop&w=300&q=80',NULL,'Content creator, photographer and cultural fest coordinator.','Computer Engineering','Second Year','A','https://linkedin.com','https://github.com'),
(105,'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',NULL,'Mechanical design student and football team member.','Mechanical Engineering','Fourth Year','B','https://linkedin.com','https://github.com'),
(106,'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=300&q=80',NULL,'Placement preparation mentor and coding club volunteer.','Information Technology','Third Year','A','https://linkedin.com','https://github.com');

-- --------------------------------------------------------------------
-- Fresh campus feed content
-- --------------------------------------------------------------------
INSERT IGNORE INTO posts
(id,user_id,caption,post_type,media_url,likes_count,comments_count,shares_count,created_at)
VALUES
(101,101,'Our team just qualified for the inter-college innovation challenge! 🚀 Looking for one more teammate for the product demo.','TEXT',NULL,32,5,4,'2026-10-08 09:10:00'),
(102,102,'New student-portal UI concept is ready. What should we improve first: timetable, attendance or event discovery?','IMAGE','https://images.unsplash.com/photo-1558655146-9f40138edfeb?auto=format&fit=crop&w=900&q=80',48,9,6,'2026-10-07 18:20:00'),
(103,103,'Basketball practice starts at 5:30 PM today. New members are welcome! 🏀','IMAGE','https://images.unsplash.com/photo-1546519638-68e109498ffc?auto=format&fit=crop&w=900&q=80',27,4,3,'2026-10-07 15:45:00'),
(104,104,'Behind the scenes from our campus photography walk. The sunset near the gazebo was amazing. 📸','IMAGE','https://images.unsplash.com/photo-1497366754035-f200968a6e72?auto=format&fit=crop&w=900&q=80',39,7,5,'2026-10-06 20:15:00'),
(105,105,'Placement season checklist: resume review, aptitude practice, DSA revision and two mock interviews every week.','TEXT',NULL,22,3,2,'2026-10-06 11:00:00'),
(106,106,'The Coding Club is opening registrations for its beginner Java + SQL bootcamp.','TEXT',NULL,54,11,8,'2026-10-05 16:30:00'),
(107,101,'Proud moment: our project dashboard is finally connected to MySQL and real Servlet APIs. 💚','IMAGE','https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=900&q=80',61,12,9,'2026-10-04 19:40:00'),
(108,102,'Reminder: bring your college ID for tomorrow’s workshop registration desk.','TEXT',NULL,18,2,1,'2026-10-04 10:05:00');

INSERT IGNORE INTO comments(post_id,user_id,comment_text)
VALUES
(101,102,'Count me in for the product demo!'),
(102,101,'The event discovery card would be really useful.'),
(103,104,'I will join practice after 6 PM.'),
(106,101,'This will be great for first-year students.'),
(107,103,'The live dashboard looks solid!');

INSERT IGNORE INTO likes(post_id,user_id)
VALUES
(101,102),(101,104),(102,101),(102,103),(103,101),(103,104),(104,102),(105,106),(106,101),(106,102),(107,103),(107,104),(108,105);

INSERT IGNORE INTO followers(follower_id,following_id)
VALUES
(101,102),(101,103),(102,101),(102,104),(103,101),(104,101),(105,106),(106,102),(106,101);

-- --------------------------------------------------------------------
-- Future campus events so the dashboard is populated in 2026
-- --------------------------------------------------------------------
INSERT IGNORE INTO events
(id,created_by,title,event_type,description,venue,event_date,banner_url,max_seats,registered_count)
VALUES
(101,101,'MIT TechSprint 2026','hackathon','24-hour product building challenge with mentors, judging and prizes.','Main Auditorium','2026-10-17 09:00:00','https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=1000&q=80',250,86),
(102,103,'Inter-Department Basketball League','sports','Campus basketball league featuring department teams and open tryouts.','Basketball Court','2026-10-22 16:30:00','https://images.unsplash.com/photo-1546519638-68e109498ffc?auto=format&fit=crop&w=1000&q=80',180,72),
(103,104,'Persona Cultural Evening','cultural','Music, dance, theatre and student performances under the campus lights.','Main Playground','2026-11-05 17:00:00','https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=1000&q=80',800,420),
(104,106,'Java + MySQL Career Workshop','workshop','Hands-on workshop covering Servlets, JDBC, SQL and interview-ready backend patterns.','Academic Building 2','2026-11-12 14:00:00','https://images.unsplash.com/photo-1531403009284-440f080d1e12?auto=format&fit=crop&w=1000&q=80',80,54),
(105,101,'Campus Innovation Expo','seminar','Student projects, startup ideas, research demos and industry interaction.','Academic Building 1','2026-11-20 10:00:00','https://images.unsplash.com/photo-1511578314322-379afb476865?auto=format&fit=crop&w=1000&q=80',500,198),
(106,102,'Annual Sports & Wellness Day','sports','Friendly competitions, swimming activities and student wellness sessions.','Main Playground','2026-12-01 08:00:00','https://images.unsplash.com/photo-1461896836934-ffe607ba8211?auto=format&fit=crop&w=1000&q=80',600,210);

INSERT IGNORE INTO event_registrations(event_id,user_id,status)
SELECT 101,@me,'REGISTERED' WHERE @me IS NOT NULL;
INSERT IGNORE INTO event_registrations(event_id,user_id,status)
SELECT 104,@me,'REGISTERED' WHERE @me IS NOT NULL;

-- --------------------------------------------------------------------
-- Clubs and announcements
-- --------------------------------------------------------------------
INSERT IGNORE INTO clubs
(id,name,category,description,logo_url,banner_url,lead_id,is_verified,achievements,members_count)
VALUES
(101,'MIT Developers Guild','Technical','Build real projects, run coding sessions and prepare for software careers.','https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=300&q=80','https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=1000&q=80',101,1,'National hackathon finalists and weekly technical workshops',186),
(102,'Design & Creators Club','Creative','UI/UX, photography, video, illustration and creative collaboration.','https://images.unsplash.com/photo-1561070791-2526d30994b5?auto=format&fit=crop&w=300&q=80','https://images.unsplash.com/photo-1497366754035-f200968a6e72?auto=format&fit=crop&w=1000&q=80',102,1,'Campus design showcase and annual creator exhibition',124),
(103,'MIT Sports Collective','Sports','Open community for basketball, football, swimming, fitness and recreational sports.','https://images.unsplash.com/photo-1461896836934-ffe607ba8211?auto=format&fit=crop&w=300&q=80','https://images.unsplash.com/photo-1461896836934-ffe607ba8211?auto=format&fit=crop&w=1000&q=80',103,1,'Inter-department league champions',248),
(104,'Social Impact Cell','Community','Student-led volunteering, donation drives and local community initiatives.','https://images.unsplash.com/photo-1559027615-cd4628902d4a?auto=format&fit=crop&w=300&q=80','https://images.unsplash.com/photo-1559027615-cd4628902d4a?auto=format&fit=crop&w=1000&q=80',106,1,'12 community drives completed this year',97);

INSERT IGNORE INTO club_members(club_id,user_id,role) VALUES
(101,101,'ADMIN'),(101,102,'MEMBER'),(101,106,'CORE_MEMBER'),
(102,102,'ADMIN'),(102,104,'CORE_MEMBER'),
(103,103,'ADMIN'),(103,105,'CORE_MEMBER'),
(104,106,'ADMIN'),(104,101,'MEMBER');

INSERT IGNORE INTO club_posts(club_id,author_id,title,content,post_type) VALUES
(101,101,'TechSprint registrations are open','Teams of 2–4 can register now. Bring an idea, a laptop and your best build mindset.','ANNOUNCEMENT'),
(102,102,'Creator meetup this Friday','Bring your portfolio and meet students working in design, photography and content.','ANNOUNCEMENT'),
(103,103,'Basketball trials','Open trials are happening before the inter-department league.','ANNOUNCEMENT'),
(104,106,'Volunteer drive','We are collecting volunteers for the next campus community outreach activity.','ANNOUNCEMENT');

-- --------------------------------------------------------------------
-- Communities
-- --------------------------------------------------------------------
INSERT IGNORE INTO communities(id,name,description,icon_url,creator_id,members_count) VALUES
(101,'AI Builders','Discuss AI projects, papers, tools and practical experiments.','🤖',101,146),
(102,'Placement 2026','Interview prep, company experiences, resumes and mock interviews.','💼',106,284),
(103,'Campus Creators','Photography, design, video editing, music and creative collaborations.','🎨',102,118),
(104,'Sports & Fitness','Training plans, teams, match updates and wellness discussions.','🏆',103,173);

INSERT IGNORE INTO community_members(community_id,user_id,role) VALUES
(101,101,'ADMIN'),(101,102,'MEMBER'),(102,106,'ADMIN'),(102,101,'MEMBER'),(103,102,'ADMIN'),(103,104,'MEMBER'),(104,103,'ADMIN'),(104,105,'MEMBER');

INSERT IGNORE INTO community_posts(community_id,author_id,title,content,upvotes,downvotes,comments_count) VALUES
(101,101,'What are you building this semester?','Share your project idea and find teammates from other branches.',74,1,14),
(102,106,'Share your best DSA resources','Let us build one useful placement-prep resource list for everyone.',92,0,21),
(103,104,'Best campus photography spots','The gazebo and main ground are amazing around sunset.',51,1,8),
(104,103,'Basketball conditioning plan','Sharing a simple weekly plan before the department league.',63,2,11);

-- --------------------------------------------------------------------
-- Messages + notifications for the active account
-- --------------------------------------------------------------------
INSERT INTO messages(sender_id,receiver_id,message_text,is_read)
SELECT 101,@me,'Hey! Are you joining TechSprint this weekend?',0 WHERE @me IS NOT NULL;
INSERT INTO messages(sender_id,receiver_id,message_text,is_read)
SELECT @me,101,'Yes, I am checking the team list today.',1 WHERE @me IS NOT NULL;
INSERT INTO messages(sender_id,receiver_id,message_text,is_read)
SELECT 106,@me,'The Java + MySQL workshop seats are filling up.',0 WHERE @me IS NOT NULL;

INSERT INTO notifications(user_id,actor_id,type,content,target_url,is_read)
SELECT @me,101,'LIKE','Aarav Mehta liked your campus update.','/MIT-SOCIALS/dashboard.html',0 WHERE @me IS NOT NULL;
INSERT INTO notifications(user_id,actor_id,type,content,target_url,is_read)
SELECT @me,106,'EVENT','You have a new reminder for the Java + MySQL Career Workshop.','/MIT-SOCIALS/dashboard.html',0 WHERE @me IS NOT NULL;
INSERT INTO notifications(user_id,actor_id,type,content,target_url,is_read)
SELECT @me,102,'FOLLOW','Isha Patil started following you.','/MIT-SOCIALS/dashboard.html',0 WHERE @me IS NOT NULL;

-- --------------------------------------------------------------------
-- Career demo jobs
-- --------------------------------------------------------------------
INSERT IGNORE INTO jobs(posted_by,title,company,location,job_type,description,apply_url,deadline)
VALUES
(101,'Java Backend Intern','CampusTech Labs','Pune','INTERNSHIP','Work on Java Servlets, JDBC APIs and MySQL-backed applications.','https://example.com','2026-11-30'),
(102,'UI/UX Design Intern','DesignWorks Studio','Mumbai','INTERNSHIP','Create student-facing product experiences and design systems.','https://example.com','2026-12-05'),
(106,'Software Engineering Intern','CloudScale Systems','Bengaluru','INTERNSHIP','Build backend services and developer tools with an engineering mentor.','https://example.com','2026-12-12');

-- --------------------------------------------------------------------
-- Extra sports/cultural records for a richer profile
-- --------------------------------------------------------------------
INSERT IGNORE INTO sports(user_id,sport,event,year,team,position,result,medal,certificate) VALUES
(101,'Football','MIT Inter-Department League','2026','Computer Engineering XI','Midfielder','Semi Finalist','Bronze',NULL),
(103,'Basketball','MIT Inter-Department League','2026','ENTC Titans','Captain','Winners','Gold',NULL),
(105,'Football','Annual Sports Fest','2026','Mechanical United','Defender','Runner Up','Silver',NULL);

INSERT IGNORE INTO cultural_activities(user_id,category,event,year,result_win,award,leadership_role) VALUES
(102,'Design','MIT Creator Showcase','2026','Winner','Best Student Interface','Design Lead'),
(104,'Photography','Campus Photography Week','2026','Winner','Best Campus Frame','Exhibition Coordinator'),
(106,'Public Speaking','Youth Leadership Forum','2026','Finalist','Best Speaker','Student Volunteer');

-- --------------------------------------------------------------------
-- Leaderboard: refresh overall ranking for demo users
-- --------------------------------------------------------------------
INSERT INTO leaderboard(user_id,category,points,rank_position)
VALUES
(101,'OVERALL',420,1),(102,'OVERALL',365,2),(103,'OVERALL',315,3),(104,'OVERALL',290,4),(105,'OVERALL',255,5),(106,'OVERALL',235,6)
ON DUPLICATE KEY UPDATE points=VALUES(points),rank_position=VALUES(rank_position);

INSERT INTO leaderboard(user_id,category,points,rank_position)
VALUES
(101,'PROFESSIONAL',120,1),(102,'CREATOR',145,1),(103,'SPORTS',160,1),(104,'CULTURAL',155,1),(105,'SPORTS',110,2),(106,'CONTRIBUTOR',130,1)
ON DUPLICATE KEY UPDATE points=VALUES(points),rank_position=VALUES(rank_position);

SELECT 'MIT Socials demo data loaded successfully.' AS status;
