package com.mitsocials.model;

import java.sql.Timestamp;

public class Profile {
    private int id;
    private int userId;
    private String profilePhoto;
    private String coverPhoto;
    private String bio;
    private String branch;
    private String year;
    private String division;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public Profile() {
    }

    public Profile(int id, int userId, String profilePhoto, String coverPhoto, String bio, 
                   String branch, String year, String division, Timestamp createdAt, Timestamp updatedAt) {
        this.id = id;
        this.userId = userId;
        this.profilePhoto = profilePhoto;
        this.coverPhoto = coverPhoto;
        this.bio = bio;
        this.branch = branch;
        this.year = year;
        this.division = division;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public Profile(int userId, String profilePhoto, String coverPhoto, String bio, 
                   String branch, String year, String division) {
        this.userId = userId;
        this.profilePhoto = profilePhoto;
        this.coverPhoto = coverPhoto;
        this.bio = bio;
        this.branch = branch;
        this.year = year;
        this.division = division;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getProfilePhoto() {
        return profilePhoto;
    }

    public void setProfilePhoto(String profilePhoto) {
        this.profilePhoto = profilePhoto;
    }

    public String getCoverPhoto() {
        return coverPhoto;
    }

    public void setCoverPhoto(String coverPhoto) {
        this.coverPhoto = coverPhoto;
    }

    public String getBio() {
        return bio;
    }

    public void setBio(String bio) {
        this.bio = bio;
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
        return "Profile{" +
                "id=" + id +
                ", userId=" + userId +
                ", profilePhoto='" + profilePhoto + '\'' +
                ", coverPhoto='" + coverPhoto + '\'' +
                ", bio='" + bio + '\'' +
                ", branch='" + branch + '\'' +
                ", year='" + year + '\'' +
                ", division='" + division + '\'' +
                '}';
    }
}
