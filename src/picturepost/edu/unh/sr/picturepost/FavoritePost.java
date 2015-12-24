package edu.unh.sr.picturepost;

import java.sql.*;


public class FavoritePost {
    private int personId = 0;
    private int postId   = 0;

    public FavoritePost(int personId, int postId) {
        setPersonId(personId);
        setPostId(postId);
    }

    public void clear() {
        setPersonId(0);
        setPostId(0);
    }

    public boolean dbInsert() {
        boolean retVal = false;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;

        sqlText = "INSERT INTO favorite_post VALUES (?, ?)";
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, getPersonId());
            stmt.setInt(2, getPostId());
            if (stmt.executeUpdate() == 1) {
                retVal = true;
            }
            else {
                Log.writeLog("ERROR: FavoritePost.java, dbInsert(), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: FavoritePost.java, dbInsert(), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return retVal;
    }

    public boolean dbDelete() {
        boolean retVal = false;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;

        sqlText = "DELETE FROM favorite_post WHERE person_id = ? AND post_id = ?";
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, getPersonId());
            stmt.setInt(2, getPostId());
            if (stmt.executeUpdate() == 1) {
                clear();
                retVal = true;
            }
            else {
                Log.writeLog("ERROR: FavoritePost.java, dbDelete(), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: FavoritePost.java, dbDelete(), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return retVal;
    }

    public int getPersonId() {
        return this.personId;
    }

    public void setPersonId(int personId) {
        this.personId = personId;
    }

    public int getPostId() {
        return this.postId;
    }

    public void setPostId(int postId) {
        this.postId = postId;
    }
}
