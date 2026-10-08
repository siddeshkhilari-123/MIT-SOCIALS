package com.mitsocials.servlet;

import com.mitsocials.dao.ProfileDAO;
import com.mitsocials.dao.UserDAO;
import com.mitsocials.model.Profile;
import com.mitsocials.model.User;
import com.mitsocials.util.JsonUtil;
import com.mitsocials.util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Map;

@WebServlet("/api/register")
public class RegisterServlet extends HttpServlet {

    private UserDAO userDAO;
    private ProfileDAO profileDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        profileDAO = new ProfileDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        Map<String, String> params = JsonUtil.parseRequestBody(request);

        String fullName = params.get("full_name");
        String collegeEmail = params.get("college_email");
        String studentId = params.get("student_id");
        String branch = params.get("branch");
        String year = params.get("year");
        String division = params.get("division");
        String password = params.get("password");
        String confirmPassword = params.get("confirm_password");

        // 1. Validate required fields
        if (isEmpty(fullName) || isEmpty(collegeEmail) || isEmpty(studentId) ||
            isEmpty(branch) || isEmpty(year) || isEmpty(division) ||
            isEmpty(password) || isEmpty(confirmPassword)) {
            JsonUtil.sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false, 
                    "All registration fields are required.", null);
            return;
        }

        fullName = fullName.trim();
        collegeEmail = collegeEmail.trim().toLowerCase();
        studentId = studentId.trim();

        // 2. Validate email format
        if (!collegeEmail.matches("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
            JsonUtil.sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false, 
                    "Please enter a valid email address.", null);
            return;
        }

        // 3. Validate password confirmation and strength
        if (!password.equals(confirmPassword)) {
            JsonUtil.sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false, 
                    "Password and confirm password do not match.", null);
            return;
        }

        if (password.length() < 6) {
            JsonUtil.sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false, 
                    "Password must be at least 6 characters long.", null);
            return;
        }

        // 4. Check duplicate email
        if (userDAO.existsByEmail(collegeEmail)) {
            JsonUtil.sendJsonResponse(response, HttpServletResponse.SC_CONFLICT, false, 
                    "This college email is already registered.", null);
            return;
        }

        // 5. Check duplicate student ID
        if (userDAO.existsByStudentId(studentId)) {
            JsonUtil.sendJsonResponse(response, HttpServletResponse.SC_CONFLICT, false, 
                    "This Student ID (PRN/Roll No) is already registered.", null);
            return;
        }

        // 6. Hash password
        String passwordHash = PasswordUtil.hashPassword(password);

        // 7. Insert user (Default role: STUDENT)
        User newUser = new User(collegeEmail, passwordHash, studentId, fullName, branch, year, division, "STUDENT");
        boolean userCreated = userDAO.createUser(newUser);

        if (!userCreated) {
            JsonUtil.sendJsonResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, false, 
                    "Database error while creating user. Please try again later.", null);
            return;
        }

        // 8. Create basic profile
        Profile newProfile = new Profile(
                newUser.getId(),
                "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80",
                "https://images.unsplash.com/photo-1523050854058-8df90110c9f1?auto=format&fit=crop&w=1200&q=80",
                "Hello! I am a student at MIT studying " + branch + ".",
                branch,
                year,
                division
        );
        profileDAO.createProfile(newProfile);

        // 9. Return success response
        JsonUtil.sendJsonResponse(response, HttpServletResponse.SC_CREATED, true, 
                "Registration successful! You can now log in.", null);
    }

    private boolean isEmpty(String str) {
        return str == null || str.trim().isEmpty();
    }
}
