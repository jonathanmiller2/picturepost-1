package edu.unh.sr.picturepost;

import java.sql.*;

public class PictureComment {

    private int pictureCommentId                = 0;
    private int personId                        = 0;
    private int pictureId                       = 0;
    private java.sql.Timestamp commentTimestamp = null;
    private String commentText                  = "";

    public PictureComment() {
        clear();
    }

    public PictureComment(int pictureCommentId) {
        clear();
        dbSelect(pictureCommentId);
    }

    public void clear() {
        setPictureCommentId(0);
        setPersonId(0);
        setPictureId(0);
        setCommentTimestamp(null);
        setCommentText("");
    }

    public boolean canEdit(Person p) {
      if (getPersonId() == p.getPersonId() || p.getAdmin()) return true;
      int postOwnerId = Utils.q()
        .select("post.person_id")
        .from("picture_comment")
        .join("picture ON (picture_comment.picture_id=picture.picture_id)")
        .join("picture_set ON (picture.picture_set_id=picture_set.picture_set_id)")
        .join("post ON (picture_set.post_id=post.post_id)")
        .where("picture_comment.picture_comment_id=?")
        .bind(getPictureId())
        .append("LIMIT 1")
        .getInt();
      return (postOwnerId == p.getPersonId()) ? true : false;
    }

    public boolean dbSelect(int pictureCommentId) {
        boolean retVal = false;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        sqlText = "SELECT person_id, picture_id, comment_timestamp, comment_text FROM picture_comment WHERE picture_comment_id = ?";
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, pictureCommentId);
            rs = stmt.executeQuery();
            if (rs != null && rs.next()) {
                setPictureCommentId(pictureCommentId);
                setPersonId(rs.getInt("person_id"));
                setPictureId(rs.getInt("picture_id"));
                setCommentTimestamp(rs.getTimestamp("comment_timestamp"));
                setCommentText(rs.getString("comment_text"));
                retVal = true;
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: PictureComment.java, dbSelect(int pictureCommentId), sqlText = " + sqlText + ", " + e.toString());
        }
        finally { 
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return retVal;
    }

    public boolean dbInsert() {
        boolean retVal = false;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;

        if (getPictureCommentId() > 0) {
            sqlText = "INSERT INTO picture_comment VALUES (?, ?, ?, ?, ?)";
            try {
                conn = DBPool.getInstance().getConnection();
                stmt = conn.prepareStatement(sqlText);
                stmt.setInt(1, getPictureCommentId());
                stmt.setInt(2, getPersonId());
                stmt.setInt(3, getPictureId());
                stmt.setTimestamp(4, getCommentTimestamp());
                stmt.setString(5, getCommentText());
                if (stmt.executeUpdate() == 1) {
                    retVal = true;
                }
                else {
                    Log.writeLog("ERROR: PictureComment.java, dbInsert(), sqlText = " + sqlText);
                }
            }
            catch (Exception e) {
                Log.writeLog("ERROR: PictureComment.java, dbInsert(), sqlText = " + sqlText + ", " + e.toString());
            }
            finally {
                try { stmt.close(); } catch (Exception e) { }
                DBPool.getInstance().returnConnection(conn);
            }
        }

        return retVal;
    }

    public boolean dbUpdate() {
        boolean retVal = false;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;

        if (getPictureCommentId() > 0) {
            sqlText = "UPDATE picture_comment SET (person_id, picture_id, comment_timestamp, comment_text) = (?, ?, ?, ?) WHERE picture_comment_id = ?";
            try {
                conn = DBPool.getInstance().getConnection();
                stmt = conn.prepareStatement(sqlText);
                stmt.setInt(1, getPersonId());
                stmt.setInt(2, getPictureId());
                stmt.setTimestamp(3, getCommentTimestamp());
                stmt.setString(4, getCommentText());
                stmt.setInt(5, getPictureCommentId());
                if (stmt.executeUpdate() == 1) {
                    retVal = true;
                }
                else { 
                    Log.writeLog("ERROR: PictureComment.java, dbUpdate(), sqlText = " + sqlText);
                }
            }
            catch (Exception e) { 
                Log.writeLog("ERROR: PictureComment.java, dbUpdate(), sqlText = " + sqlText + ", " + e.toString());
            }
            finally {
                try { stmt.close(); } catch (Exception e) { }
                DBPool.getInstance().returnConnection(conn);
            }
        }

        return retVal; 
    }

    public boolean dbDelete() {
        boolean retVal = false;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;

        if (getPictureCommentId() > 0) {
            sqlText = "DELETE FROM picture_comment WHERE picture_comment_id = ?";
            try {
                conn = DBPool.getInstance().getConnection();
                stmt = conn.prepareStatement(sqlText);
                stmt.setInt(1, getPictureCommentId());
                if (stmt.executeUpdate() == 1) {
                    clear(); 
                    retVal = true;
                }
                else {
                    Log.writeLog("ERROR: PictureComment.java, dbDelete(), sqlText = " + sqlText);
                }
            }
            catch (Exception e) {
                Log.writeLog("ERROR: PictureComment.java, dbDelete(), sqlText = " + sqlText + ", " + e.toString());
            }
            finally { 
                try { stmt.close(); } catch (Exception e) { }
                DBPool.getInstance().returnConnection(conn);
            }
        }

        return retVal;
    }

    public boolean equals(Object o) {
        boolean retVal = false;
        PictureComment pictureComment = (PictureComment)o;

        if (pictureComment.getPictureCommentId() == this.getPictureCommentId() && this.getPictureCommentId() != 0) {
            retVal = true;
        }

        return retVal;
    }

    public int getPictureCommentId() {
        return this.pictureCommentId;
    }

    public boolean dbSetPictureCommentId() {
        boolean retVal = false;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        sqlText = "SELECT nextval('picture_comment_picture_comment_id_seq')";
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            rs = stmt.executeQuery();
            if (rs != null && rs.next()) {
                setPictureCommentId(rs.getInt(1));
                retVal = true;
            }
            else {
                Log.writeLog("ERROR: PictureComment.java, dbSetPictureCommentId(), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: PictureComment.java, dbSetPictureCommentId(), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return retVal;
    }

    public void setPictureCommentId(int pictureCommentId) {
        this.pictureCommentId = pictureCommentId;
    }

    public int getPersonId() {
        return this.personId;
    }

    public void setPersonId(int personId) {
        this.personId = personId;
    }

    public int getPictureId() {
        return this.pictureId;
    }

    public void setPictureId(int pictureId) {
        this.pictureId = pictureId;
    }

    public java.sql.Timestamp getCommentTimestamp() {
        return this.commentTimestamp;
    }

    public void setCommentTimestamp(java.sql.Timestamp commentTimestamp) {
        this.commentTimestamp = commentTimestamp;
    }

    public String getCommentText() {
        return this.commentText;
    }

    public void setCommentText(String commentText) {
        this.commentText = commentText; if (this.commentText == null) this.commentText = "";
    }
}
