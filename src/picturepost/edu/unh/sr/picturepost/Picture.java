package edu.unh.sr.picturepost;

import java.util.*;
import java.sql.*;
import java.io.*;

public class Picture {

    private int pictureId            = 0;
    private int pictureSetId         = 0;
    private String orientation       = "";
    private String imageFileOriginal = "";
    private String fileType          = "";
    private String fileExt           = "";

    private static String[] orientations = { "N", "NE", "E", "SE", "S", "SW", "W", "NW", "UP" };

    public Picture() {
        clear();
    }

    public Picture(int pictureId) {
        clear();
        dbSelect(pictureId);
    }

    public void clear() {
        setPictureId(0);
        setPictureSetId(0);
        setOrientation("");
        setImageFileOriginal("");
        setFileType("");
        setFileExt("");
    }

    public boolean dbSelect(int pictureId) {
        boolean retVal = false;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        sqlText = "SELECT picture_set_id, orientation, image_file_original, file_type, file_ext FROM picture WHERE picture_id = ?";
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, pictureId);
            rs = stmt.executeQuery();
            if (rs != null && rs.next()) {
                setPictureId(pictureId);
                setPictureSetId(rs.getInt("picture_set_id"));
                setOrientation(rs.getString("orientation"));
                setImageFileOriginal(rs.getString("image_file_original"));
                setFileType(rs.getString("file_type"));
                setFileExt(rs.getString("file_ext"));

                retVal = true;
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Picture.java, dbSelect(int pictureId), sqlText = " + sqlText + ", " + e.toString());
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

        if (getPictureId() > 0) {
            sqlText = "INSERT INTO picture VALUES (?, ?, ?, ?, ?, ?)";
            try {
                conn = DBPool.getInstance().getConnection();
                stmt = conn.prepareStatement(sqlText);
                stmt.setInt(1, getPictureId());
                stmt.setInt(2, getPictureSetId());
                stmt.setString(3, getOrientation());
                stmt.setString(4, getImageFileOriginal());
                stmt.setString(5, getFileType());
                stmt.setString(6, getFileExt());
                if (stmt.executeUpdate() == 1) {
                    retVal = true;
                }
                else {
                    Log.writeLog("ERROR: Picture.java, dbInsert(), sqlText = " + sqlText);
                }
            }
            catch (Exception e) {
                Log.writeLog("ERROR: Picture.java, dbInsert(), sqlText = " + sqlText + ", " + e.toString());
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

        if (getPictureId() > 0) {
            sqlText = "UPDATE picture SET (picture_set_id, orientation, image_file_original, file_type, file_ext) = (?, ?, ?, ?, ?) WHERE picture_id = ?";
            try {
                conn = DBPool.getInstance().getConnection();
                stmt = conn.prepareStatement(sqlText);
                stmt.setInt(1, getPictureSetId());
                stmt.setString(2, getOrientation());
                stmt.setString(3, getImageFileOriginal());
                stmt.setString(4, getFileType());
                stmt.setString(5, getFileExt());
                stmt.setInt(6, getPictureId());
                if (stmt.executeUpdate() == 1) {
                    retVal = true;
                }
                else {
                    Log.writeLog("ERROR: Picture.java, dbUpdate(), sqlText = " + sqlText);
                }
            }
            catch (Exception e) {
                Log.writeLog("ERROR: Picture.java, dbUpdate(), sqlText = " + sqlText + ", " + e.toString());
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

        if (getPictureId() > 0) {
            sqlText = "DELETE FROM picture WHERE picture_id = ?";
            try {
                conn = DBPool.getInstance().getConnection();
                stmt = conn.prepareStatement(sqlText);
                stmt.setInt(1, getPictureId());
                if (stmt.executeUpdate() == 1) {
                    deleteImageFiles();
                    clear();
                    retVal = true;
                }
                else {
                    Log.writeLog("ERROR: Picture.java, dbDelete(), sqlText = " + sqlText);
                }
            }
            catch (Exception e) {
                Log.writeLog("ERROR: Picture.java, dbDelete(), sqlText = " + sqlText + ", " + e.toString());
            }
            finally {
                try { stmt.close(); } catch (Exception e) { }
                DBPool.getInstance().returnConnection(conn);
            }
        }

        return retVal;
    }

    public void deleteImageFiles() {
        if (PictureSet.dbIsValidPictureSetId(getPictureSetId())) {
            PictureSet pictureSet = new PictureSet(getPictureSetId());
            Post post = new Post(pictureSet.getPostId());
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
    }

    public boolean equals(Object o) {
        boolean retVal = false;
        Picture picture = (Picture)o;

        if (picture.getPictureId() == this.getPictureId() && this.getPictureId() != 0) {
            retVal = true;
        }

        return retVal;
    }

    public int getPictureId() {
        return this.pictureId;
    }

    public boolean dbSetPictureId() {
        boolean retVal = false;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        sqlText = "SELECT nextval('picture_picture_id_seq')";
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            rs = stmt.executeQuery();
            if (rs != null && rs.next()) {
                setPictureId(rs.getInt(1));
                retVal = true;
            }
            else { 
                Log.writeLog("ERROR: Picture.java, dbSetPictureId(), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Picture.java, dbSetPictureId(), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return retVal;
    }

    public void setPictureId(int pictureId) {
        this.pictureId = pictureId;
    }

    public int getPictureSetId() {
        return this.pictureSetId;
    }

    public void setPictureSetId(int pictureSetId) {
        this.pictureSetId = pictureSetId;
    }

    public String getOrientation() {
        return this.orientation;
    }

    public void setOrientation(String orientation) {
        this.orientation = orientation; if (this.orientation == null) this.orientation = "";
    }

    public String getImageFile() {
        return "picture_" + String.valueOf(getPictureId()) + getFileExt();
    }

    public String getImageFileMedium() {
        return "picture_" + String.valueOf(getPictureId()) + "_medium" + getFileExt();
    }

    public String getImageFileThumb() {
        return "picture_" + String.valueOf(getPictureId()) + "_thumb" + getFileExt();
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

    public Vector<PictureMD> dbGetPictureMDRecords() {
        Vector<PictureMD> pictureMDRecords = new Vector<PictureMD>();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        String sqlText = "";

        sqlText = "SELECT picture_md_id FROM picture_md WHERE picture_id = ? ORDER BY directory, tag_id";
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, getPictureId());
            rs = stmt.executeQuery();
            if (rs != null) {
                while (rs.next()) {
                    pictureMDRecords.add(new PictureMD(rs.getInt("picture_md_id")));
                }
            }
            else {
                Log.writeLog("ERROR: Post.java, dbGetPictureMDRecords(), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Picture.java, dbGetPictureMDRecords(), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return pictureMDRecords;
    }

    public Vector<PictureComment> dbGetPictureCommentRecords() {
        Vector<PictureComment> pictureCommentRecords = new Vector<PictureComment>();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        String sqlText = "";

        sqlText = "SELECT picture_comment_id FROM picture_comment WHERE picture_id = ? ORDER BY comment_timestamp DESC";
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, getPictureId());
            rs = stmt.executeQuery();
            if (rs != null) {
                while (rs.next()) {
                    pictureCommentRecords.add(new PictureComment(rs.getInt("picture_comment_id")));
                }
            }
            else {
                Log.writeLog("ERROR: Post.java, dbGetPictureCommentRecords(), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Picture.java: dbGetPictureCommentRecords(), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return pictureCommentRecords;
    }

    public static boolean dbIsValidPictureId(int pictureId) {
        boolean retVal = false;
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        String sqlText = "";

        sqlText = "SELECT COUNT(*) FROM picture WHERE picture_id = ?";
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, pictureId);
            rs = stmt.executeQuery();
            if (rs != null && rs.next()) {
                if (rs.getInt(1) == 1) {
                    retVal = true;
                }
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Picture.java, dbIsValidPictureId(int pictureId), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return retVal;
    } 

    public static int getPictureIdPreviousOrientation(int curPictureId) {
        int retVal = curPictureId;

        if (dbIsValidPictureId(curPictureId)) {
            Picture picture = new Picture(curPictureId);
            PictureSet pictureSet = new PictureSet(picture.getPictureSetId());

            for (int i = 0; i < orientations.length; i++) {
                if (picture.getOrientation().equals(orientations[i])) {
                    for (int j = i - 1; j != i; j--) {
                        if (j == -1) j = orientations.length - 1;
                        if (PictureSet.pictureRecordExists(pictureSet, orientations[j])) {
                            retVal = PictureSet.getPictureRecord(pictureSet, orientations[j]).getPictureId();
                            break;
                        }
                    }
                    break;
                }
            }
        }

        return retVal;
    }

    public static int getPictureIdNextOrientation(int curPictureId) {
        int retVal = curPictureId;

        if (dbIsValidPictureId(curPictureId)) {
            Picture picture = new Picture(curPictureId);
            PictureSet pictureSet = new PictureSet(picture.getPictureSetId());

            for (int i = 0; i < orientations.length; i++) {
                if (picture.getOrientation().equals(orientations[i])) {
                    for (int j = i + 1; j != i; j++) {
                        if (j == orientations.length) j = 0;
                        if (PictureSet.pictureRecordExists(pictureSet, orientations[j])) {
                            retVal = PictureSet.getPictureRecord(pictureSet, orientations[j]).getPictureId();
                            break;
                        }
                    }
                    break;
                }
            }
        }

        return retVal;
    }

    public static int getPictureIdPreviousPictureSet(int curPictureId, int numPerPage, int curPage) {
        int retVal = curPictureId;

        if (dbIsValidPictureId(curPictureId)) {
            Picture picture = new Picture(curPictureId);
            PictureSet pictureSet = new PictureSet(picture.getPictureSetId());
            Post post = new Post(pictureSet.getPostId());
            Vector<PictureSet> pictureSetRecords = post.dbGetViewablePictureSetRecords(numPerPage, curPage);

            for (int i = 0; i < pictureSetRecords.size(); i++) {
                if (pictureSet.getPictureSetId() == pictureSetRecords.get(i).getPictureSetId()) {
                    for (int j = i - 1; j != i; j--) {
                        if (j == -1) j = pictureSetRecords.size() - 1;
                        if (PictureSet.pictureRecordExists(pictureSetRecords.get(j), picture.getOrientation())) {
                            retVal = PictureSet.getPictureRecord(pictureSetRecords.get(j), picture.getOrientation()).getPictureId();
                            break;
                        } 
                    }
                    break;
                }
            }
        }

        return retVal;
    }

    public static int getPictureIdNextPictureSet(int curPictureId, int numPerPage, int curPage) {
        int retVal = curPictureId;

        if (dbIsValidPictureId(curPictureId)) {
            Picture picture = new Picture(curPictureId);
            PictureSet pictureSet = new PictureSet(picture.getPictureSetId());
            Post post = new Post(pictureSet.getPostId());
            Vector<PictureSet> pictureSetRecords = post.dbGetViewablePictureSetRecords(numPerPage, curPage);

            for (int i = 0; i < pictureSetRecords.size(); i++) {
                if (pictureSet.getPictureSetId() == pictureSetRecords.get(i).getPictureSetId()) {
                    for (int j = i + 1; j != i; j++) {
                        if (j == pictureSetRecords.size()) j = 0;
                        if (PictureSet.pictureRecordExists(pictureSetRecords.get(j), picture.getOrientation())) {
                            retVal = PictureSet.getPictureRecord(pictureSetRecords.get(j), picture.getOrientation()).getPictureId();
                            break;
                        } 
                    }
                    break;
                }
            }
        }

        return retVal;
    }
}
