package com.mitsocials.util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class JsonUtil {

    public static Map<String, String> parseRequestBody(HttpServletRequest request) throws IOException {
        Map<String, String> data = new HashMap<>();
        Map<String, String[]> parameterMap = request.getParameterMap();
        if (parameterMap != null && !parameterMap.isEmpty()) {
            for (Map.Entry<String, String[]> entry : parameterMap.entrySet()) {
                if (entry.getValue() != null && entry.getValue().length > 0) {
                    data.put(entry.getKey(), entry.getValue()[0].trim());
                }
            }
        }

        String contentType = request.getContentType();
        if (contentType != null && contentType.toLowerCase().contains("application/json")) {
            StringBuilder sb = new StringBuilder();
            try (BufferedReader reader = request.getReader()) {
                String line;
                while ((line = reader.readLine()) != null) sb.append(line);
            }
            String body = sb.toString().trim();
            if (!body.isEmpty()) parseSimpleJson(body, data);
        }
        return data;
    }

    private static void parseSimpleJson(String json, Map<String, String> targetMap) {
        json = json.trim();
        if (json.startsWith("{") && json.endsWith("}")) json = json.substring(1, json.length() - 1);
        String[] pairs = json.split(",(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)");
        for (String pair : pairs) {
            String[] keyValue = pair.split(":(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)", 2);
            if (keyValue.length == 2) {
                targetMap.put(cleanJsonString(keyValue[0]), cleanJsonString(keyValue[1]));
            }
        }
    }

    private static String cleanJsonString(String str) {
        str = str.trim();
        if (str.startsWith("\"") && str.endsWith("\"")) str = str.substring(1, str.length() - 1);
        return str.replace("\\\"", "\"").replace("\\\\", "\\");
    }

    public static void sendJsonResponse(HttpServletResponse response, boolean success, String message,
                                        Map<String, Object> extraData) throws IOException {
        sendJsonResponse(response, HttpServletResponse.SC_OK, success, message, extraData);
    }

    public static void sendJsonResponse(HttpServletResponse response, int statusCode, boolean success,
                                        String message, Map<String, Object> extraData) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setStatus(statusCode);
        Map<String, Object> result = new HashMap<>();
        result.put("success", success);
        result.put("message", message);
        if (extraData != null) result.putAll(extraData);
        writeJson(response, result);
    }

    public static void sendJson(HttpServletResponse response, int statusCode, Object value) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setStatus(statusCode);
        writeJson(response, value);
    }

    public static void writeJson(HttpServletResponse response, Object value) throws IOException {
        try (PrintWriter out = response.getWriter()) {
            out.print(toJson(value));
        }
    }

    public static String mapToJson(Map<?, ?> map) {
        return toJson(map);
    }

    public static String toJson(Object value) {
        if (value == null) return "null";
        if (value instanceof String || value instanceof Character || value instanceof Enum<?>) {
            return "\"" + escapeJson(String.valueOf(value)) + "\"";
        }
        if (value instanceof Boolean || value instanceof Number) return String.valueOf(value);
        if (value instanceof Map<?, ?> map) {
            StringBuilder sb = new StringBuilder("{");
            boolean first = true;
            for (Map.Entry<?, ?> entry : map.entrySet()) {
                if (!first) sb.append(",");
                sb.append("\"").append(escapeJson(String.valueOf(entry.getKey()))).append("\":");
                sb.append(toJson(entry.getValue()));
                first = false;
            }
            return sb.append("}").toString();
        }
        if (value instanceof List<?> list) {
            StringBuilder sb = new StringBuilder("[");
            for (int i = 0; i < list.size(); i++) {
                if (i > 0) sb.append(",");
                sb.append(toJson(list.get(i)));
            }
            return sb.append("]").toString();
        }
        if (value.getClass().isArray()) {
            StringBuilder sb = new StringBuilder("[");
            int length = java.lang.reflect.Array.getLength(value);
            for (int i = 0; i < length; i++) {
                if (i > 0) sb.append(",");
                sb.append(toJson(java.lang.reflect.Array.get(value, i)));
            }
            return sb.append("]").toString();
        }
        return "\"" + escapeJson(String.valueOf(value)) + "\"";
    }

    private static String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\b", "\\b")
                .replace("\f", "\\f")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
