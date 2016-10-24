package edu.unh.sr.picturepost_rest;

import javax.servlet.*;
import javax.servlet.http.*;
import java.util.*;
import java.io.*;
import edu.unh.sr.picturepost.*;
import org.json.JSONArray;
import org.json.JSONObject;

public class GetPictureSet extends HttpServlet {

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
        int pictureSetId = 0;
        PictureSet pictureSet = null;
        try {
            pictureSetId = Integer.parseInt(Utils.cleanup(request.getParameter("pictureSetId")));
            if (!PictureSet.dbIsValidPictureSetId(pictureSetId)) {
                error.add("\"Invalid pictureSetId\"");
            }
        }
        catch (Exception e) {
            error.add("\"Invalid pictureSetId, " + Utils.cleanup(request.getParameter("pictureSetId")) + "\"");
        }

        // Any errors?
        if (!error.isEmpty()) {
            String buf = new JSONObject()
                .put("error", error)
                .toString();
            out.println(buf);
            return;
        }

        // Get the PictureSet record.
        pictureSet = new PictureSet(pictureSetId);
        
        if (pictureSet.getFlagged() == true || pictureSet.getReady() == false) {
            error.add("\"not enabled\"");
            String buf = new JSONObject()
                .put("error", error)
                .toString();
            out.println(buf);
            return;
        }
        
        Vector<Picture> pictureRecords = pictureSet.dbGetPictureRecords();
        Vector<String> orientations = new Vector<String>();
        if (PictureSet.pictureRecordExists(pictureRecords, "N"))  orientations.add("\"N\"");
        if (PictureSet.pictureRecordExists(pictureRecords, "NE")) orientations.add("\"NE\"");
        if (PictureSet.pictureRecordExists(pictureRecords, "E"))  orientations.add("\"E\"");
        if (PictureSet.pictureRecordExists(pictureRecords, "SE")) orientations.add("\"SE\"");
        if (PictureSet.pictureRecordExists(pictureRecords, "S"))  orientations.add("\"S\"");
        if (PictureSet.pictureRecordExists(pictureRecords, "SW")) orientations.add("\"SW\"");
        if (PictureSet.pictureRecordExists(pictureRecords, "W"))  orientations.add("\"W\"");
        if (PictureSet.pictureRecordExists(pictureRecords, "NW")) orientations.add("\"NW\"");
        if (PictureSet.pictureRecordExists(pictureRecords, "UP")) orientations.add("\"UP\"");

        // Print out the results.
        JSONArray result = new JSONArray();
        JSONObject pictureSetJSON = new JSONObject()
            .put("pictureSetId", pictureSet.getPictureSetId())
            .put("postId", pictureSet.getPostId())
            .put("personId", pictureSet.getPersonId())
            .put("recordTimestamp", pictureSet.getRecordTimestamp())
            .put("pictureSetTimestamp", pictureSet.getPictureSetTimestamp())
            .put("ready", pictureSet.getReady())
            .put("flagged", pictureSet.getFlagged())
            .put("annotation", pictureSet.getAnnotation())
            .put("orientations", orientations);
        result.put(pictureSetJSON);
        out.println(result.toString());
    }
}
