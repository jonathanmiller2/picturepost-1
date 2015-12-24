package edu.unh.sr.picturepost_rest;

import javax.servlet.*;
import javax.servlet.http.*;
import java.util.*;
import java.io.*;
import edu.unh.sr.picturepost.*;

public class IsValidMobilePhone extends HttpServlet {

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
        //boolean isValidMobilePhone = false;
        String mobilePhone = Utils.cleanup(request.getParameter("mobilePhone"));

        // Check that what we got makes sense.
        if (mobilePhone.equals("")) {
            error.add("Missing mobilePhone value");
        }

        // Any errors?
        if (!error.isEmpty()) {
            out.println("{\"error\":[" + Utils.join_dq(error) + "]}");
            return;
        }

        String status_str = Person.dbIsValidMobilePhone(mobilePhone) ? "Valid" : "Invalid";
        
        // Print out the result.
        out.println("{");
        out.println("\"status\": \"" + status_str + "\"");
        out.println("}");
    }
}
