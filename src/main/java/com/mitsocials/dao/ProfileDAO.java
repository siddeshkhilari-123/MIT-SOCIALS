package com.mitsocials.dao;

import com.mitsocials.model.Profile;
import com.mitsocials.util.DBConnection;

import java.sql.*;

public class ProfileDAO {

    /**
     * Inserts a new profile record for a user.
     */
    public boolean createProfile(Profile profile) {
        String sql = "INSERT INTO profiles (user_id, profile_photo, cover_photo, bio, branch, year, division) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, profile.getUserId());
            stmt.setString(2, profile.getProfilePhoto());
            stmt.setString(3, profile.getCoverPhoto());
            stmt.setString(4, profile.getBio());
            stmt.setString(5, profile.getBranch());
            stmt.setString(6, profile.getYear());
            stmt.setString(7, profile.getDivision());

            int rows = stmt.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        profile.setId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            System.err.println("ProfileDAO.createProfile error: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Finds a profile by User ID.
     */
    public Profile findByUserId(int userId) {
        String sql = "SELECT id, user_id, profile_photo, cover_photo, bio, branch, year, division, created_at, updated_at " +
                     "FROM profiles WHERE user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return extractProfileFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("ProfileDAO.findByUserId error: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Updates profile details (bio, profile_photo, cover_photo, branch, year, division).
     */
    public boolean updateProfile(Profile profile) {
        String sql = "UPDATE profiles SET profile_photo = ?, cover_photo = ?, bio = ?, " +
                     "branch = ?, year = ?, division = ? WHERE user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, profile.getProfilePhoto());
            stmt.setString(2, profile.getCoverPhoto());
            stmt.setString(3, profile.getBio());
            stmt.setString(4, profile.getBranch());
            stmt.setString(5, profile.getYear());
            stmt.setString(6, profile.getDivision());
            stmt.setInt(7, profile.getUserId());

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("ProfileDAO.updateProfile error: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    private Profile extractProfileFromResultSet(ResultSet rs) throws SQLException {
        Profile profile = new Profile();
        profile.setId(rs.getInt("id"));
        profile.setUserId(rs.getInt("user_id"));
        profile.setProfilePhoto(rs.getString("profile_photo"));
        profile.setCoverPhoto(rs.getString("cover_photo"));
        profile.setBio(rs.getString("bio"));
        profile.setBranch(rs.getString("branch"));
        profile.setYear(rs.getString("year"));
        profile.setDivision(rs.getString("division"));
        profile.setCreatedAt(rs.getTimestamp("created_at"));
        profile.setUpdatedAt(rs.getTimestamp("updated_at"));
        return profile;
    }
}
