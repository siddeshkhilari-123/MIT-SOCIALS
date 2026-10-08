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

@WebServlet("/api/clubs")
public class ClubsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer userId = currentUserId(request);
        if (userId == null) {
            JsonUtil.sendJsonResponse(response, HttpServletResponse.SC_UNAUTHORIZED, false,
                    "Please login to access clubs.", null);
            return;
        }

        String clubIdParam = request.getParameter("id");
        try (Connection conn = DBConnection.getConnection()) {
            if (clubIdParam != null && !clubIdParam.isBlank()) {
                int clubId = Integer.parseInt(clubIdParam);
                sendClubDetails(conn, response, userId, clubId);
            } else {
                sendClubList(conn, response, userId);
            }
        } catch (NumberFormatException e) {
            JsonUtil.sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false,
                    "Invalid club id.", null);
        } catch (SQLException e) {
            e.printStackTrace();
            JsonUtil.sendJsonResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, false,
                    "Unable to load clubs.", null);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer userId = currentUserId(request);
        if (userId == null) {
            JsonUtil.sendJsonResponse(response, HttpServletResponse.SC_UNAUTHORIZED, false,
                    "Please login first.", null);
            return;
        }

        Map<String, String> params = JsonUtil.parseRequestBody(request);
        String action = params.getOrDefault("action", "").toLowerCase(Locale.ROOT);
        int clubId;
        try {
            clubId = Integer.parseInt(params.getOrDefault("club_id", "0"));
        } catch (NumberFormatException e) {
            clubId = 0;
        }

        if (clubId <= 0 || !(action.equals("join") || action.equals("leave"))) {
            JsonUtil.sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false,
                    "Valid club_id and action (join/leave) are required.", null);
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            if (!clubExists(conn, clubId)) {
                JsonUtil.sendJsonResponse(response, HttpServletResponse.SC_NOT_FOUND, false,
                        "Club not found.", null);
                return;
            }

            if (action.equals("join")) {
                String sql = "INSERT IGNORE INTO club_members (club_id, user_id, role) VALUES (?, ?, 'MEMBER')";
                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setInt(1, clubId);
                    stmt.setInt(2, userId);
                    stmt.executeUpdate();
                }
            } else {
                if (isClubLead(conn, clubId, userId)) {
                    JsonUtil.sendJsonResponse(response, HttpServletResponse.SC_CONFLICT, false,
                            "The club lead cannot leave their own club.", null);
                    return;
                }
                String sql = "DELETE FROM club_members WHERE club_id = ? AND user_id = ?";
                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setInt(1, clubId);
                    stmt.setInt(2, userId);
                    stmt.executeUpdate();
                }
            }

            syncMemberCount(conn, clubId);

            Map<String, Object> extra = new HashMap<>();
            extra.put("joined", isMember(conn, clubId, userId));
            extra.put("memberCount", memberCount(conn, clubId));
            JsonUtil.sendJsonResponse(response, HttpServletResponse.SC_OK, true,
                    action.equals("join") ? "You joined the club." : "You left the club.", extra);

        } catch (SQLException e) {
            e.printStackTrace();
            JsonUtil.sendJsonResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, false,
                    "Could not update club membership.", null);
        }
    }

    private void sendClubList(Connection conn, HttpServletResponse response, int userId) throws SQLException, IOException {
        String sql = """
            SELECT c.id, c.name, c.category, c.description, c.logo_url, c.banner_url,
                   c.is_verified, c.achievements, u.full_name AS lead_name,
                   COUNT(cm.id) AS member_count,
                   EXISTS(SELECT 1 FROM club_members x WHERE x.club_id = c.id AND x.user_id = ?) AS joined
            FROM clubs c
            JOIN users u ON u.id = c.lead_id
            LEFT JOIN club_members cm ON cm.club_id = c.id
            GROUP BY c.id, c.name, c.category, c.description, c.logo_url, c.banner_url,
                     c.is_verified, c.achievements, u.full_name
            ORDER BY c.name
            """;

        List<Map<String, Object>> clubs = new ArrayList<>();
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) clubs.add(clubFromResult(rs));
            }
        }

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("clubs", clubs);
        result.put("count", clubs.size());
        JsonUtil.sendJson(response, HttpServletResponse.SC_OK, result);
    }

    private void sendClubDetails(Connection conn, HttpServletResponse response, int userId, int clubId)
            throws SQLException, IOException {
        String sql = """
            SELECT c.id, c.name, c.category, c.description, c.logo_url, c.banner_url,
                   c.is_verified, c.achievements, u.full_name AS lead_name,
                   COUNT(cm.id) AS member_count,
                   EXISTS(SELECT 1 FROM club_members x WHERE x.club_id = c.id AND x.user_id = ?) AS joined
            FROM clubs c
            JOIN users u ON u.id = c.lead_id
            LEFT JOIN club_members cm ON cm.club_id = c.id
            WHERE c.id = ?
            GROUP BY c.id, c.name, c.category, c.description, c.logo_url, c.banner_url,
                     c.is_verified, c.achievements, u.full_name
            """;

        Map<String, Object> club = null;
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, clubId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) club = clubFromResult(rs);
            }
        }

        if (club == null) {
            JsonUtil.sendJsonResponse(response, HttpServletResponse.SC_NOT_FOUND, false,
                    "Club not found.", null);
            return;
        }

        List<Map<String, Object>> posts = new ArrayList<>();
        String postSql = """
            SELECT cp.id, cp.title, cp.content, cp.post_type, cp.media_url, cp.created_at,
                   u.full_name AS author_name
            FROM club_posts cp
            JOIN users u ON u.id = cp.author_id
            WHERE cp.club_id = ?
            ORDER BY cp.created_at DESC
            LIMIT 20
            """;
        try (PreparedStatement stmt = conn.prepareStatement(postSql)) {
            stmt.setInt(1, clubId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> post = new HashMap<>();
                    post.put("id", rs.getInt("id"));
                    post.put("title", rs.getString("title"));
                    post.put("content", rs.getString("content"));
                    post.put("postType", rs.getString("post_type"));
                    post.put("mediaUrl", rs.getString("media_url"));
                    post.put("createdAt", rs.getTimestamp("created_at"));
                    post.put("authorName", rs.getString("author_name"));
                    posts.add(post);
                }
            }
        }

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("club", club);
        result.put("posts", posts);
        JsonUtil.sendJson(response, HttpServletResponse.SC_OK, result);
    }

    private Map<String, Object> clubFromResult(ResultSet rs) throws SQLException {
        Map<String, Object> club = new HashMap<>();
        club.put("id", rs.getInt("id"));
        club.put("name", rs.getString("name"));
        club.put("category", rs.getString("category"));
        club.put("description", rs.getString("description"));
        club.put("logoUrl", rs.getString("logo_url"));
        club.put("bannerUrl", rs.getString("banner_url"));
        club.put("verified", rs.getBoolean("is_verified"));
        club.put("achievements", rs.getString("achievements"));
        club.put("leadName", rs.getString("lead_name"));
        club.put("memberCount", rs.getInt("member_count"));
        club.put("joined", rs.getBoolean("joined"));
        return club;
    }

    private boolean clubExists(Connection conn, int clubId) throws SQLException {
        try (PreparedStatement stmt = conn.prepareStatement("SELECT 1 FROM clubs WHERE id=?")) {
            stmt.setInt(1, clubId);
            try (ResultSet rs = stmt.executeQuery()) { return rs.next(); }
        }
    }

    private boolean isMember(Connection conn, int clubId, int userId) throws SQLException {
        try (PreparedStatement stmt = conn.prepareStatement(
                "SELECT 1 FROM club_members WHERE club_id=? AND user_id=?")) {
            stmt.setInt(1, clubId); stmt.setInt(2, userId);
            try (ResultSet rs = stmt.executeQuery()) { return rs.next(); }
        }
    }

    private boolean isClubLead(Connection conn, int clubId, int userId) throws SQLException {
        try (PreparedStatement stmt = conn.prepareStatement(
                "SELECT 1 FROM clubs WHERE id=? AND lead_id=?")) {
            stmt.setInt(1, clubId); stmt.setInt(2, userId);
            try (ResultSet rs = stmt.executeQuery()) { return rs.next(); }
        }
    }

    private int memberCount(Connection conn, int clubId) throws SQLException {
        try (PreparedStatement stmt = conn.prepareStatement(
                "SELECT COUNT(*) FROM club_members WHERE club_id=?")) {
            stmt.setInt(1, clubId);
            try (ResultSet rs = stmt.executeQuery()) { rs.next(); return rs.getInt(1); }
        }
    }

    private void syncMemberCount(Connection conn, int clubId) throws SQLException {
        try (PreparedStatement stmt = conn.prepareStatement(
                "UPDATE clubs SET members_count=(SELECT COUNT(*) FROM club_members WHERE club_id=?) WHERE id=?")) {
            stmt.setInt(1, clubId); stmt.setInt(2, clubId);
            stmt.executeUpdate();
        }
    }

    private Integer currentUserId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return null;
        Object id = session.getAttribute("userId");
        return id instanceof Integer ? (Integer) id : null;
    }
}
