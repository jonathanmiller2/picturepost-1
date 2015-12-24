package edu.unh.sr.picturepost;

import java.util.*;

public class PostInfo {
    private int postId                                    = 0;
    private String name                                   = "";
    private int personId                                  = 0;
    private String firstName                              = "";
    private String lastName                               = "";
    private String email                                  = "";
    private int numPictureSets                            = 0;
    private java.sql.Timestamp tStampMostRecentPictureSet = new java.sql.Timestamp(Calendar.getInstance().getTimeInMillis());

    public PostInfo() {
        clear();
    }

    public void clear() {
        setPostId(0);
        setName("");
        setPersonId(0);
        setFirstName("");
        setLastName("");
        setEmail("");
        setNumPictureSets(0);
        setTStampMostRecentPictureSet(new java.sql.Timestamp(Calendar.getInstance().getTimeInMillis()));
    }

    public int getPostId() {
        return this.postId;
    }

    public void setPostId(int postId) {
        this.postId = postId;
    }

    public String getName() {
        return this.name;
    }

    public void setName(String name) {
        this.name = name;  if (this.name == null) this.name = "";
    }

    public int getPersonId() {
        return this.personId;
    }

    public void setPersonId(int personId) {
        this.personId = personId;
    }

    public String getFirstName() {
        return this.firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;  if (this.firstName == null) this.firstName = "";
    }

    public String getLastName() {
        return this.lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;  if (this.lastName == null) this.lastName = "";
    }

    public String getEmail() {
        return this.email;
    }

    public void setEmail(String email) {
        this.email = email;  if (this.email == null) this.email = "";
    }

    public int getNumPictureSets() {
        return this.numPictureSets;
    }

    public void setNumPictureSets(int numPictureSets) {
        this.numPictureSets = numPictureSets;
    }

    public java.sql.Timestamp getTStampMostRecentPictureSet() {
        return this.tStampMostRecentPictureSet;
    }

    public void setTStampMostRecentPictureSet(java.sql.Timestamp tStampMostRecentPictureSet) {
        this.tStampMostRecentPictureSet = tStampMostRecentPictureSet;
    }
}
