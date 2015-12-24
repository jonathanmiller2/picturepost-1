package edu.unh.sr.picturepost;

import java.util.*;
import java.sql.*;

public class PictureSet {

    private int pictureSetId                       = 0;
    private int postId                             = 0;
    private int personId                           = 0;
    private java.sql.Timestamp recordTimestamp     = new java.sql.Timestamp(Calendar.getInstance().getTimeInMillis());
    private java.sql.Timestamp pictureSetTimestamp = null;
    private boolean ready                          = false;
    private boolean flagged                        = false;
    private String annotation                      = "";

    public PictureSet() {
        clear();
    }

    public PictureSet(int pictureSetId) {
        clear();
        dbSelect(pictureSetId);
    }

    public void clear() {
        Calendar now  = Calendar.getInstance(TimeZone.getTimeZone("America/New_York"));
        String year = Integer.toString(now.get(Calendar.YEAR));
 
        setPictureSetId(0);
        setPostId(0);
        setPersonId(0);
        setRecordTimestamp(new java.sql.Timestamp(now.getTimeInMillis()));
        setPictureSetTimestamp(java.sql.Timestamp.valueOf("1970-01-01 00:00:00"));
        setReady(false);
        setFlagged(false);
        setAnnotation("");
    }

    public boolean dbSelect(int pictureSetId) {
        boolean retVal = false;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        sqlText = "SELECT post_id, person_id, record_timestamp, picture_set_timestamp, ready, flagged, annotation FROM picture_set WHERE picture_set_id = ?";
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, pictureSetId);
            rs = stmt.executeQuery();
            if (rs != null && rs.next()) {
                setPictureSetId(pictureSetId);
                setPostId(rs.getInt("post_id"));
                setPersonId(rs.getInt("person_id"));
                setRecordTimestamp(rs.getTimestamp("record_timestamp"));
                setPictureSetTimestamp(rs.getTimestamp("picture_set_timestamp"));
                setReady(rs.getBoolean("ready"));
                setFlagged(rs.getBoolean("flagged"));
                setAnnotation(rs.getString("annotation"));

                retVal = true;
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: PictureSet.java, dbSelect(int pictureSetId), sqlText = " + sqlText + ", " + e.toString());
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

        if (getPictureSetId() > 0) {
            if (!dbIsValidPictureSetId(getPictureSetId())) {
                sqlText = "INSERT INTO picture_set VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                try { 
                    conn = DBPool.getInstance().getConnection();
                    stmt = conn.prepareStatement(sqlText);
                    stmt.setInt(1, getPictureSetId());
                    stmt.setInt(2, getPostId());
                    stmt.setInt(3, getPersonId());
                    stmt.setTimestamp(4, getRecordTimestamp());
                    stmt.setTimestamp(5, getPictureSetTimestamp());
                    stmt.setBoolean(6, getReady());
                    stmt.setBoolean(7, getFlagged());
                    stmt.setString(8, getAnnotation());
                    if (stmt.executeUpdate() == 1) {
                        retVal = true;
                    }
                    else {
                        Log.writeLog("ERROR: PictureSet.java, dbInsert(), sqlText = " + sqlText);
                    }
                }
                catch (Exception e) {
                    Log.writeLog("ERROR: PictureSet.java, dbInsert(), sqlText = " + sqlText + ", " + e.toString());
                }
                finally { 
                    try { stmt.close(); } catch (Exception e) { }
                    DBPool.getInstance().returnConnection(conn);
                }
            }
        }
   
        return retVal;
    }

    public boolean dbUpdate() {
        boolean retVal = false;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;

        if (getPictureSetId() > 0) {
            sqlText = "UPDATE picture_set SET (post_id, person_id, record_timestamp, picture_set_timestamp, ready, flagged, annotation) = (?, ?, ?, ?, ?, ?, ?) WHERE picture_set_id = ?";
            try { 
                conn = DBPool.getInstance().getConnection();
                stmt = conn.prepareStatement(sqlText);
                stmt.setInt(1, getPostId());
                stmt.setInt(2, getPersonId());
                stmt.setTimestamp(3, Utils.getCurrentTimestamp());
                stmt.setTimestamp(4, getPictureSetTimestamp());
                stmt.setBoolean(5, getReady());
                stmt.setBoolean(6, getFlagged());
                stmt.setString(7, getAnnotation());
                stmt.setInt(8, getPictureSetId());
                if (stmt.executeUpdate() == 1) {
                    retVal = true;
               		Utils.q().select("updatefulltextsearchidx()").execute();
                }
                else {
                    Log.writeLog("ERROR: PictureSet.java, dbUpdate(), sqlText = " + sqlText);
                }
            }
            catch (Exception e) {
                Log.writeLog("ERROR: PictureSet.java, dbUpdate(), sqlText = " + sqlText + ", " + e.toString());
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

        if (getPictureSetId() > 0) {

            // Delete the picture records first, since doing so will delete the image files.
            Vector<Picture> pictureRecords = dbGetPictureRecords();
            for (int i = 0; i < pictureRecords.size(); i++) {
                pictureRecords.get(i).dbDelete();
            }

            sqlText = "DELETE FROM picture_set WHERE picture_set_id = ?";
            try {
                conn = DBPool.getInstance().getConnection();
                stmt = conn.prepareStatement(sqlText);
                stmt.setInt(1, getPictureSetId());
                if (stmt.executeUpdate() == 1) {
                    clear();
                    retVal = true;
                }
                else {
                    Log.writeLog("ERROR: PictureSet.java, dbDelete(), sqlText = " + sqlText);
                }
            }
            catch (Exception e) {
                Log.writeLog("ERROR: PictureSet.java, dbDelete(), sqlText = " + sqlText + ", " + e.toString());
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
        PictureSet pictureSet = (PictureSet)o;

        if (pictureSet.getPictureSetId() == this.getPictureSetId() && this.getPictureSetId() != 0) {
            retVal = true;
        }

        return retVal;
    }

    public int getPictureSetId() {
        return this.pictureSetId;
    }

    public boolean dbSetPictureSetId() {
        boolean retVal = false;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        sqlText = "SELECT nextval('picture_set_picture_set_id_seq')";
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            rs = stmt.executeQuery();
            if (rs != null && rs.next()) {
                setPictureSetId(rs.getInt(1));
                retVal = true;
            }
            else {
                Log.writeLog("ERROR: PictureSet.java, dbSetPictureSetId(), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: PictureSet.java, dbSetPictureSetId(), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return retVal;
    }

    public void setPictureSetId(int pictureSetId) {
        this.pictureSetId = pictureSetId;
    }

    public int getPostId() {
        return this.postId;
    }

    public void setPostId(int postId) {
        this.postId = postId;
    }

    public int getPersonId() {
        return this.personId;
    }

    public void setPersonId(int personId) {
        this.personId = personId;
    }

    public java.sql.Timestamp getRecordTimestamp() {
        return this.recordTimestamp;
    }

    public void setRecordTimestamp(java.sql.Timestamp recordTimestamp) {
        this.recordTimestamp = recordTimestamp;
    }

    public java.sql.Timestamp getPictureSetTimestamp() {
        return this.pictureSetTimestamp;
    }

    public void setPictureSetTimestamp(java.sql.Timestamp pictureSetTimestamp) {
        this.pictureSetTimestamp = pictureSetTimestamp;
    }
    
    public void setPictureSetDate(java.util.Date date) {
    	this.pictureSetTimestamp = new Timestamp(date.getTime());
    }

    public boolean getReady() {
        return this.ready;
    }

    public void setReady(boolean ready) {
        this.ready = ready;
    }

    public boolean getFlagged() {
        return this.flagged;
    }

    public void setFlagged(boolean flagged) {
        this.flagged = flagged;
    }

    public String getAnnotation() {
        return this.annotation;
    }

    public void setAnnotation(String annotation) {
        this.annotation = annotation; if (this.annotation == null) this.annotation = "";
    }

    public Vector<Picture> dbGetPictureRecords() {
        Vector<Picture> pictureRecords = new Vector<Picture>();
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        sqlText = "SELECT picture_id FROM picture WHERE picture_set_id = ? ORDER BY picture_id";
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, getPictureSetId());
            rs = stmt.executeQuery();
            if (rs != null) {
                while (rs.next()) {
                    pictureRecords.add(new Picture(rs.getInt("picture_id")));
                }
            }
            else {
                Log.writeLog("ERROR: PictureSet.java, dbGetPictureRecords(), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: PictureSet.java, dbGetPictureRecords(), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return pictureRecords;
    }

    public static boolean dbIsValidPictureSetId(int pictureSetId) {
        boolean retVal = false;
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        String sqlText = "";

        sqlText = "SELECT COUNT(*) AS count FROM picture_set WHERE picture_set_id = ?";
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, pictureSetId);
            rs = stmt.executeQuery();
            if (rs != null && rs.next()) {
                if (rs.getInt("count") == 1) {
                    retVal = true;
                }
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: PictureSet.java, dbIsValidPictureSetId(int pictureSetId), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return retVal;
    }

    public static boolean dbIsValidPictureSetId(int pictureSetId, int postId) {
        boolean retVal = false;
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        String sqlText = "";

        sqlText = "SELECT COUNT(*) AS count FROM picture_set WHERE picture_set_id = ? AND post_id = ?";
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, pictureSetId);
            stmt.setInt(2, postId);
            rs = stmt.executeQuery();
            if (rs != null && rs.next()) {
                if (rs.getInt("count") == 1) {
                    retVal = true;
                }
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: PictureSet.java, dbIsValidPictureSetId(int pictureSetId, int postId), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return retVal;
    }

    public static boolean pictureRecordExists(PictureSet pictureSet, String orientation) {
        boolean retVal = false;

        if (pictureSet != null) {
            Vector<Picture> pictureRecords = pictureSet.dbGetPictureRecords();
            for (int p = 0; p < pictureRecords.size(); p++) {
                if (pictureRecords.get(p).getOrientation().equals(orientation)) {
                    retVal = true;
                }
            }
        }

        return retVal;
    }

    public static boolean pictureRecordExists(Vector<Picture> pictureRecords, String orientation) {
        boolean retVal = false;

        if (pictureRecords != null) {
            for (int p = 0; p < pictureRecords.size(); p++) {
                if (pictureRecords.get(p).getOrientation().equals(orientation)) {
                    retVal = true;
                }
            }
        }

        return retVal;
    }

    public static Picture getPictureRecord(PictureSet pictureSet, String orientation) {
        Picture retVal = null;

        Vector<Picture> pictureRecords = pictureSet.dbGetPictureRecords();
        for (int p = 0; p < pictureRecords.size(); p++) {
            if (pictureRecords.get(p).getOrientation().equals(orientation)) {
                retVal = pictureRecords.get(p);
            }
        }

        return retVal;
    }

    public static Picture getPictureRecord(Vector<Picture> pictureRecords, String orientation) {
        Picture retVal = null;

        for (int p = 0; p < pictureRecords.size(); p++) {
            if (pictureRecords.get(p).getOrientation().equals(orientation)) {
                retVal = pictureRecords.get(p);
            }
        }

        return retVal;
    }
    
    
    public static Vector<PictureSet> dbGetFlaggedPostRecords() {
        return PictureSet.dbGetFlaggedPostRecords("post_id");
    }
    
    public static Vector<PictureSet> dbGetFlaggedPostRecords(String orderBy) {
        Vector<PictureSet> flaggedsets = new Vector<PictureSet>();
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        sqlText = "SELECT * FROM picture_set WHERE flagged = 'true' ORDER BY " + orderBy;
        //sqlText = "SELECT * FROM picture_set WHERE post_id = 446 ORDER BY " + orderBy;
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            rs = stmt.executeQuery();
            if (rs != null) {
                while (rs.next()) {
                	flaggedsets.add(new PictureSet(rs.getInt("picture_set_id")));
                }
            }
            else {
                Log.writeLog("ERROR: Post.java, dbGetPostRecords(String orderBy), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Post.java, dbGetPostRecords(String orderBy), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }
        return flaggedsets;
    }
}
