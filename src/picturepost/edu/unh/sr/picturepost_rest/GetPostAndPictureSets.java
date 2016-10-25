package edu.unh.sr.picturepost_rest;

import javax.servlet.*;
import javax.servlet.http.*;
import java.util.*;
import java.io.*;
import edu.unh.sr.picturepost.*;
import org.json.JSONArray;
import org.json.JSONObject;

public class GetPostAndPictureSets extends HttpServlet {

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
        Post post = null;
        int postId = 0;
        try {
            postId = Integer.parseInt(Utils.cleanup(request.getParameter("postId")));
            if (!Post.dbIsValidPostId(postId)) {
                error.add("Invalid postId");
            }
        }
        catch (Exception e) {
            error.add("Invalid postId, " + Utils.cleanup(request.getParameter("postId")));
        }

        // Any errors?
        if (!error.isEmpty()) {
            String buf = new JSONObject()
                .put("error", error)
                .toString();
            out.println(buf);
            return;
        }

        // Get the Post record.
        post = new Post(postId);
        
        if (post.getReady() == false) {
            error.add("not enabled");
            String buf = new JSONObject()
                .put("error", error)
                .toString();
            out.println(buf);
            return;
        }

        // Get a Vector of PostPicture records.
        //Vector<PostPicture> postPictureRecords = post.dbGetActivePostPictureRecords();

        // Get a Vector of PictureSetIds for this post.
        Vector<Integer> pictureSetIds = post.dbGetPictureSetIds();

        // Print out the results.
        JSONObject postJSON = new JSONObject()
            .put("postId", post.getPostId())
            .put("name", post.getName())
            .put("lat", post.getLat())
            .put("lon", post.getLon());
        JSONArray pictureSetsJSON = new JSONArray();

        for (int ps = 0; ps < pictureSetIds.size(); ++ps) {
            PictureSet pictureSet = new PictureSet(pictureSetIds.get(ps).intValue());
            
            // skip pictureset if not enabled
            if (pictureSet.getFlagged() == true || pictureSet.getReady() == false) {
            	continue;
            }
            
            Vector<Picture> pictureRecords = pictureSet.dbGetPictureRecords();
            
            int pictureId_N  = 0;
            int pictureId_NE = 0;
            int pictureId_E  = 0;
            int pictureId_SE = 0;
            int pictureId_S  = 0;
            int pictureId_SW = 0;
            int pictureId_W  = 0;
            int pictureId_NW = 0;
            int pictureId_UP = 0;
            if (PictureSet.pictureRecordExists(pictureRecords, "N")) {
                pictureId_N  = PictureSet.getPictureRecord(pictureRecords, "N").getPictureId();
            }
            if (PictureSet.pictureRecordExists(pictureRecords, "NE")) {
                pictureId_NE = PictureSet.getPictureRecord(pictureRecords, "NE").getPictureId();
            }
            if (PictureSet.pictureRecordExists(pictureRecords, "E")) {
                pictureId_E  = PictureSet.getPictureRecord(pictureRecords, "E").getPictureId();
            }
            if (PictureSet.pictureRecordExists(pictureRecords, "SE")) {
                pictureId_SE = PictureSet.getPictureRecord(pictureRecords, "SE").getPictureId();
            }
            if (PictureSet.pictureRecordExists(pictureRecords, "S")) {
                pictureId_S  = PictureSet.getPictureRecord(pictureRecords, "S").getPictureId();
            }
            if (PictureSet.pictureRecordExists(pictureRecords, "SW")) {
                pictureId_SW = PictureSet.getPictureRecord(pictureRecords, "SW").getPictureId();
            }
            if (PictureSet.pictureRecordExists(pictureRecords, "W")) {
                pictureId_W  = PictureSet.getPictureRecord(pictureRecords, "W").getPictureId();
            }
            if (PictureSet.pictureRecordExists(pictureRecords, "NW")) {
                pictureId_NW = PictureSet.getPictureRecord(pictureRecords, "NW").getPictureId();
            }
            if (PictureSet.pictureRecordExists(pictureRecords, "UP")) {
                pictureId_UP = PictureSet.getPictureRecord(pictureRecords, "UP").getPictureId();
            }
            
            JSONObject pictureSetJSON = new JSONObject()
                .put("pictureSetId", pictureSet.getPictureSetId())
                .put("pictureSetTimeStamp", String.valueOf(pictureSet.getPictureSetTimestamp()));
            JSONArray pictureIdJSON = new JSONArray()
                .put(pictureId_N)
                .put(pictureId_NE)
                .put(pictureId_E)
                .put(pictureId_SE)
                .put(pictureId_S)
                .put(pictureId_SW)
                .put(pictureId_W)
                .put(pictureId_NW)
                .put(pictureId_UP);
            pictureSetJSON.put("pictureIds", pictureIdJSON);
            pictureSetsJSON.put(pictureSetJSON);
        }
        postJSON.put("pictureSets", pictureSetsJSON);
        out.println(postJSON.toString());
    }
}
