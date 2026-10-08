package com.mitsocials.model;

import java.sql.Timestamp;

public class User {
    private int id;
    private String collegeEmail;
    private String passwordHash;
    private String studentId;
    private String fullName;
    private String branch;
    private String year;
    private String division;
    private String role; // STUDENT, CLUB_ADMIN, COLLEGE_ADMIN
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public User() {
    }

    public User(int id, String collegeEmail, String passwordHash, String studentId, String fullName, 
                String branch, String year, String division, String role, Timestamp createdAt, Timestamp updatedAt) {
        this.id = id;
        this.collegeEmail = collegeEmail;
        this.passwordHash = passwordHash;
        this.studentId = studentId;
        this.fullName = fullName;
        this.branch = branch;
        this.year = year;
        this.division = division;
        this.role = role;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public User(String collegeEmail, String passwordHash, String studentId, String fullName, 
                String branch, String year, String division, String role) {
        this.collegeEmail = collegeEmail;
        this.passwordHash = passwordHash;
        this.studentId = studentId;
        this.fullName = fullName;
        this.branch = branch;
        this.year = year;
        this.division = division;
        this.role = role;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getCollegeEmail() {
        return collegeEmail;
    }

    public void setCollegeEmail(String collegeEmail) {
        this.collegeEmail = collegeEmail;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public String getStudentId() {
        return studentId;
    }

    public void setStudentId(String studentId) {
        this.studentId = studentId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getBranch() {
        return branch;
    }

    public void setBranch(String branch) {
        this.branch = branch;
    }

    public String getYear() {
        return year;
    }

    public void setYear(String year) {
        this.year = year;
    }

    public String getDivision() {
        return division;
    }

    public void setDivision(String division) {
        this.division = division;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", collegeEmail='" + collegeEmail + '\'' +
                ", studentId='" + studentId + '\'' +
                ", fullName='" + fullName + '\'' +
                ", branch='" + branch + '\'' +
                ", year='" + year + '\'' +
                ", division='" + division + '\'' +
                ", role='" + role + '\'' +
                '}';
    }
}
