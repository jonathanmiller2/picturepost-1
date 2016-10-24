package edu.unh.sr.picturepost_rest;

import javax.servlet.*;
import javax.servlet.http.*;

import org.json.JSONObject;

import java.util.*;
import java.io.*;

import edu.unh.sr.picturepost.*;

public class SetReferencePictureSetId extends HttpServlet {

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
        catch (Exception e) { }
        int pictureSetId = 0;
        try {
            pictureSetId = Integer.parseInt(Utils.cleanup(request.getParameter("pictureSetId")));
        }
        catch (Exception e) { }
        String mobilePhone = Utils.cleanup(request.getParameter("mobilePhone"));

        // Check that what we got makes sense.
        if (!Post.dbIsValidPostId(postId)) {
            error.add("Invalid postId");
        }
        if (!PictureSet.dbIsValidPictureSetId(pictureSetId)) {
            error.add("Invalid pictureSetId");
        }
        if (!Person.dbIsValidMobilePhone(mobilePhone)) {
            error.add("Invalid mobilePhone value");
        }

        // Any errors?
        if (!error.isEmpty()) {
            String buf = new JSONObject()
                .put("error", error)
                .toString();
            out.println(buf);
            return;
        }

        // Check that the post, pictureSet, and person all make sense.
        Post post = new Post(postId);
        PictureSet pictureSet = new PictureSet(pictureSetId);
        Person person = new Person(Person.dbGetPersonIdFromMobilePhone(mobilePhone));
        if (post.getPersonId() != person.getPersonId()) {
            error.add("Post is not owned by this person");
        }
        if (post.getPostId() != pictureSet.getPostId()) {
            error.add("PictureSet does not belong to this post");
        }

        // Any errors?
        if (!error.isEmpty()) {
            String buf = new JSONObject()
                .put("error", error)
                .toString();
            out.println(buf);
            return;
        }

        // OK, set the referencPictureSetId.
        post.setReferencePictureSetId(pictureSetId);
        if (!post.dbUpdate()) {
            error.add("Error updating the database");
        }

        // Any errors?
        if (!error.isEmpty()) {
            String buf = new JSONObject()
                .put("error", error)
                .toString();
            out.println(buf);
            return;
        }

        // Print out the result.
        String buf = new JSONObject()
            .put("status", "OK")
            .toString();
        out.println(buf);
    }
}
