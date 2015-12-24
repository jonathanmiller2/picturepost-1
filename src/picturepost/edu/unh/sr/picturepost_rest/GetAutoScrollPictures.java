package edu.unh.sr.picturepost_rest;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import edu.unh.sr.picturepost.*;

public class GetAutoScrollPictures extends HttpServlet {

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
        response.setContentType("text/xml");

        // Print the XML header.
        out.println("<?xml version=\"1.0\" encoding=\"utf-8\"?>");

        // Print the root element.
        out.println("<autoScrollPictures>");

        // Gather info.
        String orientation = Utils.cleanup(request.getParameter("orientation"));
        String pictureSetIdString = Utils.cleanup(request.getParameter("pictureSetIdString"));
        String pictureSetIdStrings[] = pictureSetIdString.split(",");
        for (int i = 0; i < pictureSetIdStrings.length; i++) {
            try {
                PictureSet pictureSet = new PictureSet(Integer.parseInt(pictureSetIdStrings[i]));
                if (PictureSet.pictureRecordExists(pictureSet, orientation)) {
                    Picture picture = PictureSet.getPictureRecord(pictureSet, orientation);
                    out.println("<picture>");
                    out.println("<pictureId>" + String.valueOf(picture.getPictureId()) + "</pictureId>");
                    out.println("<imageFileMedium>" + picture.getImageFileMedium() + "</imageFileMedium>");
                    out.println("<pictureSetTimestamp>" + pictureSet.getPictureSetTimestamp().toString().substring(0, 16) + "</pictureSetTimestamp>");
                    out.println("</picture>");
                }
            }
            catch (Exception e) { }
        }

        // Print the closing root element.
        out.println("</autoScrollPictures>");
    }
}
