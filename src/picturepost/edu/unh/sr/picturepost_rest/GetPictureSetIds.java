package edu.unh.sr.picturepost_rest;

import javax.servlet.*;
import javax.servlet.http.*;
import java.util.*;
import java.io.*;
import edu.unh.sr.picturepost.*;

public class GetPictureSetIds extends HttpServlet {

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
            if (!Post.dbIsValidPostId(postId)) {
                error.add("Invalid postId");
            }
        }
        catch (Exception e) {
            error.add("Invalid postId, " + Utils.cleanup(request.getParameter("postId")));
        }
        String orderBy = Utils.cleanup(request.getParameter("orderBy"));
        if (!orderBy.equals("picture_set_timestamp desc") &&
            !orderBy.equals("picture_set_timestamp")  &&
            !orderBy.equals("record_timestamp desc")      &&
            !orderBy.equals("record_timestamp")) {

            orderBy = "picture_set_timestamp desc";
        }

        // Any errors?
        if (!error.isEmpty()) {
            out.println("{\"error\":[" + Utils.join_dq(error) + "]}");
            return;
        }

        // Get the PictureSetIds.
        Post post = new Post(postId);
        Vector<Integer> pictureSetIds = post.dbGetViewablePictureSetIds(orderBy);

        // Print out the results.
        out.println("{ \"pictureSetIds\":");
        out.println("[");
        if (pictureSetIds.size() > 0) {
            out.println(pictureSetIds.get(0).toString());
            for (int i = 1; i < pictureSetIds.size(); i++) {
                out.println("," + pictureSetIds.get(i).toString());
            }
        }
        out.println("]");
        out.println("}");
    }
}
