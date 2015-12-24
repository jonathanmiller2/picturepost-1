package edu.unh.sr.picturepost;

import java.sql.*;

public class PictureMD {

    private int pictureMDId  = 0;
    private int pictureId    = 0;
    private String directory = "";
    private int tagId        = 0;
    private String tagName   = "";
    private String tagValue  = "";

    public PictureMD() {
        clear();
    }

    public PictureMD(int pictureMDId) {
        clear();
        dbSelect(pictureMDId);
    }

    public void clear() {
        setPictureMDId(0);
        setPictureId(0);
        setDirectory("");
        setTagId(0);
        setTagName("");
        setTagValue("");
    }

    public boolean dbSelect(int pictureMDId) {
        boolean retVal = false;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        sqlText = "SELECT picture_id, directory, tag_id, tag_name, tag_value FROM picture_md WHERE picture_md_id = ?";
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, pictureMDId);
            rs = stmt.executeQuery();
            if (rs != null && rs.next()) {
                setPictureMDId(pictureMDId);
                setPictureId(rs.getInt("picture_id"));
                setDirectory(rs.getString("directory"));
                setTagId(rs.getInt("tag_id"));
                setTagName(rs.getString("tag_name"));
                setTagValue(rs.getString("tag_value"));
                retVal = true;
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: PictureMD.java, dbSelect(int pictureMDId), sqlText = " + sqlText + ", " + e.toString());
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

        if (getPictureMDId() > 0) {
            sqlText = "INSERT INTO picture_md VALUES (?, ?, ?, ?, ?, ?)";
            try {
                conn = DBPool.getInstance().getConnection();
                stmt = conn.prepareStatement(sqlText);
                stmt.setInt(1, getPictureMDId());
                stmt.setInt(2, getPictureId());
                stmt.setString(3, getDirectory());
                stmt.setInt(4, getTagId());
                stmt.setString(5, getTagName());
                stmt.setString(6, getTagValue());
                if (stmt.executeUpdate() == 1) {
                    retVal = true;
                }
                else {
                    Log.writeLog("ERROR: PictureMD.java, dbInsert(), sqlText = " + sqlText);
                }
            }
            catch (Exception e) {
                Log.writeLog("ERROR: PictureMD.java, dbInsert(), sqlText = " + sqlText + ", " + e.toString());
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

        if (getPictureMDId() > 0) {
            sqlText = "UPDATE picture_md SET (picture_id, directory, tag_id, tag_name, tag_value) = (?, ?, ?, ?, ?) WHERE picture_md_id = ?";
            try {
                conn = DBPool.getInstance().getConnection();
                stmt = conn.prepareStatement(sqlText);
                stmt.setInt(1, getPictureId());
                stmt.setString(2, getDirectory());
                stmt.setInt(3, getTagId());
                stmt.setString(4, getTagName());
                stmt.setString(5, getTagValue());
                if (stmt.executeUpdate() == 1) {
                    retVal = true;
                }
                else {
                    Log.writeLog("ERROR: PictureMD.java, dbUpdate(), sqlText = " + sqlText);
                }
            }
            catch (Exception e) {
                Log.writeLog("ERROR: PictureMD.java, dbUpdate(), sqlText = " + sqlText + ", " + e.toString());
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

        if (getPictureMDId() > 0) {
            sqlText = "DELETE FROM picture_md WHERE picture_md_id = ?";
            try {
                conn = DBPool.getInstance().getConnection();
                stmt = conn.prepareStatement(sqlText);
                stmt.setInt(1, getPictureMDId());
                if (stmt.executeUpdate() == 1) {
                    clear();
                    retVal = true;
                }
                else {
                    Log.writeLog("ERROR: PictureMD.java, dbDelete(), sqlText = " + sqlText);
                }
            }
            catch (Exception e) {
                Log.writeLog("ERROR: PictureMD.java, dbDelete(), sqlText = " + sqlText + ", " + e.toString());
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
        PictureMD pictureMD = (PictureMD)o;

        if (pictureMD.getPictureMDId() == this.getPictureMDId() && this.getPictureMDId() != 0) {
            retVal = true;
        }

        return retVal;
    }

    public int getPictureMDId() {
        return this.pictureMDId;
    }

    public boolean dbSetPictureMDId() {
        boolean retVal = false;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        sqlText = "SELECT nextval('picture_md_picture_md_id_seq')";
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            rs = stmt.executeQuery();
            if (rs != null && rs.next()) {
                setPictureMDId(rs.getInt(1));
                retVal = true;
            }
            else {
                Log.writeLog("ERROR: PictureMD.java, dbSetPictureMDId(), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: PictureMD.java, dbSetPictureMDId(), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return retVal;
    }

    public void setPictureMDId(int pictureMDId) {
        this.pictureMDId = pictureMDId;
    }

    public int getPictureId() {
        return this.pictureId;
    }

    public void setPictureId(int pictureId) {
        this.pictureId = pictureId;
    }

    public String getDirectory() {
        return this.directory;
    }

    public void setDirectory(String directory) {
        this.directory = directory; if (this.directory == null) this.directory = "";
    }

    public int getTagId() {
        return this.tagId;
    }

    public void setTagId(int tagId) {
        this.tagId = tagId;
    }

    public String getTagName() {
        return this.tagName;
    }

    public void setTagName(String tagName) {
        this.tagName = tagName; if (this.tagName == null) this.tagName = "";
    }

    public String getTagValue() {
        return this.tagValue;
    }

    public void setTagValue(String tagValue) {
        this.tagValue = tagValue; if (this.tagValue == null) this.tagValue = "";
        this.tagValue = Utils.truncate(this.tagValue, 10240);
    }
}
