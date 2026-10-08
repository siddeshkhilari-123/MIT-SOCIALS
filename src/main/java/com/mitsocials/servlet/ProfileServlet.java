package com.mitsocials.servlet;

import com.mitsocials.dao.ProfileDAO;
import com.mitsocials.dao.UserDAO;
import com.mitsocials.model.Profile;
import com.mitsocials.model.User;
import com.mitsocials.util.JsonUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/api/profile")
public class ProfileServlet extends HttpServlet {

    private UserDAO userDAO;
    private ProfileDAO profileDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        profileDAO = new ProfileDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            JsonUtil.sendJsonResponse(response, HttpServletResponse.SC_UNAUTHORIZED, false, 
                    "Unauthorized access. Please login.", null);
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        User user = userDAO.findById(userId);
        Profile profile = profileDAO.findByUserId(userId);

        if (user == null) {
            JsonUtil.sendJsonResponse(response, HttpServletResponse.SC_NOT_FOUND, false, 
                    "User profile not found.", null);
            return;
        }

        // If profile record doesn't exist yet, create default one
        if (profile == null) {
            profile = new Profile(userId, null, null, "Student at MIT.", user.getBranch(), user.getYear(), user.getDivision());
            profileDAO.createProfile(profile);
            profile = profileDAO.findByUserId(userId);
        }

        Map<String, Object> extra = new HashMap<>();
        extra.put("user", userToMap(user));
        extra.put("profile", profileToMap(profile));

        JsonUtil.sendJsonResponse(response, HttpServletResponse.SC_OK, true, 
                "Profile retrieved successfully.", extra);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            JsonUtil.sendJsonResponse(response, HttpServletResponse.SC_UNAUTHORIZED, false, 
                    "Unauthorized access. Please login.", null);
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        Map<String, String> params = JsonUtil.parseRequestBody(request);

        Profile profile = profileDAO.findByUserId(userId);
        User user = userDAO.findById(userId);

        if (profile == null) {
            profile = new Profile();
            profile.setUserId(userId);
            profile.setBranch(user.getBranch());
            profile.setYear(user.getYear());
            profile.setDivision(user.getDivision());
        }

        if (params.containsKey("bio")) {
            profile.setBio(params.get("bio"));
        }
        if (params.containsKey("profile_photo")) {
            profile.setProfilePhoto(params.get("profile_photo"));
        }
        if (params.containsKey("cover_photo")) {
            profile.setCoverPhoto(params.get("cover_photo"));
        }

        boolean updated = profileDAO.updateProfile(profile);

        if (updated) {
            Map<String, Object> extra = new HashMap<>();
            extra.put("user", userToMap(user));
            extra.put("profile", profileToMap(profile));
            JsonUtil.sendJsonResponse(response, HttpServletResponse.SC_OK, true, 
                    "Profile updated successfully.", extra);
        } else {
            JsonUtil.sendJsonResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, false, 
                    "Failed to update profile.", null);
        }
    }

    private Map<String, Object> userToMap(User user) {
        Map<String, Object> m = new HashMap<>();
        m.put("id", user.getId());
        m.put("collegeEmail", user.getCollegeEmail());
        m.put("studentId", user.getStudentId());
        m.put("fullName", user.getFullName());
        m.put("branch", user.getBranch());
        m.put("year", user.getYear());
        m.put("division", user.getDivision());
        m.put("role", user.getRole());
        return m;
    }

    private Map<String, Object> profileToMap(Profile profile) {
        Map<String, Object> m = new HashMap<>();
        m.put("id", profile.getId());
        m.put("userId", profile.getUserId());
        m.put("profilePhoto", profile.getProfilePhoto());
        m.put("coverPhoto", profile.getCoverPhoto());
        m.put("bio", profile.getBio());
        m.put("branch", profile.getBranch());
        m.put("year", profile.getYear());
        m.put("division", profile.getDivision());
        return m;
    }
}
