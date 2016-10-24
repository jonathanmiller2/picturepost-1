package edu.unh.sr.picturepost_rest;

import javax.servlet.*;
import javax.servlet.http.*;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.*;
import java.io.*;

import edu.unh.sr.picturepost.*;

public class AddPictureSet extends HttpServlet {

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
		int postId = 0;
		try {
			postId = Integer.parseInt(Utils.cleanup(request.getParameter("postId")));
		}
		catch (Exception e) {
			error.add("Missing or invalid parameter value: postId");
		}
		String mobilePhone         = Utils.cleanup(request.getParameter("mobilePhone"));
		String pictureSetTimestamp = Utils.cleanup(request.getParameter("pictureSetTimestamp"));
		String annotation          = Utils.cleanup(request.getParameter("annotation"));

		// Check that what we got makes sense.
		if (!Post.dbIsValidPostId(postId)) {
			error.add("Invalid postId: " + String.valueOf(postId));
		}
		if (mobilePhone.equals("")) {
			error.add("Missing parameter value: mobilePhone");
		}
		int personId = Person.dbGetPersonIdFromMobilePhone(mobilePhone);
		if (!mobilePhone.equals("") && !Person.dbIsValidPersonId(personId)) {
			error.add("Invalid mobilePhone value: " + mobilePhone);
		}
		if (!pictureSetTimestamp.matches("\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}\\.\\d+")) {
			error.add("Missing or invalid parameter value: pictureSetTimestamp");
		}

		// Any errors?
		if (!error.isEmpty()) {
            String buf = new JSONObject()
                .put("error", error)
                .toString();
            out.println(buf);
			return;
		}

		// Try to insert the PictureSet.
		PictureSet pictureSet = new PictureSet();
		if (!pictureSet.dbSetPictureSetId()) {
			error.add("Error creating PictureSetId");
		}
		if (error.isEmpty()) {
			pictureSet.setPostId(postId);
			pictureSet.setPersonId(personId);
			pictureSet.setRecordTimestamp(Utils.getCurrentTimestamp());
			pictureSet.setPictureSetTimestamp(java.sql.Timestamp.valueOf(pictureSetTimestamp));
			pictureSet.setReady(true);
			pictureSet.setFlagged(false);
			pictureSet.setAnnotation(annotation);
			if (!pictureSet.dbInsert()) {
				error.add("Error inserting pictureSet");
			}
		}

		// Any errors?
		if (!error.isEmpty()) {
			String buf = new JSONObject()
			    .put("error", new JSONArray(error))
			    .toString();
			out.println(buf); 
			return;
		}

		// Print out the result.
		String buf = new JSONObject()
		    .put("pictureSetId", pictureSet.getPictureSetId())
		    .toString();
		out.println(buf);
	}  
}
