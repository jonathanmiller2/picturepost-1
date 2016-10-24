package edu.unh.sr.picturepost_rest;

import javax.servlet.*;
import javax.servlet.http.*;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.*;
import java.io.*;

import edu.unh.sr.picturepost.*;

public class FlagPictureSet extends HttpServlet {

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
		PictureSet pictureSet = null;
		try {
			int pictureSetId = Integer.parseInt(Utils.cleanup(request.getParameter("pictureSetId")));
			pictureSet = new PictureSet(pictureSetId);
			if (pictureSet.getFlagged() == false) {
				pictureSet.setFlagged(true);
				pictureSet.dbUpdate();
			}
		}
		catch (Exception e) {
			error.add("\"Invalid pictureSetId, " + Utils.cleanup(request.getParameter("pictureSetId")) + "\"");
		}

		if (!error.isEmpty()) {
			String buf = new JSONObject()
			    .put("error", new JSONArray(error))
			    .toString();
			out.println(buf); 
			return;
		}

		else {            
			String buf = new JSONObject()
			    .put("pictureSetId", pictureSet.getPictureSetId())
			    .put("reported", true)
			    .toString();
			out.println(buf); 
		}
	}  
}
