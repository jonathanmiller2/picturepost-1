package edu.unh.sr.picturepost;

import java.sql.*;
import java.io.*;

public class PostPicture {

    private int postPictureId        = 0;
    private int postId               = 0;
    private int seqNbr               = 0;
    private String imageFileOriginal = "";
    private String fileType          = "";
    private String fileExt           = "";
    private boolean active           = true;

    public PostPicture() {
        clear();
    }

    public PostPicture(int postPictureId) {
        clear();
        dbSelect(postPictureId);
    }

    public void clear() {
        setPostPictureId(0);
        setPostId(0);
        setSeqNbr(0);
        setImageFileOriginal("");
        setFileType("");
        setFileExt("");
        setActive(true);
    }

    public boolean dbSelect(int postPictureId) {
        boolean retVal = false;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        sqlText = "SELECT post_id, seq_nbr, image_file_original, file_type, file_ext, active FROM post_picture WHERE post_picture_id = ?";
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, postPictureId);
            rs = stmt.executeQuery();
            if (rs != null && rs.next()) {
                setPostPictureId(postPictureId);
                setPostId(rs.getInt("post_id"));
                setSeqNbr(rs.getInt("seq_nbr"));
                setImageFileOriginal(rs.getString("image_file_original"));
                setFileType(rs.getString("file_type"));
                setFileExt(rs.getString("file_ext"));
                setActive(rs.getBoolean("active"));

                retVal = true;
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: PostPicture.java, dbSelect(int postPictureId), sqlText = " + sqlText + ", " + e.toString());
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

        if (getPostPictureId() > 0) {
            sqlText = "INSERT INTO post_picture VALUES (?, ?, ?, ?, ?, ?, ?)";
            try {
                conn = DBPool.getInstance().getConnection();
                stmt = conn.prepareStatement(sqlText);
                stmt.setInt(1, getPostPictureId());
                stmt.setInt(2, getPostId());
                stmt.setInt(3, getSeqNbr());
                stmt.setString(4, getImageFileOriginal());
                stmt.setString(5, getFileType());
                stmt.setString(6, getFileExt());
                stmt.setBoolean(7, getActive());
                if (stmt.executeUpdate() == 1) {
                    retVal = true;
                }
                else {
                    Log.writeLog("ERROR: PostPicture.java, dbInsert(), sqlText = " + sqlText);
                }
            }
            catch (Exception e) {
                Log.writeLog("ERROR: PostPicture.java, dbInsert(), sqlText = " + sqlText + ", " + e.toString());
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

        if (getPostPictureId() > 0) {
            sqlText = "UPDATE post_picture SET (post_id, seq_nbr, image_file_original, file_type, file_ext, active) = (?, ?, ?, ?, ?, ?) WHERE post_picture_id = ?";
            try {
                conn = DBPool.getInstance().getConnection();
                stmt = conn.prepareStatement(sqlText);
                stmt.setInt(1, getPostId());
                stmt.setInt(2, getSeqNbr());
                stmt.setString(3, getImageFileOriginal());
                stmt.setString(4, getFileType());
                stmt.setString(5, getFileExt());
                stmt.setBoolean(6, getActive());
                stmt.setInt(7, getPostPictureId());
                if (stmt.executeUpdate() == 1) {
                    retVal = true;
                }
                else {
                    Log.writeLog("ERROR: PostPicture.java, dbUpdate(), sqlText = " + sqlText);
                }
            }
            catch (Exception e) {
                Log.writeLog("ERROR: PostPicture.java, dbUpdate(), sqlText = " + sqlText + ", " + e.toString());
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

        if (getPostPictureId() > 0) {
            sqlText = "DELETE FROM post_picture WHERE post_picture_id = ?";
            try {
                conn = DBPool.getInstance().getConnection();
                stmt = conn.prepareStatement(sqlText);
                stmt.setInt(1, getPostPictureId());
                if (stmt.executeUpdate() == 1) {
                    deleteImageFiles();
                    clear();
                    retVal = true;
                }
                else {
                    Log.writeLog("ERROR: PostPicture.java, dbDelete(), sqlText = " + sqlText);
                }
            }
            catch (Exception e) {
                Log.writeLog("ERROR: PostPicture.java, dbDelete(), sqlText = " + sqlText + ", " + e.toString());
            }
            finally {
                try { stmt.close(); } catch (Exception e) { }
                DBPool.getInstance().returnConnection(conn);
            }
        }

        return retVal;
    }

    public void deleteImageFiles() {
        Post post = new Post(getPostId());
        File file = new File(Config.get("PICTURE_DIR") + "/" + post.getPostDir() + "/" + getImageFile());
        if (file.isFile()) {
            file.delete();
        }
        file = new File(Config.get("PICTURE_DIR") + "/" + post.getPostDir() + "/" + getImageFileMedium());
        if (file.isFile()) {
            file.delete();
        }
        file = new File(Config.get("PICTURE_DIR") + "/" + post.getPostDir() + "/" + getImageFileThumb());
        if (file.isFile()) {
            file.delete();
        }
    }

    public boolean equals(Object o) {
        boolean retVal = false;
        PostPicture postPicture = (PostPicture)o;

        if (postPicture.getPostPictureId() == this.getPostPictureId() && this.getPostPictureId() != 0) {
            retVal = true;
        }

        return retVal;
    }

    public int getPostPictureId() {
        return this.postPictureId;
    }

    public boolean dbSetPostPictureId() {
        boolean retVal = false;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        sqlText = "SELECT nextval('post_picture_post_picture_id_seq')";
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            rs = stmt.executeQuery();
            if (rs != null && rs.next()) {
                setPostPictureId(rs.getInt(1));
                retVal = true;
            }
            else { 
                Log.writeLog("ERROR: PostPicture.java, dbSetPostPictureId(), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: PostPicture.java, dbSetPostPictureId(), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return retVal;
    }

    public void setPostPictureId(int postPictureId) {
        this.postPictureId = postPictureId;
    }

    public int getPostId() {
        return this.postId;
    }

    public void setPostId(int postId) {
        this.postId = postId;
    }

    public int getSeqNbr() {
        return this.seqNbr;
    }

    public boolean dbSetSeqNbr() {
        boolean retVal = false;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
    
        sqlText = "SELECT max(seq_nbr) FROM post_picture WHERE post_id = ?";
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, getPostId());
            rs = stmt.executeQuery();
            if (rs != null && rs.next()) {
                setSeqNbr(rs.getInt(1) + 1);
                retVal = true;
            }
            else { 
                Log.writeLog("ERROR: PostPicture.java, dbSetSeqNbr(), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: PostPicture.java, dbSetSeqNbr(), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return retVal;
    }

    public void setSeqNbr(int seqNbr) {
        this.seqNbr = seqNbr;
    }

    public String getImageFile() {
        return "post_picture_" + String.valueOf(getPostPictureId()) + getFileExt();
    }

    public String getImageFileMedium() {
        return "post_picture_" + String.valueOf(getPostPictureId()) + "_medium" + getFileExt();
    }

    public String getImageFileThumb() {
        return "post_picture_" + String.valueOf(getPostPictureId()) + "_thumb" + getFileExt();
    }

    public String getImageFileOriginal() {
        return this.imageFileOriginal;
    }

    public void setImageFileOriginal(String imageFileOriginal) {
        this.imageFileOriginal = imageFileOriginal; if (this.imageFileOriginal == null) this.imageFileOriginal = "";
    }

    public String getFileType() {
        return this.fileType;
    }

    public void setFileType(String fileType) {
        this.fileType = fileType; if (this.fileType == null) this.fileType = "";
    }

    public String getFileExt() {
        return this.fileExt;
    }

    public void setFileExt(String fileExt) {
        this.fileExt = fileExt; if (this.fileExt == null) this.fileExt = "";
    }

    public boolean getActive() {
        return this.active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public static boolean dbIsValidPostPictureId(int postPictureId) {
        boolean retVal = false;
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        String sqlText = "";

        sqlText = "SELECT COUNT(*) FROM post_picture WHERE post_picture_id = ?";
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, postPictureId);
            rs = stmt.executeQuery();
            if (rs != null && rs.next()) {
                if (rs.getInt(1) == 1) {
                    retVal = true;
                }
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: PostPicture.java, dbIsValidPostPictureId(int pictureId), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return retVal;
    } 
}
