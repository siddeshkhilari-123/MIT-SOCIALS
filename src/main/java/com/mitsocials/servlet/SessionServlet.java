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

@WebServlet("/api/session")
public class SessionServlet extends HttpServlet {

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
            Map<String, Object> extra = new HashMap<>();
            extra.put("loggedIn", false);
            JsonUtil.sendJsonResponse(response, HttpServletResponse.SC_OK, false, 
                    "No active session found.", extra);
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        User user = userDAO.findById(userId);

        if (user == null) {
            session.invalidate();
            Map<String, Object> extra = new HashMap<>();
            extra.put("loggedIn", false);
            JsonUtil.sendJsonResponse(response, HttpServletResponse.SC_OK, false, 
                    "User not found.", extra);
            return;
        }

        Profile profile = profileDAO.findByUserId(userId);

        Map<String, Object> userData = new HashMap<>();
        userData.put("id", user.getId());
        userData.put("collegeEmail", user.getCollegeEmail());
        userData.put("studentId", user.getStudentId());
        userData.put("fullName", user.getFullName());
        userData.put("branch", user.getBranch());
        userData.put("year", user.getYear());
        userData.put("division", user.getDivision());
        userData.put("role", user.getRole());

        Map<String, Object> profileData = new HashMap<>();
        if (profile != null) {
            profileData.put("id", profile.getId());
            profileData.put("profilePhoto", profile.getProfilePhoto());
            profileData.put("coverPhoto", profile.getCoverPhoto());
            profileData.put("bio", profile.getBio());
            profileData.put("branch", profile.getBranch());
            profileData.put("year", profile.getYear());
            profileData.put("division", profile.getDivision());
        }

        Map<String, Object> extra = new HashMap<>();
        extra.put("loggedIn", true);
        extra.put("user", userData);
        extra.put("profile", profileData);

        JsonUtil.sendJsonResponse(response, HttpServletResponse.SC_OK, true, 
                "Session active.", extra);
    }
}
