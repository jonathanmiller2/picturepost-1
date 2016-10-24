package edu.unh.sr.picturepost_rest;

import javax.servlet.*;
import javax.servlet.http.*;
import java.util.*;
import java.io.*;
import edu.unh.sr.picturepost.*;
import org.json.JSONArray;
import org.json.JSONObject;

public class GetPost extends HttpServlet {

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

        // Get a Vector of PostPicture records.
        Vector<PostPicture> postPictureRecords = post.dbGetActivePostPictureRecords();

        JSONArray result = new JSONArray();
        JSONObject postJSON = new JSONObject()
            .put("postId", post.getPostId())
            .put("personId", post.getPersonId())
            .put("name", post.getName())
            .put("description", post.getDescription())
            .put("installDate", post.getInstallDate())
            .put("referencePictureSetId", post.getReferencePictureSetId())
            .put("recordTimestamp", post.getRecordTimestamp())
            .put("ready", post.getReady())
            .put("lat", post.getLat())
            .put("lon", post.getLon());
        if (!postPictureRecords.isEmpty()) {
            JSONArray postPictureIds = new JSONArray();
            for (int i = 0; i < postPictureRecords.size(); ++i) {
                postPictureIds.put(postPictureRecords.get(i).getPostPictureId());
            }
            postJSON.put("postPictureId", postPictureIds);
        }
        result.put(postJSON);
        out.println(result.toString());
    }
}
