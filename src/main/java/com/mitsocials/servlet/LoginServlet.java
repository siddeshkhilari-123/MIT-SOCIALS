package com.mitsocials.servlet;

import com.mitsocials.dao.UserDAO;
import com.mitsocials.model.User;
import com.mitsocials.util.JsonUtil;
import com.mitsocials.util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/api/login")
public class LoginServlet extends HttpServlet {

    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        Map<String, String> params = JsonUtil.parseRequestBody(request);

        String collegeEmail = params.get("college_email");
        String password = params.get("password");

        // Validate missing inputs
        if (collegeEmail == null || collegeEmail.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            JsonUtil.sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false, 
                    "College email and password are required.", null);
            return;
        }

        collegeEmail = collegeEmail.trim().toLowerCase();

        // Find user by email
        User user = userDAO.findByEmail(collegeEmail);
        if (user == null) {
            JsonUtil.sendJsonResponse(response, HttpServletResponse.SC_UNAUTHORIZED, false, 
                    "Invalid college email or password.", null);
            return;
        }

        // Verify password hash
        boolean passwordValid = PasswordUtil.verifyPassword(password, user.getPasswordHash());
        if (!passwordValid) {
            JsonUtil.sendJsonResponse(response, HttpServletResponse.SC_UNAUTHORIZED, false, 
                    "Invalid college email or password.", null);
            return;
        }

        // Create HttpSession and store user data
        HttpSession session = request.getSession(true);
        session.setAttribute("userId", user.getId());
        session.setAttribute("collegeEmail", user.getCollegeEmail());
        session.setAttribute("fullName", user.getFullName());
        session.setAttribute("studentId", user.getStudentId());
        session.setAttribute("role", user.getRole());
        session.setAttribute("branch", user.getBranch());
        session.setAttribute("year", user.getYear());
        session.setAttribute("division", user.getDivision());

        // Prepare return payload
        Map<String, Object> userData = new HashMap<>();
        userData.put("id", user.getId());
        userData.put("collegeEmail", user.getCollegeEmail());
        userData.put("fullName", user.getFullName());
        userData.put("studentId", user.getStudentId());
        userData.put("role", user.getRole());
        userData.put("branch", user.getBranch());
        userData.put("year", user.getYear());
        userData.put("division", user.getDivision());

        Map<String, Object> extra = new HashMap<>();
        extra.put("redirect", "dashboard.html");
        extra.put("user", userData);

        JsonUtil.sendJsonResponse(response, HttpServletResponse.SC_OK, true, 
                "Login successful! Welcome to MIT Socials.", extra);
    }
}
