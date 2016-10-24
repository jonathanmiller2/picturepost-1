package edu.unh.sr.picturepost_rest;

import javax.servlet.*;
import javax.servlet.http.*;
import java.util.*;
import java.sql.*;
import java.io.*;
import edu.unh.sr.picturepost.*;
import org.json.JSONArray;
import org.json.JSONObject;

public class GetPostList extends HttpServlet {

    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // Get something to write with.
        PrintWriter out = response.getWriter();

        // Prevent the browser from caching this page.
        response.addHeader("Cache-control", "no-store");

        // Set the content type.
        response.setContentType("application/json");

        // Handle errors.
        Vector<String> error = new Vector<String>();

        // Some parameters.
        Vector<Post> postRecords = new Vector<Post>();
        boolean haveLat          = false;
        boolean haveLon          = false;
        boolean haveRadius       = false;
        boolean haveAfterTime    = false;
        boolean haveBeforeTime   = false;
        //boolean haveOrderBy      = false;
        //boolean haveIncludePosts = false;
        boolean haveMobilePhone  = false;
        double lat = 0.0;
        double lon = 0.0;
        int radius = 0;
        java.sql.Timestamp afterTime = null;
        java.sql.Timestamp beforeTime = null;
        String orderBy = "name"; 
        String includePosts = "all";
        String mobilePhone = "";
        int personId = 0;
        Person person = null;

        if (!Utils.cleanup(request.getParameter("lat")).equals("")) {
            try {
                lat = Double.parseDouble(Utils.cleanup(request.getParameter("lat")));
                if (lat < -90.0 || lat > 90.0) {
                    throw new Exception();
                }
                haveLat = true;
            }
            catch (Exception e) {
                error.add("Invalid lat, " + Utils.cleanup(request.getParameter("lat")));
            }
        }
        if (!Utils.cleanup(request.getParameter("lon")).equals("")) {
            try {
                lon = Double.parseDouble(Utils.cleanup(request.getParameter("lon")));
                if (lon < -180.0 || lon > 180.0) {
                    throw new Exception();
                }
                haveLon = true;
            }
            catch (Exception e) {
                error.add("Invalid lon, " + Utils.cleanup(request.getParameter("lon")));
            }
        }
        if (!Utils.cleanup(request.getParameter("radius")).equals("")) {
            try {
                radius = Integer.parseInt(Utils.cleanup(request.getParameter("radius")));
                if (radius <= 0) {
                    throw new Exception();
                }
                haveRadius = true;
            }
            catch (Exception e) {
                error.add("Invalid radius, " + Utils.cleanup(request.getParameter("radius")));
            }
        }
        if (!Utils.cleanup(request.getParameter("afterTime")).equals("")) {
            try {
                afterTime = new java.sql.Timestamp(Long.parseLong(Utils.cleanup(request.getParameter("afterTime"))));
                haveAfterTime = true;
            }
            catch (Exception e) {
                error.add("Invalid afterTime, " + Utils.cleanup(request.getParameter("afterTime")));
            }
        }
        if (!Utils.cleanup(request.getParameter("beforeTime")).equals("")) {
            try {
                beforeTime = new java.sql.Timestamp(Long.parseLong(Utils.cleanup(request.getParameter("beforeTime"))));
                haveBeforeTime = true;
            }
            catch (Exception e) {
                error.add("Invalid beforeTime, " + Utils.cleanup(request.getParameter("beforeTime")));
            }
        }
        if (!Utils.cleanup(request.getParameter("orderBy")).equals("")) {
            orderBy = Utils.cleanup(request.getParameter("orderBy"));
            if (!orderBy.equals("radius") && !orderBy.equals("radius desc") && !orderBy.equals("install_date") && !orderBy.equals("install_date desc") && !orderBy.equals("name") && !orderBy.equals("name desc")) {
                error.add("Invalid orderBy, " + orderBy);
            }
            else {
                //haveOrderBy = true;
            }
        }
        if (!Utils.cleanup(request.getParameter("includePosts")).equals("")) {
            includePosts = Utils.cleanup(request.getParameter("includePosts"));
            if (!includePosts.equals("all") && !includePosts.equals("mine") && !includePosts.equals("favorites")) {
                error.add("Invalid includePosts, " + includePosts);
            }
            else {
            	// TODO commented out by phil
                //haveIncludePosts = true;
            }
        }
        if (!Utils.cleanup(request.getParameter("mobilePhone")).equals("")) {
            mobilePhone = Utils.cleanup(request.getParameter("mobilePhone"));
            if (!Person.dbIsValidMobilePhone(mobilePhone)) {
                error.add("Invalid mobilePhone number, " + mobilePhone);
            }
            else { 
                personId = Person.dbGetPersonIdFromMobilePhone(mobilePhone);
                person = new Person(personId);
                haveMobilePhone = true;
            }
        }

        // Check that what we got makes sense.
        if (orderBy.equals("radius") && (!haveLat || !haveLon)) {
            error.add("lat and lon are required when orderBy = radius.");
        }

        // Any errors?
        if (!error.isEmpty()) {
            String buf = new JSONObject()
                .put("error", error)
                .toString();
            out.println(buf);
            return;
        }

        // Get a Vector of Post records.
        if (haveLat && haveLon && haveRadius && (haveAfterTime || haveBeforeTime)) {
            if (includePosts.equals("all")) {
                postRecords = Post.dbGetPostRecords(lat, lon, radius, afterTime, beforeTime, orderBy);
            }
            else if (haveMobilePhone && includePosts.equals("mine")) {
                postRecords = Post.dbGetPostRecords(personId, lat, lon, radius, afterTime, beforeTime, orderBy);
            }
            else if (haveMobilePhone && includePosts.equals("favorites")) {
                postRecords = person.dbGetFavoritePostRecords(lat, lon, radius, afterTime, beforeTime, orderBy);
            }
        }
        else if (haveLat && haveLon && (haveAfterTime || haveBeforeTime)) {
            if (includePosts.equals("all")) {
                postRecords = Post.dbGetPostRecords(lat, lon, afterTime, beforeTime, orderBy);
            }
            else if (haveMobilePhone && includePosts.equals("mine")) {
                postRecords = Post.dbGetPostRecords(personId, lat, lon, afterTime, beforeTime, orderBy);
            }
            else if (haveMobilePhone && includePosts.equals("favorites")) {
                postRecords = person.dbGetFavoritePostRecords(lat, lon, afterTime, beforeTime, orderBy);
            }
        }
        else if (haveLat && haveLon && haveRadius) {
            if (includePosts.equals("all")) {
                postRecords = Post.dbGetPostRecords(lat, lon, radius, orderBy);
            }
            else if (haveMobilePhone && includePosts.equals("mine")) {
                postRecords = Post.dbGetPostRecords(personId, lat, lon, radius, orderBy);
            }
            else if (haveMobilePhone && includePosts.equals("favorites")) {
                postRecords = person.dbGetFavoritePostRecords(lat, lon, radius, orderBy);
            }
        }
        else if (haveLat && haveLon) {
            if (includePosts.equals("all")) {
                postRecords = Post.dbGetPostRecords(lat, lon, orderBy);
            }
            else if (haveMobilePhone && includePosts.equals("mine")) {
                postRecords = Post.dbGetPostRecords(personId, lat, lon, orderBy);
            }
            else if (haveMobilePhone && includePosts.equals("favorites")) {
                postRecords = person.dbGetFavoritePostRecords(lat, lon, orderBy);
            }
        }
        else if (haveAfterTime || haveBeforeTime) {
            if (includePosts.equals("all")) {
                postRecords = Post.dbGetPostRecords(afterTime, beforeTime, orderBy);
            }
            else if (haveMobilePhone && includePosts.equals("mine")) {
                postRecords = Post.dbGetPostRecords(personId, afterTime, beforeTime, orderBy);
            }
            else if (haveMobilePhone && includePosts.equals("favorites")) {
                postRecords = person.dbGetFavoritePostRecords(afterTime, beforeTime, orderBy);
            }
        }
        else {
            if (includePosts.equals("all")) {
                postRecords = Post.dbGetPostRecords(orderBy);
            }
            else if (haveMobilePhone && includePosts.equals("mine")) {
                postRecords = Post.dbGetPostRecords(personId, orderBy);
            }
            else if (haveMobilePhone && includePosts.equals("favorites")) {
                postRecords = person.dbGetFavoritePostRecords(orderBy);
            }
        }

        // Print out the results.
        JSONArray results = new JSONArray();
        for (int i = 0; i < postRecords.size(); ++i) {
            int postId = postRecords.get(i).getPostId();

            String sqlText = "";
            Connection conn = null;
            PreparedStatement stmt = null;
            ResultSet rs = null;
            int postPictureId = -1;

            sqlText = "SELECT post_picture_id FROM post_picture WHERE post_id = ?";
  
            try {
              conn = DBPool.getInstance().getConnection();
              stmt = conn.prepareStatement(sqlText);
              stmt.setInt(1, postId);
              rs = stmt.executeQuery();
              while (rs != null && rs.next()) {
                  postPictureId = rs.getInt("post_picture_id");
                  // Log.writeLog("DEBUG: a post picture id: " + postPictureId);
              }
            } catch (Exception e) {
              Log.writeLog("ERROR: GetPost.java, doGet(...), sqlText = " + sqlText + ", " + e.toString());
            } finally {
              try { stmt.close(); } catch (Exception e) { }
              DBPool.getInstance().returnConnection(conn);
            }

            JSONObject postJSON = new JSONObject()
                .put("postId", postRecords.get(i).getPostId())
                .put("personId", postRecords.get(i).getPersonId())
                .put("name", postRecords.get(i).getName())
                .put("description", postRecords.get(i).getDescription())
                .put("installDate", postRecords.get(i).getInstallDate())
                .put("referencePictureSetId", postRecords.get(i).getReferencePictureSetId())
                .put("recordTimestamp", postRecords.get(i).getRecordTimestamp())
                .put("ready", postRecords.get(i).getReady())
                .put("lat", postRecords.get(i).getLat())
                .put("lon", postRecords.get(i).getLon())
                .put("postPictureId", postPictureId);
            results.put(postJSON);
        }
        out.println(results.toString());
    }
}
