package edu.unh.sr.picturepost_rest;

import javax.servlet.*;
import javax.servlet.http.*;
import java.util.*;
import java.io.*;
import edu.unh.sr.picturepost.*;

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
            out.println("{\"error\":[" + Utils.join_dq(error) + "]}");
            return;
        }

        // Get the Post record.
        post = new Post(postId);

        // Get a Vector of PostPicture records.
        Vector<PostPicture> postPictureRecords = post.dbGetActivePostPictureRecords();

        // Print out the results.
        out.println("[");
        out.println("{");
        out.println("\"postId\":" + String.valueOf(post.getPostId()) + ",");
        out.println("\"personId\":" + String.valueOf(post.getPersonId()) + ",");
        out.println("\"name\":\"" + post.getName().replaceAll("\"", java.util.regex.Matcher.quoteReplacement("\\\"")) + "\",");
        out.println("\"description\":\"" + post.getDescription().replaceAll("\"", java.util.regex.Matcher.quoteReplacement("\\\"")) + "\",");
        out.println("\"installDate\":\"" + post.getInstallDate() + "\",");
        out.println("\"referencePictureSetId\":" + String.valueOf(post.getReferencePictureSetId()) + ",");
        out.println("\"recordTimestamp\":\"" + post.getRecordTimestamp() + "\",");
        out.println("\"ready\":" + String.valueOf(post.getReady()) + ",");
        out.println("\"lat\":" + String.valueOf(post.getLat()) + ",");
        out.println("\"lon\":" + String.valueOf(post.getLon()) + ",");
        out.print("\"postPictureId\": [");
        if (!postPictureRecords.isEmpty()) {
            out.print(String.valueOf(postPictureRecords.get(0).getPostPictureId()));
            for (int i = 1; i < postPictureRecords.size(); i++) {
                out.print(", " + String.valueOf(postPictureRecords.get(i).getPostPictureId()));
            }
        }
        out.println("]");
        out.println("}");
        out.println("]");
    }
}
