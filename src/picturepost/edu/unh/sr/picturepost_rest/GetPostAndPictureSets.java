package edu.unh.sr.picturepost_rest;

import javax.servlet.*;
import javax.servlet.http.*;
import java.util.*;
import java.io.*;
import edu.unh.sr.picturepost.*;

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
            out.println("{\"error\": [" + Utils.join_dq(error) + "]}");
            return;
        }

        // Get the Post record.
        post = new Post(postId);
        
        if (post.getReady() == false) {
            out.println("{\"error\":[\"not enabled\"]}");
            return;
        }

        // Get a Vector of PostPicture records.
        //Vector<PostPicture> postPictureRecords = post.dbGetActivePostPictureRecords();

        // Get a Vector of PictureSetIds for this post.
        Vector<Integer> pictureSetIds = post.dbGetPictureSetIds();

        // Print out the results.
        out.println("{");
        out.println("    \"postId\": " + String.valueOf(post.getPostId()) + ",");
        out.println("    \"name\": \"" + post.getName().replaceAll("\"", java.util.regex.Matcher.quoteReplacement("\\\"")) + "\",");
        out.println("    \"lat\": " + String.valueOf(post.getLat()) + ",");
        out.println("    \"lon\": " + String.valueOf(post.getLon()) + ",");
        out.println("    \"pictureSets\": [");
        for (int ps = 0; ps < pictureSetIds.size(); ps++) {
            PictureSet pictureSet = new PictureSet(pictureSetIds.get(ps).intValue());
            
            // skip pictureset if not enabled
            if (pictureSet.getFlagged() == true || pictureSet.getReady() == false) {
            	continue;
            }
            
            Vector<Picture> pictureRecords = pictureSet.dbGetPictureRecords();
            
            String pictureId_N  = "0";
            String pictureId_NE = "0";
            String pictureId_E  = "0";
            String pictureId_SE = "0";
            String pictureId_S  = "0";
            String pictureId_SW = "0";
            String pictureId_W  = "0";
            String pictureId_NW = "0";
            String pictureId_UP = "0";
            if (PictureSet.pictureRecordExists(pictureRecords, "N")) {
                pictureId_N  = String.valueOf(PictureSet.getPictureRecord(pictureRecords, "N").getPictureId());
            }
            if (PictureSet.pictureRecordExists(pictureRecords, "NE")) {
                pictureId_NE = String.valueOf(PictureSet.getPictureRecord(pictureRecords, "NE").getPictureId());
            }
            if (PictureSet.pictureRecordExists(pictureRecords, "E")) {
                pictureId_E  = String.valueOf(PictureSet.getPictureRecord(pictureRecords, "E").getPictureId());
            }
            if (PictureSet.pictureRecordExists(pictureRecords, "SE")) {
                pictureId_SE = String.valueOf(PictureSet.getPictureRecord(pictureRecords, "SE").getPictureId());
            }
            if (PictureSet.pictureRecordExists(pictureRecords, "S")) {
                pictureId_S  = String.valueOf(PictureSet.getPictureRecord(pictureRecords, "S").getPictureId());
            }
            if (PictureSet.pictureRecordExists(pictureRecords, "SW")) {
                pictureId_SW = String.valueOf(PictureSet.getPictureRecord(pictureRecords, "SW").getPictureId());
            }
            if (PictureSet.pictureRecordExists(pictureRecords, "W")) {
                pictureId_W  = String.valueOf(PictureSet.getPictureRecord(pictureRecords, "W").getPictureId());
            }
            if (PictureSet.pictureRecordExists(pictureRecords, "NW")) {
                pictureId_NW = String.valueOf(PictureSet.getPictureRecord(pictureRecords, "NW").getPictureId());
            }
            if (PictureSet.pictureRecordExists(pictureRecords, "UP")) {
                pictureId_UP = String.valueOf(PictureSet.getPictureRecord(pictureRecords, "UP").getPictureId());
            }

            out.println("        {");
            out.println("            \"pictureSetId\": " + String.valueOf(pictureSet.getPictureSetId()) + ",");
            out.println("            \"pictureSetTimeStamp\": \"" + String.valueOf(pictureSet.getPictureSetTimestamp()) + "\",");
            out.println("            \"pictureIds\": [" + pictureId_N + ", " + pictureId_NE + ", " + pictureId_E + ", " + pictureId_SE + ", " + pictureId_S + ", " + pictureId_SW + ", " + pictureId_W + ", " + pictureId_NW + ", " + pictureId_UP + "]");
            if (ps == pictureSetIds.size() - 1) {
                out.println("        }");
            }
            else {
                out.println("        },");
            }
        }
        out.println("    ]");
        out.println("}");
    }
}
