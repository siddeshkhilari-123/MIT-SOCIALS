package com.mitsocials.servlet;

import com.mitsocials.util.JsonUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/api/logout")
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        processLogout(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        processLogout(request, response);
    }

    private void processLogout(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }

        String acceptHeader = request.getHeader("Accept");
        if (acceptHeader != null && acceptHeader.contains("application/json")) {
            JsonUtil.sendJsonResponse(response, HttpServletResponse.SC_OK, true, 
                    "Logged out successfully.", null);
        } else {
            response.sendRedirect(request.getContextPath() + "/login.html");
        }
    }
}
