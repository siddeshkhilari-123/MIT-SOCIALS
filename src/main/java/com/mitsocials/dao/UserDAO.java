package com.mitsocials.dao;

import com.mitsocials.model.User;
import com.mitsocials.util.DBConnection;

import java.sql.*;

public class UserDAO {

    /**
     * Inserts a new user into the database using JDBC PreparedStatements.
     * Sets generated ID on the User object upon success.
     */
    public boolean createUser(User user) {
        String sql = "INSERT INTO users (college_email, password_hash, student_id, full_name, branch, year, division, role) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, user.getCollegeEmail());
            stmt.setString(2, user.getPasswordHash());
            stmt.setString(3, user.getStudentId());
            stmt.setString(4, user.getFullName());
            stmt.setString(5, user.getBranch());
            stmt.setString(6, user.getYear());
            stmt.setString(7, user.getDivision());
            stmt.setString(8, user.getRole() != null ? user.getRole() : "STUDENT");

            int rows = stmt.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        user.setId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            System.err.println("UserDAO.createUser error: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Finds a user by college email.
     */
    public User findByEmail(String collegeEmail) {
        String sql = "SELECT id, college_email, password_hash, student_id, full_name, branch, year, division, role, created_at, updated_at " +
                     "FROM users WHERE LOWER(college_email) = LOWER(?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, collegeEmail.trim());
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return extractUserFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("UserDAO.findByEmail error: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Finds a user by ID.
     */
    public User findById(int id) {
        String sql = "SELECT id, college_email, password_hash, student_id, full_name, branch, year, division, role, created_at, updated_at " +
                     "FROM users WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return extractUserFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("UserDAO.findById error: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Finds a user by Student ID (PRN/Roll No).
     */
    public User findByStudentId(String studentId) {
        String sql = "SELECT id, college_email, password_hash, student_id, full_name, branch, year, division, role, created_at, updated_at " +
                     "FROM users WHERE LOWER(student_id) = LOWER(?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, studentId.trim());
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return extractUserFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("UserDAO.findByStudentId error: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Checks if a college email is already registered.
     */
    public boolean existsByEmail(String collegeEmail) {
        String sql = "SELECT 1 FROM users WHERE LOWER(college_email) = LOWER(?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, collegeEmail.trim());
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            System.err.println("UserDAO.existsByEmail error: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Checks if a student ID is already registered.
     */
    public boolean existsByStudentId(String studentId) {
        String sql = "SELECT 1 FROM users WHERE LOWER(student_id) = LOWER(?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, studentId.trim());
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            System.err.println("UserDAO.existsByStudentId error: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    private User extractUserFromResultSet(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setCollegeEmail(rs.getString("college_email"));
        user.setPasswordHash(rs.getString("password_hash"));
        user.setStudentId(rs.getString("student_id"));
        user.setFullName(rs.getString("full_name"));
        user.setBranch(rs.getString("branch"));
        user.setYear(rs.getString("year"));
        user.setDivision(rs.getString("division"));
        user.setRole(rs.getString("role"));
        user.setCreatedAt(rs.getTimestamp("created_at"));
        user.setUpdatedAt(rs.getTimestamp("updated_at"));
        return user;
    }
}
