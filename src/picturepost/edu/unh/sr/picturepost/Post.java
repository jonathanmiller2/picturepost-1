package edu.unh.sr.picturepost;

import java.util.*;
import java.sql.*;

@SuppressWarnings("deprecation")

public class Post {
    private int postId                         = 0;
    private int personId                       = 0;
    private String name                        = "";
    private String description                 = "";
    private String logohtml                    = "";
    private String thankyouhtml                = "";
    private java.sql.Date installDate          = new java.sql.Date(Calendar.getInstance().getTimeInMillis());
    private int referencePictureSetId          = 0;
    private java.sql.Timestamp recordTimestamp = new java.sql.Timestamp(Calendar.getInstance().getTimeInMillis());
    private boolean ready                      = false;
    private double lat                         = 0.0;
    private double lon                         = 0.0;

    public Post() {
        clear();
    }

    public Post(int postId) {
        clear();
        dbSelect(postId);
    }

    public void clear() {
        setPostId(0);
        setPersonId(0);
        setName("");
        setDescription("");
        setLogoHtml("");
        setThankyouHtml("");
        setInstallDate(new java.sql.Date(Calendar.getInstance().getTimeInMillis()));
        setReferencePictureSetId(0);
        setRecordTimestamp(new java.sql.Timestamp(Calendar.getInstance().getTimeInMillis()));
        setReady(false);
        setLat(0.0);
        setLon(0.0);
    }

    public boolean dbSelect(int postId) {
        boolean retVal = false;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        sqlText = "SELECT person_id, name, description, logohtml, thankyouhtml, install_date, reference_picture_set_id, record_timestamp, ready, ST_Y(location) AS lat, ST_X(location) AS lon FROM post WHERE post_id = ?";
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, postId); 
            rs = stmt.executeQuery();
            if (rs != null && rs.next()) {
                setPostId(postId);
                setPersonId(rs.getInt("person_id"));
                setName(rs.getString("name"));
                setDescription(rs.getString("description"));
                setLogoHtml(rs.getString("logohtml"));
                setThankyouHtml(rs.getString("thankyouhtml"));
                setInstallDate(rs.getDate("install_date"));
                setReferencePictureSetId(rs.getInt("reference_picture_set_id"));
                setRecordTimestamp(rs.getTimestamp("record_timestamp"));
                setReady(rs.getBoolean("ready"));
                setLat(rs.getDouble("lat"));
                setLon(rs.getDouble("lon"));

                retVal = true;
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Post.java, dbSelect(int postId), sqlText = " + sqlText + ", " + e.toString());
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

        if (getPostId() > 0) {
            sqlText = "INSERT INTO post (post_id, person_id, name, description, install_date, reference_picture_set_id, record_timestamp, ready, location, txtsearch, thankyouhtml, logohtml) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ST_PointFromText('POINT(" + String.valueOf(getLon()) + " " + String.valueOf(getLat()) + ")', 4326), NULL, ?, ?)";
            try {
                conn = DBPool.getInstance().getConnection();
                stmt = conn.prepareStatement(sqlText);
                stmt.setInt(1, getPostId());
                stmt.setInt(2, getPersonId());
                stmt.setString(3, getName());
                stmt.setString(4, getDescription());
                stmt.setDate(5, getInstallDate());
                stmt.setInt(6, getReferencePictureSetId());
                stmt.setTimestamp(7, getRecordTimestamp());
                stmt.setBoolean(8, getReady());
                stmt.setString(9, getThankyouHtml());
                stmt.setString(10, getLogoHtml());
                if (stmt.executeUpdate() == 1) {
                    retVal = true;
                    new Q(conn).select("updatefulltextsearchidx()").execute();
                }
                else {
                    Log.writeLog("ERROR: Post.java, dbInsert(), sqlText = " + sqlText);
                }
            }
            catch (Exception e) {
                Log.writeLog("ERROR: Post.java, dbInsert(), sqlText = " + sqlText + ", " + e.toString());
            }
            finally {
                try { stmt.close(); } catch (Exception e) { }
                DBPool.getInstance().returnConnection(conn);
            }
        }

        return retVal;
    }

    public boolean dbUpdate() {
    	boolean rv = false;

        // post if ready if reference pictureset is uploaded
        if (getReferencePictureSetId() > 0) setReady(true);

    	int numUpdated = Utils.q().update("post")
    			.set("person_id","?",getPersonId())
    			.set("name","?",getName())
    			.set("description","?",getDescription())
    			.set("logohtml","?",getLogoHtml())
    			.set("thankyouhtml","?",getThankyouHtml())
    			.set("install_date","?",getInstallDate())
    			.set("reference_picture_set_id","?",getReferencePictureSetId())
    			.set("record_timestamp","?",getRecordTimestamp())
    			.set("ready","?",getReady())
    			.set("location", "ST_PointFromText('POINT(" 
    				+ String.valueOf(getLon()) + " " 
    				+ String.valueOf(getLat()) + ")', 4326)")
    			.set("txtsearch", "NULL")
    			.where("post_id=?").bind(getPostId())
    			.execute();
    	if (numUpdated==1) {
    		Utils.q().select("updatefulltextsearchidx()").execute();
    		rv = true;
    	}
    	return rv;
    }
    

    public boolean dbDelete() {
        boolean retVal = false;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;

        if (getPostId() > 0) {
            sqlText = "DELETE FROM post WHERE post_id = ?";
            try {
                conn = DBPool.getInstance().getConnection();
                stmt = conn.prepareStatement(sqlText);
                stmt.setInt(1, getPostId());
                if (stmt.executeUpdate() == 1) {
                    clear();
                    retVal = true;
                }
                else {
                    Log.writeLog("ERROR: Post.java, dbDelete(), sqlText = " + sqlText);
                }
            }
            catch (Exception e) {
                Log.writeLog("ERROR: Post.java, dbDelete(), sqlText = " + sqlText + ", " + e.toString());
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
        Post post = (Post)o;

        if (post.getPostId() == this.getPostId() && this.getPostId() != 0) {
            retVal = true;
        }

        return retVal;
    }

    public int getPostId() {
        return this.postId;
    }

    public boolean dbSetPostId() {
        boolean retVal = false;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        sqlText = "SELECT nextval('post_post_id_seq')";
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            rs = stmt.executeQuery();
            if (rs != null && rs.next()) {
                setPostId(rs.getInt(1));
                retVal = true;
            }
            else {
                Log.writeLog("ERROR: Post.java, dbSetPostId(), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Post.java, dbSetPostId(), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return retVal;
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

    public String getName() {
        return this.name;
    }

    public void setName(String name) {
        this.name = name;  if (this.name == null) this.name = "";
    }

    public String getDescription() {
        return this.description;
    }

    public void setDescription(String description) {
        this.description = description;  if (this.description == null) this.description = "";
    }

    public String getLogoHtml() {
        return this.logohtml;
    }

    public void setLogoHtml(String logohtml) {
        this.logohtml = logohtml;  if (this.logohtml == null) this.logohtml = "";
    }

    public String getThankyouHtml() {
        return this.thankyouhtml;
    }

    public void setThankyouHtml(String thankyouhtml) {
        this.thankyouhtml = thankyouhtml ;  if (this.thankyouhtml == null) this.thankyouhtml = "";
    }
    public java.sql.Date getInstallDate() {
        return this.installDate;
    }

    public void setInstallDate(java.sql.Date installDate) {
        this.installDate = installDate;
    }

    public int getInstallDateYear() {
        if (this.installDate == null) {
            return -1;
        }
        else {
            return this.installDate.getYear() + 1900;
        }
    }

    public void setInstallDateYear(int year) {
        this.installDate.setYear(year - 1900);
    }

    public void setInstallDateYear(String year) {
        try {
            this.installDate.setYear(Integer.parseInt(year) - 1900);
        }
        catch (Exception e) { }
    }

    public int getInstallDateMonth() {
        if (this.installDate == null) {
            return -1;
        }
        else {
            return this.installDate.getMonth() + 1;
        }
    }

    public void setInstallDateMonth(int month) {
        this.installDate.setMonth(month - 1);
    }

    public void setInstallDateMonth(String month) {
        try {
            this.installDate.setMonth(Integer.parseInt(month) - 1);
        }
        catch (Exception e) { }
    }

    public int getInstallDateDay() {
        if (this.installDate == null) {
            return -1;
        }
        else {
            return this.installDate.getDate();
        }
    }

    public void setInstallDateDay(int day) {
        this.installDate.setDate(day);
    }

    public void setInstallDateDay(String day) {
        try {
            this.installDate.setDate(Integer.parseInt(day));
        }
        catch (Exception e) { }
    }

    public int getReferencePictureSetId() {
        return this.referencePictureSetId;
    }

    public void setReferencePictureSetId(int referencePictureSetId) {
        this.referencePictureSetId = referencePictureSetId;
    }

    public java.sql.Timestamp getRecordTimestamp() {
        return this.recordTimestamp;
    }

    public void setRecordTimestamp(java.sql.Timestamp recordTimestamp) {
        this.recordTimestamp = recordTimestamp;
    }

    public boolean getReady() {
        return this.ready;
    }

    public void setReady(boolean ready) {
        this.ready = ready;
    }

    public double getLat() {
        return this.lat;
    }

    public void setLat(double lat) {
        if (lat >= -90.0 && lat <= 90.0) {
            this.lat = lat;
        }
    }

    public double getLon() {
        return this.lon;
    }

    public void setLon(double lon) {
        if (lon >= -180.0 && lon <= 180.0) {
            this.lon = lon;
        }
    }

    public static boolean dbIsValidPostId(int postId) {
        boolean retVal = false;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            sqlText = "SELECT COUNT(*) FROM post WHERE post_id = ?";
            try {
                conn = DBPool.getInstance().getConnection();
                stmt = conn.prepareStatement(sqlText);
                stmt.setInt(1, postId);
                rs = stmt.executeQuery();
                if (rs != null && rs.next()) {
                    if (rs.getInt(1) == 1) {
                        retVal = true;
                    }
                }
            }
            catch (Exception e) {
                Log.writeLog("ERROR: Post.java, dbIsValidPostId(int postId), sqlText = " + sqlText + ", " + e.toString());
            }
            finally {
                try { stmt.close(); } catch (Exception e) { }
                DBPool.getInstance().returnConnection(conn);
            }
        }
        catch (NumberFormatException e) { }

        return retVal;
    }

    public static boolean dbIsValidPostId(int postId, int personId) {
        boolean retVal = false;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            sqlText = "SELECT COUNT(*) FROM post WHERE post_id = ? AND person_id = ?";
            try {
                conn = DBPool.getInstance().getConnection();
                stmt = conn.prepareStatement(sqlText);
                stmt.setInt(1, postId);
                stmt.setInt(2, personId);
                rs = stmt.executeQuery();
                if (rs != null && rs.next()) {
                    if (rs.getInt(1) == 1) {
                        retVal = true;
                    }
                }
            }
            catch (Exception e) {
                Log.writeLog("ERROR: Post.java, dbIsValidPostId(int postId, int personId), sqlText = " + sqlText + ", " + e.toString());
            }
            finally {
                try { stmt.close(); } catch (Exception e) { }
                DBPool.getInstance().returnConnection(conn);
            }
        }
        catch (NumberFormatException e) { }

        return retVal;
    }

    public static Vector<Post> dbGetPostRecords() {
        return Post.dbGetPostRecords("name");
    }

    public static Vector<Post> dbGetPostRecords(String orderBy) {
        Vector<Post> postRecords = new Vector<Post>();
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        sqlText = "SELECT post_id FROM post WHERE ready = 't' ORDER BY " + orderBy;
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            rs = stmt.executeQuery();
            if (rs != null) {
                while (rs.next()) {
                    postRecords.add(new Post(rs.getInt("post_id")));
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

        return postRecords;
    }

    public static Vector<Post> dbGetPostRecords(int personId) {
        return Post.dbGetPostRecords(personId, "name");
    }

    public static Vector<Post> dbGetPostRecords(int personId, String orderBy) {
        Vector<Post> postRecords = new Vector<Post>();
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        sqlText = "SELECT post_id FROM post WHERE ready = 't' AND person_id = ? ORDER BY " + orderBy;
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, personId);
            rs = stmt.executeQuery();
            if (rs != null) {
                while (rs.next()) {
                    postRecords.add(new Post(rs.getInt("post_id")));
                }
            }
            else {
                Log.writeLog("ERROR: Post.java, dbGetPostRecords(int personId, String orderBy), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Post.java, dbGetPostRecords(int personId, String orderBy), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return postRecords;
    }

    public static Vector<Post> dbGetPostRecords(java.sql.Timestamp afterTime, java.sql.Timestamp beforeTime) {
        return dbGetPostRecords(afterTime, beforeTime, "name");
    }

    public static Vector<Post> dbGetPostRecords(java.sql.Timestamp afterTime, java.sql.Timestamp beforeTime, String orderBy) {
        Vector<Post> postRecords = new Vector<Post>();
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        if (afterTime != null && beforeTime != null) {
            sqlText = "SELECT post_id FROM post WHERE ready = 't' AND install_date >= ? AND install_date <= ? ORDER BY " + orderBy;
        }
        else if (afterTime != null && beforeTime == null) {
            sqlText = "SELECT post_id FROM post WHERE ready = 't' AND install_date >= ? ORDER BY " + orderBy;
        }
        else if (afterTime == null && beforeTime != null) {
            sqlText = "SELECT post_id FROM post WHERE ready = 't' AND install_date <= ? ORDER BY " + orderBy;
        }
        else if (afterTime == null && beforeTime == null) {
            sqlText = "SELECT post_id FROM post WHERE ready = 't' ORDER BY " + orderBy;
        }
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            if (afterTime != null && beforeTime != null) {
                stmt.setTimestamp(1, afterTime);
                stmt.setTimestamp(2, beforeTime);
            }
            else if (afterTime != null && beforeTime == null) {
                stmt.setTimestamp(1, afterTime);
            }
            else if (afterTime == null && beforeTime != null) {
                stmt.setTimestamp(1, beforeTime);
            }
            rs = stmt.executeQuery();
            if (rs != null) {
                while (rs.next()) {
                    postRecords.add(new Post(rs.getInt("post_id")));
                }
            }
            else {
                Log.writeLog("ERROR: Post.java, dbGetPostRecords(java.sql.Timestamp afterTime, java.sql.Timestamp beforeTime, String orderBy), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Post.java, dbGetPostRecords(java.sql.Timestamp afterTime, java.sql.Timestamp beforeTime, String orderBy), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return postRecords;
    }

    public static Vector<Post> dbGetPostRecords(int personId, java.sql.Timestamp afterTime, java.sql.Timestamp beforeTime) {
        return dbGetPostRecords(personId, afterTime, beforeTime, "name");
    }

    public static Vector<Post> dbGetPostRecords(int personId, java.sql.Timestamp afterTime, java.sql.Timestamp beforeTime, String orderBy) {
        Vector<Post> postRecords = new Vector<Post>();
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        if (afterTime != null && beforeTime != null) {
            sqlText = "SELECT post_id FROM post WHERE ready = 't' AND person_id = ? AND install_date >= ? AND install_date <= ? ORDER BY " + orderBy;
        }
        else if (afterTime != null && beforeTime == null) {
            sqlText = "SELECT post_id FROM post WHERE ready = 't' AND person_id = ? AND install_date >= ? ORDER BY " + orderBy;
        }
        else if (afterTime == null && beforeTime != null) {
            sqlText = "SELECT post_id FROM post WHERE ready = 't' AND person_id = ? AND install_date <= ? ORDER BY " + orderBy;
        }
        else if (afterTime == null && beforeTime == null) {
            sqlText = "SELECT post_id FROM post WHERE ready = 't' AND person_id = ? ORDER BY " + orderBy;
        }
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, personId);
            if (afterTime != null && beforeTime != null) {
                stmt.setTimestamp(2, afterTime);
                stmt.setTimestamp(3, beforeTime);
            }
            else if (afterTime != null && beforeTime == null) {
                stmt.setTimestamp(2, afterTime);
            }
            else if (afterTime == null && beforeTime != null) {
                stmt.setTimestamp(2, beforeTime);
            }
            rs = stmt.executeQuery();
            if (rs != null) {
                while (rs.next()) {
                    postRecords.add(new Post(rs.getInt("post_id")));
                }
            }
            else {
                Log.writeLog("ERROR: Post.java, dbGetPostRecords(int personId, java.sql.Timestamp afterTime, java.sql.Timestamp beforeTime, String orderBy), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Post.java, dbGetPostRecords(int personId, java.sql.Timestamp afterTime, java.sql.Timestamp beforeTime, String orderBy), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return postRecords;
    }

    public static Vector<Post> dbGetPostRecords(double lat, double lon) {
        return Post.dbGetPostRecords(lat, lon, "name");
    }

    public static Vector<Post> dbGetPostRecords(double lat, double lon, String orderBy) {
        Vector<Post> postRecords = new Vector<Post>();
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        String distance = "ST_Distance(ST_GeogFromText(ST_AsEWKT(location)), ST_GeogFromText('POINT(" + Double.toString(lon) + " " + Double.toString(lat) + ")'))";

        sqlText = "SELECT post_id, " + distance + " AS radius FROM post WHERE ready = 't' ORDER BY " + orderBy;
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            rs = stmt.executeQuery();
            if (rs != null) {
                while (rs.next()) {
                    postRecords.add(new Post(rs.getInt("post_id")));
                }
            }
            else {
                Log.writeLog("ERROR: Post.java, dbGetPostRecords(double lat, double lon, String orderBy), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Post.java, dbGetPostRecords(double lat, double lon, String orderBy), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return postRecords;
    }

    public static Vector<Post> dbGetPostRecords(int personId, double lat, double lon) {
        return Post.dbGetPostRecords(personId, lat, lon, "name");
    }

    public static Vector<Post> dbGetPostRecords(int personId, double lat, double lon, String orderBy) {
        Vector<Post> postRecords = new Vector<Post>();
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        String distance = "ST_Distance(ST_GeogFromText(ST_AsEWKT(location)), ST_GeogFromText('POINT(" + Double.toString(lon) + " " + Double.toString(lat) + ")'))";

        sqlText = "SELECT post_id, " + distance + " AS radius FROM post WHERE ready = 't' AND person_id = ? ORDER BY " + orderBy;
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, personId);
            rs = stmt.executeQuery();
            if (rs != null) {
                while (rs.next()) {
                    postRecords.add(new Post(rs.getInt("post_id")));
                }
            }
            else {
                Log.writeLog("ERROR: Post.java, dbGetPostRecords(int personId, double lat, double lon, String orderBy), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Post.java, dbGetPostRecords(int personId, double lat, double lon, String orderBy), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return postRecords;
    }

    public static Vector<Post> dbGetPostRecords(double lat, double lon, int radius) {
        return Post.dbGetPostRecords(lat, lon, radius, "name");
    }

    public static Vector<Post> dbGetPostRecords(double lat, double lon, int radius, String orderBy) {
        Vector<Post> postRecords = new Vector<Post>();
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        String distance = "ST_Distance(ST_GeogFromText(ST_AsEWKT(location)), ST_GeogFromText('POINT(" + Double.toString(lon) + " " + Double.toString(lat) + ")'))";

        sqlText = "SELECT post_id, " + distance + " AS radius FROM post WHERE ready = 't' AND " + distance + " <= ? ORDER BY " + orderBy;
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, radius);
            rs = stmt.executeQuery();
            if (rs != null) {
                while (rs.next()) {
                    postRecords.add(new Post(rs.getInt("post_id")));
                }
            }
            else {
                Log.writeLog("ERROR: Post.java, dbGetPostRecords(double lat, double lon, int radius, String orderBy), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Post.java, dbGetPostRecords(double lat, double lon, int radius, String orderBy), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return postRecords;
    }

    public static Vector<Post> dbGetPostRecords(int personId, double lat, double lon, int radius) {
        return Post.dbGetPostRecords(personId, lat, lon, radius, "name");
    }

    public static Vector<Post> dbGetPostRecords(int personId, double lat, double lon, int radius, String orderBy) {
        Vector<Post> postRecords = new Vector<Post>();
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        String distance = "ST_Distance(ST_GeogFromText(ST_AsEWKT(location)), ST_GeogFromText('POINT(" + Double.toString(lon) + " " + Double.toString(lat) + ")'))";

        sqlText = "SELECT post_id, " + distance + " AS radius FROM post WHERE ready = 't' AND person_id = ? AND " + distance + " <= ? ORDER BY " + orderBy;
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, personId);
            stmt.setInt(2, radius);
            rs = stmt.executeQuery();
            if (rs != null) {
                while (rs.next()) {
                    postRecords.add(new Post(rs.getInt("post_id")));
                }
            }
            else {
                Log.writeLog("ERROR: Post.java, dbGetPostRecords(int personId, double lat, double lon, int radius, String orderBy), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Post.java, dbGetPostRecords(int personId, double lat, double lon, int radius, String orderBy), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return postRecords;
    }

    public static Vector<Post> dbGetPostRecords(double lat, double lon, java.sql.Timestamp afterTime, java.sql.Timestamp beforeTime) {
        return Post.dbGetPostRecords(lat, lon, afterTime, beforeTime, "name");
    }

    public static Vector<Post> dbGetPostRecords(double lat, double lon, java.sql.Timestamp afterTime, java.sql.Timestamp beforeTime, String orderBy) {
        Vector<Post> postRecords = new Vector<Post>();
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        String distance = "ST_Distance(ST_GeogFromText(ST_AsEWKT(location)), ST_GeogFromText('POINT(" + Double.toString(lon) + " " + Double.toString(lat) + ")'))";

        if (afterTime != null && beforeTime != null) {
            sqlText = "SELECT post_id, " + distance + " AS radius FROM post WHERE ready = 't' AND install_date >= ? AND install_date <= ? ORDER BY " + orderBy;
        }
        else if (afterTime != null && beforeTime == null) {
            sqlText = "SELECT post_id, " + distance + " AS radius FROM post WHERE ready = 't' AND install_date >= ? ORDER BY " + orderBy;
        }
        else if (afterTime == null && beforeTime != null) {
            sqlText = "SELECT post_id, " + distance + " AS radius FROM post WHERE ready = 't' AND install_date <= ? ORDER BY " + orderBy;
        }
        else if (afterTime == null && beforeTime == null) {
            sqlText = "SELECT post_id, " + distance + " AS radius FROM post WHERE ready = 't' ORDER BY " + orderBy;
        }
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            if (afterTime != null && beforeTime != null) {
                stmt.setTimestamp(1, afterTime);
                stmt.setTimestamp(2, beforeTime);
            }
            else if (afterTime != null && beforeTime == null) {
                stmt.setTimestamp(1, afterTime);
            }
            else if (afterTime == null && beforeTime != null) {
                stmt.setTimestamp(1, beforeTime);
            }
            rs = stmt.executeQuery();
            if (rs != null) {
                while (rs.next()) {
                    postRecords.add(new Post(rs.getInt("post_id")));
                }
            }
            else {
                Log.writeLog("ERROR: Post.java, dbGetPostRecords(double lat, double lon, String orderBy, java.sql.Timestamp afterTime, java.sql.Timestamp beforeTime, String orderBy), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Post.java, dbGetPostRecords(double lat, double lon, java.sql.Timestamp afterTime, java.sql.Timestamp beforeTime, String orderBy), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return postRecords;
    }

    public static Vector<Post> dbGetPostRecords(int personId, double lat, double lon, java.sql.Timestamp afterTime, java.sql.Timestamp beforeTime) {
        return Post.dbGetPostRecords(personId, lat, lon, afterTime, beforeTime, "name");
    }

    public static Vector<Post> dbGetPostRecords(int personId, double lat, double lon, java.sql.Timestamp afterTime, java.sql.Timestamp beforeTime, String orderBy) {
        Vector<Post> postRecords = new Vector<Post>();
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        String distance = "ST_Distance(ST_GeogFromText(ST_AsEWKT(location)), ST_GeogFromText('POINT(" + Double.toString(lon) + " " + Double.toString(lat) + ")'))";

        if (afterTime != null && beforeTime != null) {
            sqlText = "SELECT post_id, " + distance + " AS radius FROM post WHERE ready = 't' AND person_id = ? AND install_date >= ? AND install_date <= ? ORDER BY " + orderBy;
        }
        else if (afterTime != null && beforeTime == null) {
            sqlText = "SELECT post_id, " + distance + " AS radius FROM post WHERE ready = 't' AND person_id = ? AND install_date >= ? ORDER BY " + orderBy;
        }
        else if (afterTime == null && beforeTime != null) {
            sqlText = "SELECT post_id, " + distance + " AS radius FROM post WHERE ready = 't' AND person_id = ? AND install_date <= ? ORDER BY " + orderBy;
        }
        else if (afterTime == null && beforeTime == null) {
            sqlText = "SELECT post_id, " + distance + " AS radius FROM post WHERE ready = 't' AND person_id = ? ORDER BY " + orderBy;
        }
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, personId);
            if (afterTime != null && beforeTime != null) {
                stmt.setTimestamp(2, afterTime);
                stmt.setTimestamp(3, beforeTime);
            }
            else if (afterTime != null && beforeTime == null) {
                stmt.setTimestamp(2, afterTime);
            }
            else if (afterTime == null && beforeTime != null) {
                stmt.setTimestamp(2, beforeTime);
            }
            rs = stmt.executeQuery();
            if (rs != null) {
                while (rs.next()) {
                    postRecords.add(new Post(rs.getInt("post_id")));
                }
            }
            else {
                Log.writeLog("ERROR: Post.java, dbGetPostRecords(int personId, double lat, double lon, String orderBy, java.sql.Timestamp afterTime, java.sql.Timestamp beforeTime, String orderBy), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Post.java, dbGetPostRecords(int personId, double lat, double lon, java.sql.Timestamp afterTime, java.sql.Timestamp beforeTime, String orderBy), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return postRecords;
    }

    public static Vector<Post> dbGetPostRecords(double lat, double lon, int radius, java.sql.Timestamp afterTime, java.sql.Timestamp beforeTime) {
        return Post.dbGetPostRecords(lat, lon, radius, afterTime, beforeTime, "name");
    }

    public static Vector<Post> dbGetPostRecords(double lat, double lon, int radius, java.sql.Timestamp afterTime, java.sql.Timestamp beforeTime, String orderBy) {
        Vector<Post> postRecords = new Vector<Post>();
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        String distance = "ST_Distance(ST_GeogFromText(ST_AsEWKT(location)), ST_GeogFromText('POINT(" + Double.toString(lon) + " " + Double.toString(lat) + ")'))";

        if (afterTime != null && beforeTime != null) {
            sqlText = "SELECT post_id, " + distance + " AS radius FROM post WHERE ready = 't' AND " + distance + " <= ? AND install_date >= ? AND install_date <= ? ORDER BY " + orderBy;
        }
        else if (afterTime != null && beforeTime == null) {
            sqlText = "SELECT post_id, " + distance + " AS radius FROM post WHERE ready = 't' AND " + distance + " <= ? AND install_date >= ? ORDER BY " + orderBy;
        }
        else if (afterTime == null && beforeTime != null) {
            sqlText = "SELECT post_id, " + distance + " AS radius FROM post WHERE ready = 't' AND " + distance + " <= ? AND install_date <= ? ORDER BY " + orderBy;
        }
        else if (afterTime == null && beforeTime == null) {
            sqlText = "SELECT post_id, " + distance + " AS radius FROM post WHERE ready = 't' AND " + distance + " <= ? ORDER BY " + orderBy;
        }
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, radius);
            if (afterTime != null && beforeTime != null) {
                stmt.setTimestamp(2, afterTime);
                stmt.setTimestamp(3, beforeTime);
            }
            else if (afterTime != null && beforeTime == null) {
                stmt.setTimestamp(2, afterTime);
            }
            else if (afterTime == null && beforeTime != null) {
                stmt.setTimestamp(2, beforeTime);
            }
            rs = stmt.executeQuery();
            if (rs != null) {
                while (rs.next()) {
                    postRecords.add(new Post(rs.getInt("post_id")));
                }
            }
            else {
                Log.writeLog("ERROR: Post.java, dbGetPostRecords(double lat, double lon, int radius, String orderBy, java.sql.Timestamp afterTime, java.sql.Timestamp beforeTime, String orderBy), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Post.java, dbGetPostRecords(double lat, double lon, int radius, java.sql.Timestamp afterTime, java.sql.Timestamp beforeTime, String orderBy), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return postRecords;
    }

    public static Vector<Post> dbGetPostRecords(int personId, double lat, double lon, int radius, java.sql.Timestamp afterTime, java.sql.Timestamp beforeTime) {
        return Post.dbGetPostRecords(personId, lat, lon, radius, afterTime, beforeTime, "name");
    }

    public static Vector<Post> dbGetPostRecords(int personId, double lat, double lon, int radius, java.sql.Timestamp afterTime, java.sql.Timestamp beforeTime, String orderBy) {
        Vector<Post> postRecords = new Vector<Post>();
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        String distance = "ST_Distance(ST_GeogFromText(ST_AsEWKT(location)), ST_GeogFromText('POINT(" + Double.toString(lon) + " " + Double.toString(lat) + ")'))";

        if (afterTime != null && beforeTime != null) {
            sqlText = "SELECT post_id, " + distance + " AS radius FROM post WHERE ready = 't' AND person_id = ? AND " + distance + " <= ? AND install_date >= ? AND install_date <= ? ORDER BY " + orderBy;
        }
        else if (afterTime != null && beforeTime == null) {
            sqlText = "SELECT post_id, " + distance + " AS radius FROM post WHERE ready = 't' AND person_id = ? AND " + distance + " <= ? AND install_date >= ? ORDER BY " + orderBy;
        }
        else if (afterTime == null && beforeTime != null) {
            sqlText = "SELECT post_id, " + distance + " AS radius FROM post WHERE ready = 't' AND person_id = ? AND " + distance + " <= ? AND install_date <= ? ORDER BY " + orderBy;
        }
        else if (afterTime == null && beforeTime == null) {
            sqlText = "SELECT post_id, " + distance + " AS radius FROM post WHERE ready = 't' AND person_id = ? AND " + distance + " <= ? ORDER BY " + orderBy;
        }
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, personId);
            stmt.setInt(2, radius);
            if (afterTime != null && beforeTime != null) {
                stmt.setTimestamp(3, afterTime);
                stmt.setTimestamp(4, beforeTime);
            }
            else if (afterTime != null && beforeTime == null) {
                stmt.setTimestamp(3, afterTime);
            }
            else if (afterTime == null && beforeTime != null) {
                stmt.setTimestamp(3, beforeTime);
            }
            rs = stmt.executeQuery();
            if (rs != null) {
                while (rs.next()) {
                    postRecords.add(new Post(rs.getInt("post_id")));
                }
            }
            else {
                Log.writeLog("ERROR: Post.java, dbGetPostRecords(int personId, java.sql.Timestamp afterTime, java.sql.Timestamp beforeTime, double lat, double lon, int radius, String orderBy), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Post.java, dbGetPostRecords(int personId, java.sql.Timestamp afterTime, java.sql.Timestamp beforeTime, double lat, double lon, int radius, String orderBy), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return postRecords;
    }

    public Vector<Integer> dbGetPictureSetIds() {
        return dbGetPictureSetIds("picture_set_timestamp desc");
    }

    public Vector<Integer> dbGetPictureSetIds(String orderBy) {
        Vector<Integer> pictureSetIds = new Vector<Integer>();
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        orderBy = orderBy.toLowerCase();
        if (!orderBy.equals("picture_set_timestamp desc") && 
            !orderBy.equals("picture_set_timestamp")  &&
            !orderBy.equals("record_timestamp desc")      &&
            !orderBy.equals("record_timestamp")) {

            orderBy = "picture_set_timestamp_desc";
        }
        sqlText = "SELECT picture_set_id FROM picture_set WHERE post_id = ? ORDER BY " + orderBy + ", picture_set_id DESC";
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, getPostId());
            rs = stmt.executeQuery();
            if (rs != null) {
                while (rs.next()) {
                    pictureSetIds.add(new Integer(rs.getInt("picture_set_id")));
                }
            }
            else {
                Log.writeLog("ERROR: Post.java, dbGetPictureSetIds(String orderBy), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Post.java, dbGetPictureSetIds(String orderBy), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return pictureSetIds;
    }

    public Vector<Integer> dbGetViewablePictureSetIds() {
        return dbGetViewablePictureSetIds("picture_set_timestamp desc");
    }

    public Vector<Integer> dbGetViewablePictureSetIds(String orderBy) {
        Vector<Integer> pictureSetIds = new Vector<Integer>();
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        orderBy = orderBy.toLowerCase();
        if (!orderBy.equals("picture_set_timestamp desc") && 
            !orderBy.equals("picture_set_timestamp")  &&
            !orderBy.equals("record_timestamp desc")      &&
            !orderBy.equals("record_timestamp")) {

            orderBy = "picture_set_timestamp desc";
        }
        sqlText = "SELECT picture_set_id FROM picture_set WHERE post_id = ? AND ready = 'true' AND flagged = 'false' ORDER BY " + orderBy + ", picture_set_id DESC";
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, getPostId());
            rs = stmt.executeQuery();
            if (rs != null) {
                while (rs.next()) {
                    pictureSetIds.add(new Integer(rs.getInt("picture_set_id")));
                }
            }
            else {
                Log.writeLog("ERROR: Post.java, dbGetViewablePictureSetIds(String orderBy), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Post.java, dbGetViewablePictureSetIds(String orderBy), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return pictureSetIds;
    }

    public Vector<PictureSet> dbGetPictureSetRecords() {
        return dbGetPictureSetRecords("picture_set_timestamp DESC, picture_set_id DESC");
    }

    public Vector<PictureSet> dbGetPictureSetRecords(String orderBy) {
        Vector<PictureSet> pictureSetRecords = new Vector<PictureSet>();
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        orderBy = orderBy.toLowerCase();
        if (!orderBy.equals("picture_set_timestamp desc, picture_set_id desc") &&
            !orderBy.equals("picture_set_timestamp, picture_set_id")) {

            orderBy = "picture_set_timestamp desc, picture_set_id desc";
        }

        sqlText = "SELECT picture_set_id FROM picture_set WHERE post_id = ? ORDER BY " + orderBy;
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, getPostId());
            rs = stmt.executeQuery();
            if (rs != null) {
                while (rs.next()) {
                    pictureSetRecords.add(new PictureSet(rs.getInt("picture_set_id")));
                }
            }
            else {
                Log.writeLog("ERROR: Post.java, dbGetPictureSetRecords(String orderBy), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Post.java, dbGetPictureSetRecords(String orderBy), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return pictureSetRecords;
    }

    public int dbGetNumViewablePictureSetRecords() {
        int retVal = 0;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        sqlText = "SELECT COUNT(*) FROM picture_set WHERE post_id = ? AND ready = 'true' AND flagged = 'false'";
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, getPostId());
            rs = stmt.executeQuery();
            if (rs != null && rs.next()) {
                retVal = rs.getInt(1);
            }
            else {
                Log.writeLog("ERROR: Post.java, dbGetNumViewablePictureSetRecords(), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Post.java, dbGetNumViewablePictureSetRecords(), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return retVal;
    }

    public java.sql.Timestamp dbGetDateMostRecentPictureSet() {
        java.sql.Timestamp retVal = null;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        sqlText = "SELECT picture_set_timestamp FROM picture_set WHERE post_id = ? AND ready = 'true' AND flagged = 'false' ORDER BY picture_set_timestamp DESC LIMIT 1";
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, getPostId());
            rs = stmt.executeQuery();
            if (rs != null) {
                if (rs.next()) {
                    retVal = rs.getTimestamp(1);
                }
            }
            else {
                Log.writeLog("ERROR: Post.java, dbGetDateMostRecentPictureSet(), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Post.java, dbGetDateMostRecentPictureSet(), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return retVal;
    }

    public Vector<PictureSet> dbGetViewablePictureSetRecords() {
        Vector<PictureSet> pictureSetRecords = new Vector<PictureSet>();
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        sqlText = "SELECT picture_set_id FROM picture_set WHERE post_id = ? AND ready = 'true' AND flagged = 'false' ORDER BY picture_set_timestamp DESC, picture_set_id DESC";
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, getPostId());
            rs = stmt.executeQuery();
            if (rs != null) {
                while (rs.next()) {
                    pictureSetRecords.add(new PictureSet(rs.getInt("picture_set_id")));
                }
            }
            else {
                Log.writeLog("ERROR: Post.java, dbGetViewablePictureSetRecords(), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Post.java, dbGetViewablePictureSetRecords(), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return pictureSetRecords;
    }

    public Vector<PictureSet> dbGetViewablePictureSetRecords(int numPerPage, int curPage) {
        Vector<PictureSet> pictureSetRecords = new Vector<PictureSet>();
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        int num = 0;

        if (curPage >= 0) {
            sqlText = "SELECT picture_set_id FROM picture_set WHERE post_id = ? AND ready = 'true' AND flagged = 'false' ORDER BY picture_set_timestamp DESC, picture_set_id DESC";
            try {
                conn = DBPool.getInstance().getConnection();
                stmt = conn.prepareStatement(sqlText);
                stmt.setInt(1, getPostId());
                rs = stmt.executeQuery();
                if (rs != null) {
                    while (rs.next()) {
                        if (numPerPage < 1 || (num >= curPage * numPerPage && num < (curPage + 1) * numPerPage)) {
                            pictureSetRecords.add(new PictureSet(rs.getInt("picture_set_id")));
                        }
                        num++;
                    }
                }
                else {
                    Log.writeLog("ERROR: Post.java, dbGetViewablePictureSetRecords(int numPerPage, int curPage), sqlText = " + sqlText);
                }
            }
            catch (Exception e) {
                Log.writeLog("ERROR: Post.java, dbGetViewablePictureSetRecords(int numPerPage, int curPage), sqlText = " + sqlText + ", " + e.toString());
            }
            finally {
                try { stmt.close(); } catch (Exception e) { }
                DBPool.getInstance().returnConnection(conn);
            }
        }

        return pictureSetRecords;
    }

    public int dbGetNumViewablePictureSetPages(int numPerPage) {
        int retVal = 1;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        int num = 0;

        if (numPerPage > 0) {
            sqlText = "SELECT COUNT(*) FROM picture_set WHERE post_id = ? AND ready = 'true' AND flagged = 'false'";
            try {
                conn = DBPool.getInstance().getConnection();
                stmt = conn.prepareStatement(sqlText);
                stmt.setInt(1, getPostId());
                rs = stmt.executeQuery();
                if (rs != null) {
                    while (rs.next()) {
                        num = rs.getInt(1);
                    }
                }
                else {
                    Log.writeLog("ERROR: Post.java, dbGetNumviewablePictureSetPages(int numPerPage), sqlText = " + sqlText);
                }
            }
            catch (Exception e) {
                Log.writeLog("ERROR: Post.java, dbGetNumViewablePictureSetPages(int numPerPage), sqlText = " + sqlText + ", " + e.toString());
            }
            finally {
                try { stmt.close(); } catch (Exception e) { }
                DBPool.getInstance().returnConnection(conn);
            }

            retVal = num / numPerPage;
            if (num % numPerPage > 0) retVal++;
        }

        return retVal;
    }

    public boolean dbPictureSetRecordExistsForTimestamp(java.sql.Timestamp pictureSetTimestamp) {
        boolean retVal = false;
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        String sqlText = "";

        sqlText = "SELECT COUNT(*) AS count FROM picture_set WHERE picture_set_timestamp = ? AND post_id = ?";
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setTimestamp(1, pictureSetTimestamp);
            stmt.setInt(2, getPostId());
            rs = stmt.executeQuery();
            if (rs != null && rs.next()) {
                if (rs.getInt("count") > 0) {
                    retVal = true;
                }
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Post.java, dbPictureSetRecordExistsForTimestamp(java.sql.Timestamp pictureSetTimestamp), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return retVal;
    }


    public String getPostDir() { 
        return "post_" + String.valueOf(getPostId());
    }

    public Vector<PostPicture> dbGetPostPictureRecords() {
        Vector<PostPicture> postPictureRecords = new Vector<PostPicture>();
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        sqlText = "SELECT post_picture_id FROM post_picture WHERE post_id = ? ORDER BY seq_nbr";
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, getPostId());
            rs = stmt.executeQuery();
            if (rs != null) {
                while (rs.next()) {
                    postPictureRecords.add(new PostPicture(rs.getInt(1)));
                }
            }
            else {
                Log.writeLog("ERROR: Post.java, dbGetPostPictureRecords(), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Post.java, dbGetPostPictureRecords(), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return postPictureRecords;
    }

    public int dbGetNumPostPictureRecords() {
        int retVal = 0;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        sqlText = "SELECT COUNT(*) FROM post_picture WHERE post_id = ?";
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, getPostId());
            rs = stmt.executeQuery();
            if (rs != null && rs.next()) {
                retVal = rs.getInt(1);
            }
            else {
                Log.writeLog("ERROR: Post.java, dbGetNumPostPictureRecords(), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Post.java, dbGetNumPostPictureRecords(), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return retVal;
    }

    public Vector<PostPicture> dbGetActivePostPictureRecords() {
        Vector<PostPicture> postPictureRecords = new Vector<PostPicture>();
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        sqlText = "SELECT post_picture_id FROM post_picture WHERE post_id = ? AND active = true ORDER BY seq_nbr";
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, getPostId());
            rs = stmt.executeQuery();
            if (rs != null) {
                while (rs.next()) {
                    postPictureRecords.add(new PostPicture(rs.getInt(1)));
                }
            }
            else {
                Log.writeLog("ERROR: Post.java, dbGetActivePostPictureRecords(), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Post.java, dbGetActivePostPictureRecords(), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return postPictureRecords;
    }
    
    
    
    
    
    public Vector<String> getFavEmails() {
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        Vector<Person> list=new Vector<Person>();
        
        sqlText = "SELECT favorite_post.person_id FROM post, favorite_post WHERE post.post_id = ? AND post.post_id = favorite_post.post_id";
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, getPostId());
            rs = stmt.executeQuery();

            while(rs.next()) {
                list.add(new Person(rs.getInt("person_id")));
            }
        }
        catch (Exception e) { }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }
        return getEmails(list);
    }
    
    public Vector<String> getEmails(Vector<Person> plist) {
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        Vector<String> list=new Vector<String>();
        
        for(Person p: plist) {
        	sqlText = "SELECT email FROM person WHERE person_id = ?";
        	try {
        		conn = DBPool.getInstance().getConnection();
        		stmt = conn.prepareStatement(sqlText);
        		stmt.setInt(1, p.getPersonId());
        		rs = stmt.executeQuery();
        		
        		while(rs.next()) {
        			list.add(new String(rs.getString("email")));
        		}
        	}
            catch (Exception e) { }
            finally {
                try { stmt.close(); } catch (Exception e) { }
                DBPool.getInstance().returnConnection(conn);
            }
        }
        return list;
    }
}
