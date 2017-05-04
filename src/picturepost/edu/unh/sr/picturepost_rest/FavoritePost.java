package edu.unh.sr.picturepost_rest;

import javax.servlet.*;
import javax.servlet.http.*;

import org.json.JSONObject;

import java.util.*;
import java.io.*;

import edu.unh.sr.picturepost.*;

public class FavoritePost extends HttpServlet {

    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

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
        String mobilePhone = Utils.cleanup(request.getParameter("mobilePhone"));

        String status = Utils.cleanup(request.getParameter("status"));


        // Check that what we got makes sense.
        if (!Post.dbIsValidPostId(postId)) {
            error.add("Invalid postId");
        }
        if (!Person.dbIsValidMobilePhone(mobilePhone)) {
            error.add("Invalid mobilePhone value");
        }
        if (!("1".equals(status) || "0".equals(status))) {
        	error.add("Invalid status value");
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
        Person person = new Person(Person.dbGetPersonIdFromMobilePhone(mobilePhone));
        
        edu.unh.sr.picturepost.FavoritePost fp = new edu.unh.sr.picturepost.FavoritePost(person.getPersonId(), post.getPostId());
        
        if ("1".equals(status)) {
        	fp.dbInsert();
        } else {
        	fp.dbDelete();
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
