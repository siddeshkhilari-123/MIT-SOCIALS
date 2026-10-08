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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/api/directory")
public class StudentDirectoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            JsonUtil.sendJsonResponse(response, HttpServletResponse.SC_UNAUTHORIZED, false,
                    "Please login to access the student directory.", null);
            return;
        }

        String search = trim(request.getParameter("search"));
        String branch = trim(request.getParameter("branch"));
        String year = trim(request.getParameter("year"));
        String division = trim(request.getParameter("division"));

        StringBuilder sql = new StringBuilder("""
            SELECT u.id, u.full_name, u.student_id, u.college_email, u.branch, u.year, u.division, u.role,
                   p.profile_photo, p.bio
            FROM users u
            LEFT JOIN profiles p ON p.user_id = u.id
            WHERE 1=1
            """);
        List<String> values = new ArrayList<>();

        if (!search.isEmpty()) {
            sql.append(" AND (LOWER(u.full_name) LIKE LOWER(?) OR LOWER(u.student_id) LIKE LOWER(?) OR LOWER(u.branch) LIKE LOWER(?))");
            String q = "%" + search + "%";
            values.add(q); values.add(q); values.add(q);
        }
        if (!branch.isEmpty()) { sql.append(" AND u.branch = ?"); values.add(branch); }
        if (!year.isEmpty()) { sql.append(" AND u.year = ?"); values.add(year); }
        if (!division.isEmpty()) { sql.append(" AND u.division = ?"); values.add(division); }

        sql.append(" ORDER BY u.full_name ASC LIMIT 100");

        List<Map<String, Object>> students = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < values.size(); i++) stmt.setString(i + 1, values.get(i));

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> student = new HashMap<>();
                    student.put("id", rs.getInt("id"));
                    student.put("fullName", rs.getString("full_name"));
                    student.put("studentId", rs.getString("student_id"));
                    student.put("collegeEmail", rs.getString("college_email"));
                    student.put("branch", rs.getString("branch"));
                    student.put("year", rs.getString("year"));
                    student.put("division", rs.getString("division"));
                    student.put("role", rs.getString("role"));
                    student.put("profilePhoto", rs.getString("profile_photo"));
                    student.put("bio", rs.getString("bio"));
                    students.add(student);
                }
            }

            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("students", students);
            result.put("count", students.size());
            JsonUtil.sendJson(response, HttpServletResponse.SC_OK, result);

        } catch (SQLException e) {
            e.printStackTrace();
            JsonUtil.sendJsonResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, false,
                    "Unable to load the student directory.", null);
        }
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
