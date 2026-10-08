package com.mitsocials.servlet;

import com.mitsocials.util.DBConnection;
import com.mitsocials.util.JsonUtil;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.*;
import java.util.*;

/**
 * Beginner-friendly API for the main MIT Socials modules.
 * All database work uses PreparedStatement.
 */
@WebServlet("/api/platform")
public class PlatformServlet extends HttpServlet {

    private Integer userId(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("userId") == null) return null;
        return (Integer) s.getAttribute("userId");
    }

    @Override protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Integer uid = userId(req);
        if (uid == null) { error(resp, 401, "Please login first."); return; }
        String action = value(req.getParameter("action"), "dashboard");
        try (Connection c = DBConnection.getConnection()) {
            switch (action) {
                case "dashboard" -> dashboard(c, uid, resp);
                case "events" -> events(c, uid, resp);
                case "clubs" -> clubs(c, uid, resp);
                case "communities" -> communities(c, uid, resp);
                case "directory" -> directory(c, req, resp);
                case "profile" -> profile(c, req, uid, resp);
                case "academics" -> academics(c, uid, resp);
                case "career" -> career(c, uid, resp);
                case "sports" -> sports(c, uid, resp);
                case "leaderboard" -> leaderboard(c, req, resp);
                case "notifications" -> notifications(c, uid, resp);
                case "messages" -> messages(c, uid, req, resp);
                case "feed" -> feed(c, uid, resp);
                case "campus" -> campus(c, resp);
                default -> error(resp, 400, "Unknown module.");
            }
        } catch (SQLException e) { e.printStackTrace(); error(resp, 500, "Database error. Check MySQL and the schema."); }
    }

    @Override protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Integer uid = userId(req);
        if (uid == null) { error(resp, 401, "Please login first."); return; }
        Map<String,String> p = JsonUtil.parseRequestBody(req);
        String action = value(p.get("action"), "");
        try (Connection c = DBConnection.getConnection()) {
            switch (action) {
                case "joinClub" -> membership(c, uid, id(p,"club_id"), true, false, resp);
                case "leaveClub" -> membership(c, uid, id(p,"club_id"), false, false, resp);
                case "joinCommunity" -> membership(c, uid, id(p,"community_id"), true, true, resp);
                case "leaveCommunity" -> membership(c, uid, id(p,"community_id"), false, true, resp);
                case "registerEvent" -> eventRegistration(c, uid, id(p,"event_id"), true, resp);
                case "cancelEvent" -> eventRegistration(c, uid, id(p,"event_id"), false, resp);
                case "follow" -> follow(c, uid, id(p,"user_id"), true, resp);
                case "unfollow" -> follow(c, uid, id(p,"user_id"), false, resp);
                case "like" -> like(c, uid, id(p,"post_id"), true, resp);
                case "comment" -> comment(c, uid, id(p,"post_id"), p.get("text"), resp);
                case "unlike" -> like(c, uid, id(p,"post_id"), false, resp);
                case "bookmark" -> bookmark(c, uid, id(p,"post_id"), resp);
                case "sendMessage" -> sendMessage(c, uid, id(p,"receiver_id"), p.get("message"), resp);
                case "createPost" -> createPost(c, uid, p.get("caption"), p.get("post_type"), resp);
                case "markNotification" -> markNotification(c, uid, id(p,"notification_id"), resp);
                default -> error(resp, 400, "Unknown action.");
            }
        } catch (SQLException e) { e.printStackTrace(); error(resp, 500, "Database action failed."); }
    }

    private void dashboard(Connection c,int uid,HttpServletResponse r)throws SQLException,IOException{
        Map<String,Object> out=new LinkedHashMap<>();
        out.put("stats", Map.of("posts",count(c,"posts","user_id",uid),"clubs",count(c,"club_members","user_id",uid),"events",count(c,"event_registrations","user_id",uid),"points",scalarInt(c,"SELECT points FROM users WHERE id=?",uid)));
        out.put("events", eventRows(c,uid,6)); out.put("clubs", clubRows(c,uid,6)); out.put("notifications", notificationRows(c,uid,5));
        JsonUtil.sendJson(r,200,out);
    }

    private List<Map<String,Object>> eventRows(Connection c,int uid,int limit)throws SQLException{
        String sql="SELECT e.id,e.title,e.event_type,e.description,e.venue,e.event_date,e.max_seats,e.registered_count,EXISTS(SELECT 1 FROM event_registrations x WHERE x.event_id=e.id AND x.user_id=?) joined FROM events e WHERE e.event_date>=NOW() ORDER BY e.event_date LIMIT "+limit;
        return rows(c,sql,ps->ps.setInt(1,uid),rs->{Map<String,Object>m=new LinkedHashMap<>();m.put("id",rs.getInt("id"));m.put("title",rs.getString("title"));m.put("type",rs.getString("event_type"));m.put("description",rs.getString("description"));m.put("venue",rs.getString("venue"));m.put("date",rs.getTimestamp("event_date"));m.put("seats",rs.getInt("max_seats"));m.put("registered",rs.getInt("registered_count"));m.put("joined",rs.getBoolean("joined"));return m;});
    }

    private void events(Connection c,int uid,HttpServletResponse r)throws SQLException,IOException{JsonUtil.sendJson(r,200,Map.of("events",eventRows(c,uid,100)));}

    private List<Map<String,Object>> clubRows(Connection c,int uid,int limit)throws SQLException{
        String sql="SELECT c.id,c.name,c.category,c.description,c.logo_url,c.is_verified,COUNT(cm.id) member_count,EXISTS(SELECT 1 FROM club_members x WHERE x.club_id=c.id AND x.user_id=?) joined FROM clubs c LEFT JOIN club_members cm ON cm.club_id=c.id GROUP BY c.id,c.name,c.category,c.description,c.logo_url,c.is_verified ORDER BY c.name LIMIT "+limit;
        return rows(c,sql,ps->ps.setInt(1,uid),rs->{Map<String,Object>m=new LinkedHashMap<>();m.put("id",rs.getInt("id"));m.put("name",rs.getString("name"));m.put("category",rs.getString("category"));m.put("description",rs.getString("description"));m.put("logo",rs.getString("logo_url"));m.put("verified",rs.getBoolean("is_verified"));m.put("members",rs.getInt("member_count"));m.put("joined",rs.getBoolean("joined"));return m;});
    }
    private void clubs(Connection c,int uid,HttpServletResponse r)throws SQLException,IOException{JsonUtil.sendJson(r,200,Map.of("clubs",clubRows(c,uid,100)));}

    private void communities(Connection c,int uid,HttpServletResponse r)throws SQLException,IOException{
        String sql="SELECT c.id,c.name,c.description,c.members_count,EXISTS(SELECT 1 FROM community_members x WHERE x.community_id=c.id AND x.user_id=?) joined FROM communities c ORDER BY c.name";
        JsonUtil.sendJson(r,200,Map.of("communities",rows(c,sql,ps->ps.setInt(1,uid),rs->{Map<String,Object>m=new LinkedHashMap<>();m.put("id",rs.getInt(1));m.put("name",rs.getString(2));m.put("description",rs.getString(3));m.put("members",rs.getInt(4));m.put("joined",rs.getBoolean(5));return m;})));
    }

    private void directory(Connection c,HttpServletRequest req,HttpServletResponse r)throws SQLException,IOException{
        String q=value(req.getParameter("q"),""); String sql="SELECT u.id,u.full_name,u.student_id,u.branch,u.year,u.division,p.profile_photo,p.bio FROM users u LEFT JOIN profiles p ON p.user_id=u.id WHERE 1=1"; List<String> v=new ArrayList<>();
        if(!q.isBlank()){sql+=" AND (LOWER(u.full_name) LIKE LOWER(?) OR LOWER(u.student_id) LIKE LOWER(?) OR LOWER(u.branch) LIKE LOWER(?))";String x="%"+q+"%";v.add(x);v.add(x);v.add(x);} String branch=req.getParameter("branch"),year=req.getParameter("year"),div=req.getParameter("division");
        if(branch!=null&&!branch.isBlank()){sql+=" AND u.branch=?";v.add(branch);} if(year!=null&&!year.isBlank()){sql+=" AND u.year=?";v.add(year);} if(div!=null&&!div.isBlank()){sql+=" AND u.division=?";v.add(div);} sql+=" ORDER BY u.full_name LIMIT 100";
        JsonUtil.sendJson(r,200,Map.of("students",rows(c,sql,ps->{for(int i=0;i<v.size();i++)ps.setString(i+1,v.get(i));},rs->{Map<String,Object>m=new LinkedHashMap<>();m.put("id",rs.getInt(1));m.put("name",rs.getString(2));m.put("studentId",rs.getString(3));m.put("branch",rs.getString(4));m.put("year",rs.getString(5));m.put("division",rs.getString(6));m.put("photo",rs.getString(7));m.put("bio",rs.getString(8));return m;})));
    }

    private void profile(Connection c,HttpServletRequest req,int uid,HttpServletResponse r)throws SQLException,IOException{
        int id=req.getParameter("id")==null?uid:Integer.parseInt(req.getParameter("id"));
        String sql="SELECT u.id,u.full_name,u.college_email,u.student_id,u.branch,u.year,u.division,u.role,u.points,p.profile_photo,p.cover_photo,p.bio,p.linkedin_url,p.github_url,p.website_url FROM users u LEFT JOIN profiles p ON p.user_id=u.id WHERE u.id=?";
        Map<String,Object> m=one(c,sql,ps->ps.setInt(1,id),rs->{Map<String,Object>x=new LinkedHashMap<>();x.put("id",rs.getInt(1));x.put("name",rs.getString(2));x.put("email",rs.getString(3));x.put("studentId",rs.getString(4));x.put("branch",rs.getString(5));x.put("year",rs.getString(6));x.put("division",rs.getString(7));x.put("role",rs.getString(8));x.put("points",rs.getInt(9));x.put("photo",rs.getString(10));x.put("cover",rs.getString(11));x.put("bio",rs.getString(12));x.put("linkedin",rs.getString(13));x.put("github",rs.getString(14));x.put("website",rs.getString(15));return x;});
        if(m==null){error(r,404,"Student not found.");return;}
        JsonUtil.sendJson(r,200,Map.of("profile",m,"skills",simpleUserList(c,"SELECT skill_name,proficiency_level FROM skills WHERE user_id=? ORDER BY skill_name",id),"projects",simpleUserList(c,"SELECT title,description,technologies_used,project_url,github_url FROM projects WHERE user_id=? ORDER BY created_at DESC",id),"achievements",simpleUserList(c,"SELECT title,category,description,date_achieved FROM achievements WHERE user_id=? ORDER BY date_achieved DESC",id),"sports",simpleUserList(c,"SELECT sport,event,year,team,position,result,medal FROM sports WHERE user_id=? ORDER BY year DESC",id),"cultural",simpleUserList(c,"SELECT category,event,year,result_win,award,leadership_role FROM cultural_activities WHERE user_id=? ORDER BY year DESC",id)));
    }

    private void academics(Connection c,int uid,HttpServletResponse r)throws SQLException,IOException{
        JsonUtil.sendJson(r,200,Map.of("courses",rows(c,"SELECT c.id,c.code,c.name,c.credits,e.semester,g.grade,g.grade_points FROM courses c JOIN enrollments e ON e.course_id=c.id AND e.user_id=? LEFT JOIN grades g ON g.enrollment_id=e.id WHERE e.user_id=? ORDER BY c.code",ps->{ps.setInt(1,uid);ps.setInt(2,uid);},rs->{Map<String,Object>m=new LinkedHashMap<>();m.put("id",rs.getInt(1));m.put("code",rs.getString(2));m.put("name",rs.getString(3));m.put("credits",rs.getInt(4));m.put("semester",rs.getString(5));m.put("grade",rs.getString(6));m.put("gradePoints",rs.getDouble(7));return m;}),"attendance",rows(c,"SELECT c.code,c.name,a.attended,a.total FROM attendance a JOIN enrollments e ON e.id=a.enrollment_id JOIN courses c ON c.id=e.course_id WHERE e.user_id=?",ps->ps.setInt(1,uid),rs->{Map<String,Object>m=new LinkedHashMap<>();m.put("code",rs.getString(1));m.put("name",rs.getString(2));m.put("attended",rs.getInt(3));m.put("total",rs.getInt(4));m.put("percentage",rs.getInt(4)==0?0:(rs.getInt(3)*100.0/rs.getInt(4)));return m;}),"gpa",scalarDouble(c,"SELECT COALESCE(SUM(g.grade_points*c.credits)/NULLIF(SUM(c.credits),0),0) FROM grades g JOIN enrollments e ON e.id=g.enrollment_id JOIN courses c ON c.id=e.course_id WHERE e.user_id=?",uid)));
    }

    private void career(Connection c,int uid,HttpServletResponse r)throws SQLException,IOException{
        JsonUtil.sendJson(r,200,Map.of("skills",simpleUserList(c,"SELECT skill_name,proficiency_level,endorsements_count FROM skills WHERE user_id=?",uid),"jobs",rows(c,"SELECT title,company,location,job_type,description,apply_url,deadline FROM jobs WHERE deadline IS NULL OR deadline>=CURDATE() ORDER BY deadline IS NULL,deadline LIMIT 20",ps->{},rs->{Map<String,Object>m=new LinkedHashMap<>();m.put("title",rs.getString(1));m.put("company",rs.getString(2));m.put("location",rs.getString(3));m.put("type",rs.getString(4));m.put("description",rs.getString(5));m.put("url",rs.getString(6));m.put("deadline",rs.getDate(7));return m;}),"projects",simpleUserList(c,"SELECT title,description,technologies_used,project_url,github_url FROM projects WHERE user_id=? ORDER BY created_at DESC",uid),"internships",simpleUserList(c,"SELECT company_name,role_title,start_date,end_date,is_current,description,certificate_url FROM internships WHERE user_id=? ORDER BY start_date DESC",uid),"certificates",simpleUserList(c,"SELECT title,issuing_organization,issue_date,credential_url FROM certificates WHERE user_id=? ORDER BY issue_date DESC",uid)));
    }

    private void sports(Connection c,int uid,HttpServletResponse r)throws SQLException,IOException{JsonUtil.sendJson(r,200,Map.of("sports",simpleUserList(c,"SELECT sport,event,year,team,position,result,medal,certificate FROM sports WHERE user_id=? ORDER BY year DESC",uid),"cultural",simpleUserList(c,"SELECT category,event,year,result_win,award,leadership_role FROM cultural_activities WHERE user_id=? ORDER BY year DESC",uid)));}

    private void leaderboard(Connection c,HttpServletRequest req,HttpServletResponse r)throws SQLException,IOException{String cat=value(req.getParameter("category"),"OVERALL").toUpperCase();String sql="SELECT l.rank_position,l.points,u.full_name,u.branch,u.year,p.profile_photo FROM leaderboard l JOIN users u ON u.id=l.user_id LEFT JOIN profiles p ON p.user_id=u.id WHERE l.category=? ORDER BY l.rank_position,l.points DESC LIMIT 50";JsonUtil.sendJson(r,200,Map.of("category",cat,"leaders",rows(c,sql,ps->ps.setString(1,cat),rs->{Map<String,Object>m=new LinkedHashMap<>();m.put("rank",rs.getInt(1));m.put("points",rs.getInt(2));m.put("name",rs.getString(3));m.put("branch",rs.getString(4));m.put("year",rs.getString(5));m.put("photo",rs.getString(6));return m;})));}

    private void notifications(Connection c,int uid,HttpServletResponse r)throws SQLException,IOException{JsonUtil.sendJson(r,200,Map.of("notifications",notificationRows(c,uid,50)));}
    private List<Map<String,Object>> notificationRows(Connection c,int uid,int limit)throws SQLException{return rows(c,"SELECT id,type,content,target_url,is_read,created_at FROM notifications WHERE user_id=? ORDER BY created_at DESC LIMIT "+limit,ps->ps.setInt(1,uid),rs->{Map<String,Object>m=new LinkedHashMap<>();m.put("id",rs.getInt(1));m.put("type",rs.getString(2));m.put("content",rs.getString(3));m.put("url",rs.getString(4));m.put("read",rs.getBoolean(5));m.put("createdAt",rs.getTimestamp(6));return m;});}

    private void messages(Connection c,int uid,HttpServletRequest req,HttpServletResponse r)throws SQLException,IOException{String sql="SELECT m.id,m.sender_id,m.receiver_id,m.message_text,m.is_read,m.created_at,u.full_name sender_name FROM messages m JOIN users u ON u.id=m.sender_id WHERE m.sender_id=? OR m.receiver_id=? ORDER BY m.created_at DESC LIMIT 100";JsonUtil.sendJson(r,200,Map.of("messages",rows(c,sql,ps->{ps.setInt(1,uid);ps.setInt(2,uid);},rs->{Map<String,Object>m=new LinkedHashMap<>();m.put("id",rs.getInt(1));m.put("senderId",rs.getInt(2));m.put("receiverId",rs.getInt(3));m.put("text",rs.getString(4));m.put("read",rs.getBoolean(5));m.put("createdAt",rs.getTimestamp(6));m.put("senderName",rs.getString(7));return m;})));}

    private void feed(Connection c,int uid,HttpServletResponse r)throws SQLException,IOException{String sql="SELECT p.id,p.caption,p.post_type,p.media_url,p.created_at,u.full_name,u.id user_id,(SELECT COUNT(*) FROM likes l WHERE l.post_id=p.id) likes,(SELECT COUNT(*) FROM comments cm WHERE cm.post_id=p.id) comments,EXISTS(SELECT 1 FROM likes x WHERE x.post_id=p.id AND x.user_id=?) liked FROM posts p JOIN users u ON u.id=p.user_id ORDER BY p.created_at DESC LIMIT 50";JsonUtil.sendJson(r,200,Map.of("posts",rows(c,sql,ps->ps.setInt(1,uid),rs->{Map<String,Object>m=new LinkedHashMap<>();m.put("id",rs.getInt(1));m.put("caption",rs.getString(2));m.put("type",rs.getString(3));m.put("media",rs.getString(4));m.put("createdAt",rs.getTimestamp(5));m.put("author",rs.getString(6));m.put("authorId",rs.getInt(7));m.put("likes",rs.getInt(8));m.put("comments",rs.getInt(9));m.put("liked",rs.getBoolean(10));return m;})));}

    private void campus(Connection c,HttpServletResponse r)throws SQLException,IOException{String sql="SELECT id,name,category,description,x_pos,y_pos,width,height,icon FROM campus_locations ORDER BY id";JsonUtil.sendJson(r,200,Map.of("locations",rows(c,sql,ps->{},rs->{Map<String,Object>m=new LinkedHashMap<>();m.put("id",rs.getInt(1));m.put("name",rs.getString(2));m.put("category",rs.getString(3));m.put("description",rs.getString(4));m.put("x",rs.getInt(5));m.put("y",rs.getInt(6));m.put("width",rs.getInt(7));m.put("height",rs.getInt(8));m.put("icon",rs.getString(9));return m;})));}

    private void membership(Connection c,int uid,int entityId,boolean join,boolean community,HttpServletResponse r)throws SQLException,IOException{
        if(entityId<=0){error(r,400,"Invalid id.");return;}String table=community?"community_members":"club_members", key=community?"community_id":"club_id";String exists="SELECT COUNT(*) FROM "+table+" WHERE "+key+"=? AND user_id=?";
        if(join){try(PreparedStatement p=c.prepareStatement("INSERT IGNORE INTO "+table+" ("+key+",user_id,role) VALUES (?,?,'MEMBER')")){p.setInt(1,entityId);p.setInt(2,uid);p.executeUpdate();}}else{try(PreparedStatement p=c.prepareStatement("DELETE FROM "+table+" WHERE "+key+"=? AND user_id=?")){p.setInt(1,entityId);p.setInt(2,uid);p.executeUpdate();}}
        JsonUtil.sendJson(r,200,Map.of("success",true,"joined",scalarInt(c,exists,entityId,uid)>0,"message",join?"Joined successfully.":"Left successfully."));
    }

    private void eventRegistration(Connection c,int uid,int eventId,boolean join,HttpServletResponse r)throws SQLException,IOException{
        if(eventId<=0){error(r,400,"Invalid event.");return;}if(join){int max=scalarInt(c,"SELECT max_seats FROM events WHERE id=?",eventId);int count=scalarInt(c,"SELECT COUNT(*) FROM event_registrations WHERE event_id=? AND status='REGISTERED'",eventId);if(max>0&&count>=max){error(r,409,"This event is full.");return;}try(PreparedStatement p=c.prepareStatement("INSERT INTO event_registrations(event_id,user_id,status) VALUES(?,?,'REGISTERED') ON DUPLICATE KEY UPDATE status='REGISTERED'")){p.setInt(1,eventId);p.setInt(2,uid);p.executeUpdate();}}else{try(PreparedStatement p=c.prepareStatement("UPDATE event_registrations SET status='CANCELLED' WHERE event_id=? AND user_id=?")){p.setInt(1,eventId);p.setInt(2,uid);p.executeUpdate();}}syncEventCount(c,eventId);JsonUtil.sendJson(r,200,Map.of("success",true,"registered",join));
    }

    private void follow(Connection c,int uid,int target,boolean on,HttpServletResponse r)throws SQLException,IOException{if(target<=0||target==uid){error(r,400,"Invalid user.");return;}String sql=on?"INSERT IGNORE INTO followers(follower_id,following_id) VALUES(?,?)":"DELETE FROM followers WHERE follower_id=? AND following_id=?";try(PreparedStatement p=c.prepareStatement(sql)){p.setInt(1,uid);p.setInt(2,target);p.executeUpdate();}JsonUtil.sendJson(r,200,Map.of("success",true,"following",on));}
    private void comment(Connection c,int uid,int post,String text,HttpServletResponse r)throws SQLException,IOException{
        if(post<=0||text==null||text.isBlank()){error(r,400,"Post and comment are required.");return;}
        try(PreparedStatement p=c.prepareStatement("INSERT INTO comments(post_id,user_id,comment_text) VALUES(?,?,?)")){p.setInt(1,post);p.setInt(2,uid);p.setString(3,text.trim());p.executeUpdate();}
        JsonUtil.sendJson(r,201,Map.of("success",true));
    }
    private void like(Connection c,int uid,int post,boolean on,HttpServletResponse r)throws SQLException,IOException{String sql=on?"INSERT IGNORE INTO likes(post_id,user_id) VALUES(?,?)":"DELETE FROM likes WHERE post_id=? AND user_id=?";try(PreparedStatement p=c.prepareStatement(sql)){p.setInt(1,post);p.setInt(2,uid);p.executeUpdate();}JsonUtil.sendJson(r,200,Map.of("success",true,"liked",on,"count",scalarInt(c,"SELECT COUNT(*) FROM likes WHERE post_id=?",post)));}
    private void bookmark(Connection c,int uid,int post,HttpServletResponse r)throws SQLException,IOException{int exists=scalarInt(c,"SELECT COUNT(*) FROM bookmarks WHERE user_id=? AND post_id=?",uid,post);String sql=exists==0?"INSERT INTO bookmarks(user_id,post_id) VALUES(?,?)":"DELETE FROM bookmarks WHERE user_id=? AND post_id=?";try(PreparedStatement p=c.prepareStatement(sql)){p.setInt(1,uid);p.setInt(2,post);p.executeUpdate();}JsonUtil.sendJson(r,200,Map.of("success",true,"bookmarked",exists==0));}
    private void sendMessage(Connection c,int uid,int receiver,String text,HttpServletResponse r)throws SQLException,IOException{if(receiver<=0||text==null||text.isBlank()){error(r,400,"Receiver and message are required.");return;}try(PreparedStatement p=c.prepareStatement("INSERT INTO messages(sender_id,receiver_id,message_text) VALUES(?,?,?)")){p.setInt(1,uid);p.setInt(2,receiver);p.setString(3,text.trim());p.executeUpdate();}try(PreparedStatement p=c.prepareStatement("INSERT INTO notifications(user_id,actor_id,type,content,target_url) VALUES(?,?, 'MESSAGE', ?, 'messages.html')")){p.setInt(1,receiver);p.setInt(2,uid);p.setString(3,"You received a new message.");p.executeUpdate();}JsonUtil.sendJson(r,200,Map.of("success",true));}
    private void createPost(Connection c,int uid,String caption,String type,HttpServletResponse r)throws SQLException,IOException{if(caption==null||caption.isBlank()){error(r,400,"Post text is required.");return;}try(PreparedStatement p=c.prepareStatement("INSERT INTO posts(user_id,caption,post_type) VALUES(?,?,?)")){p.setInt(1,uid);p.setString(2,caption.trim());p.setString(3,value(type,"TEXT"));p.executeUpdate();}JsonUtil.sendJson(r,201,Map.of("success",true));}
    private void markNotification(Connection c,int uid,int id,HttpServletResponse r)throws SQLException,IOException{try(PreparedStatement p=c.prepareStatement("UPDATE notifications SET is_read=1 WHERE id=? AND user_id=?")){p.setInt(1,id);p.setInt(2,uid);p.executeUpdate();}JsonUtil.sendJson(r,200,Map.of("success",true));}

    private void syncEventCount(Connection c,int id)throws SQLException{try(PreparedStatement p=c.prepareStatement("UPDATE events SET registered_count=(SELECT COUNT(*) FROM event_registrations WHERE event_id=? AND status='REGISTERED') WHERE id=?")){p.setInt(1,id);p.setInt(2,id);p.executeUpdate();}}
    private int count(Connection c,String table,String col,int val)throws SQLException{return scalarInt(c,"SELECT COUNT(*) FROM "+table+" WHERE "+col+"=?",val);}
    private void syncMemberCount(Connection c,int club)throws SQLException{try(PreparedStatement p=c.prepareStatement("UPDATE clubs SET members_count=(SELECT COUNT(*) FROM club_members WHERE club_id=?) WHERE id=?")){p.setInt(1,club);p.setInt(2,club);p.executeUpdate();}}
    private int id(Map<String,String>m,String k){try{return Integer.parseInt(value(m.get(k),"0"));}catch(Exception e){return 0;}}
    private String value(String s,String d){return s==null||s.isBlank()?d:s.trim();}
    private void error(HttpServletResponse r,int code,String msg)throws IOException{JsonUtil.sendJsonResponse(r,code,false,msg,null);}

    @FunctionalInterface private interface Binder{void bind(PreparedStatement p)throws SQLException;}
    @FunctionalInterface private interface Mapper{Map<String,Object> map(ResultSet r)throws SQLException;}
    private List<Map<String,Object>> rows(Connection c,String sql,Binder b,Mapper m)throws SQLException{List<Map<String,Object>> out=new ArrayList<>();try(PreparedStatement p=c.prepareStatement(sql)){b.bind(p);try(ResultSet rs=p.executeQuery()){while(rs.next())out.add(m.map(rs));}}return out;}
    private Map<String,Object> one(Connection c,String sql,Binder b,Mapper m)throws SQLException{try(PreparedStatement p=c.prepareStatement(sql)){b.bind(p);try(ResultSet rs=p.executeQuery()){return rs.next()?m.map(rs):null;}}}
    private int scalarInt(Connection c,String sql,int... vals)throws SQLException{try(PreparedStatement p=c.prepareStatement(sql)){for(int i=0;i<vals.length;i++)p.setInt(i+1,vals[i]);try(ResultSet r=p.executeQuery()){return r.next()?r.getInt(1):0;}}}
    private double scalarDouble(Connection c,String sql,int... vals)throws SQLException{try(PreparedStatement p=c.prepareStatement(sql)){for(int i=0;i<vals.length;i++)p.setInt(i+1,vals[i]);try(ResultSet r=p.executeQuery()){return r.next()?r.getDouble(1):0;}}}
    private List<Map<String,Object>> simpleUserList(Connection c,String sql,int uid)throws SQLException{return rows(c,sql,p->p.setInt(1,uid),rs->{Map<String,Object>m=new LinkedHashMap<>();ResultSetMetaData md=rs.getMetaData();for(int i=1;i<=md.getColumnCount();i++)m.put(md.getColumnLabel(i),rs.getObject(i));return m;});}
}
