package edu.unh.sr.picturepost_rest;

import javax.servlet.*;
import javax.servlet.http.*;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.*;
import java.io.*;

import edu.unh.sr.picturepost.*;

public class AddPost extends HttpServlet {

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
		String mobilePhone = Utils.cleanup(request.getParameter("mobilePhone"));
		String name        = Utils.cleanup(request.getParameter("name"));
		String description = Utils.cleanup(request.getParameter("description"));
		String installDate = Utils.cleanup(request.getParameter("installDate"));
		double lat = 0.0;
		try {
			lat = Double.parseDouble(Utils.cleanup(request.getParameter("lat")));
		}
		catch (Exception e) {
			error.add("Missing or invalid parameter value: lat");
		}
		double lon = 0.0;
		try {
			lon = Double.parseDouble(Utils.cleanup(request.getParameter("lon")));
		}
		catch (Exception e) {
			error.add("Missing or invalid parameter value: lon");
		}

		// Check that what we got makes sense.
		if (mobilePhone.equals("")) {
			error.add("Missing parameter value: mobilePhone");
		}
		int personId = Person.dbGetPersonIdFromMobilePhone(mobilePhone);
		if (!Person.dbIsValidPersonId(personId)) {
			error.add("Invalid mobilePhone value: " + mobilePhone);
		}
		if (name.equals("")) {
			error.add("Missing parameter value: name");
		}
		if (description.equals("")) {
			error.add("Missing parameter value: description");
		}
		if (!installDate.matches("\\d{4}-\\d{2}-\\d{2}")) {
			error.add("Missing or invalid parameter value: installDate");
		}
		if (lat < -90.0 || lat > 90.0) {
			error.add("Lat value out of range: " + String.valueOf(lat));
		}
		if (lon < -180.0 || lon > 180.0) {
			error.add("Lon value out of range: " + String.valueOf(lon));
		}

		// Any errors?
		if (!error.isEmpty()) {
            String buf = new JSONObject()
                .put("error", error).
                toString();
			out.println(buf);
			return;
		}

		// Try to insert the Post.
		Post post = new Post();
		post.dbSetPostId();
		post.setPersonId(personId);
		post.setName(name);
		post.setDescription(description);
		post.setInstallDate(java.sql.Date.valueOf(installDate));
		post.setReferencePictureSetId(0);
		post.setRecordTimestamp(Utils.getCurrentTimestamp());
		post.setReady(true);
		post.setLat(lat);
		post.setLon(lon);
		if (!post.dbInsert()) {
			error.add("Error inserting post");
		}

		// Any errors?
		if (!error.isEmpty()) {
			String buf = new JSONObject()
			    .put("error", new JSONArray(error))
			    .toString();
			out.println(buf);
			return;
		}
		String buf = new JSONObject()
		    .put("postId", post.getPostId())
		    .toString();
		out.println(buf);
	}
}
