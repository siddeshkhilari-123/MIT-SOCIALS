package com.mitsocials.servlet;

import com.mitsocials.util.DBConnection;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/api/health")
public class HealthServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        try (Connection c = DBConnection.getConnection();
             PreparedStatement p = c.prepareStatement("SELECT COUNT(*) FROM users");
             ResultSet rs = p.executeQuery()) {
            rs.next();
            resp.setStatus(HttpServletResponse.SC_OK);
            resp.getWriter().write("{\"ok\":true,\"users\":" + rs.getInt(1) + "}");
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("{\"ok\":false,\"error\":\"" + escape(e.getMessage()) + "\"}");
        }
    }

    private static String escape(String s) {
        if (s == null) return "unknown";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\r", " ").replace("\n", " ");
    }
}
