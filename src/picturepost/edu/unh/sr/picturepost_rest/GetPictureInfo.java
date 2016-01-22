package edu.unh.sr.picturepost_rest;

import javax.servlet.*;
import javax.servlet.http.*;
import java.util.*;
import java.io.*;
import edu.unh.sr.picturepost.*;

public class GetPictureInfo extends HttpServlet {

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
        out.println("<picture>");

        // Gather info.
        int pictureId = 0;
        try {
            pictureId = Integer.parseInt(Utils.cleanup(request.getParameter("pictureId")));
        }
        catch (Exception e) {
            out.println("</picture>");
            return;
        }
        if (!Picture.dbIsValidPictureId(pictureId)) {
            out.println("</picture>");
            return;
        }
        String nav = Utils.cleanup(request.getParameter("nav"));
        if (nav.equals("previousPictureSet") || nav.equals("nextPictureSet")) {
            int numPerPage = -1;
            try {
                numPerPage = Integer.parseInt(Utils.cleanup(request.getParameter("numPerPage")));
            }
            catch (Exception e) {
                Log.writeLog("ERROR, GetPictureInfo.java: Invalid numPerPage: " + numPerPage);
                out.println("</picture>");
                return;
            }
            if (numPerPage < 0) {
                Log.writeLog("ERROR, GetPictureInfo.java: Invalid numPerPage: " + numPerPage);
                out.println("</picture>");
                return;
            }

            int curPage = -1;
            try {
                curPage = Integer.parseInt(Utils.cleanup(request.getParameter("curPage")));
            }
            catch (Exception e) {
                Log.writeLog("ERROR, GetPictureInfo.java: Invalid curPage: " + curPage);
                out.println("</picture>");
                return;
            }
            if (curPage < 0) {
                Log.writeLog("ERROR, GetPictureInfo.java: Invalid curPage: " + curPage);
                out.println("</picture>");
                return;
            }

            if (nav.equals("previousPictureSet")) {
                pictureId = Picture.getPictureIdPreviousPictureSet(pictureId, numPerPage, curPage);
            }
            else if (nav.equals("nextPictureSet")) {
                pictureId = Picture.getPictureIdNextPictureSet(pictureId, numPerPage, curPage);
            }
        }
        else if (nav.equals("previousOrientation")) {
            pictureId = Picture.getPictureIdPreviousOrientation(pictureId);
        }
        else if (nav.equals("nextOrientation")) {
            pictureId = Picture.getPictureIdNextOrientation(pictureId);
        }
        Picture picture = new Picture(pictureId);
        PictureSet pictureSet = new PictureSet(picture.getPictureSetId());
        Vector<PictureComment> pictureCommentRecords = picture.dbGetPictureCommentRecords();
        Vector<PictureMD> pictureMDRecords = picture.dbGetPictureMDRecords();

        // The pictureId.
        out.println("<pictureId>" + pictureId + "</pictureId>");

        // Name of picture (imageFile).
        out.println("<imageFile>" + picture.getImageFile() + "</imageFile>");

        // Name of medium picture (imageFileMedium).
        out.println("<imageFileMedium>" + picture.getImageFileMedium() + "</imageFileMedium>");

        // pictureSetAnnotation.
        out.println("<pictureSetAnnotation>" + Utils.htmlEscape(pictureSet.getAnnotation()) + "</pictureSetAnnotation>");

        // pictureSetTimeStamp.
        out.println("<pictureSetTimestamp>" + pictureSet.getPictureSetTimestamp().toString().substring(0, 16) + "</pictureSetTimestamp>");

        // pictureOrientation.
        out.println("<pictureOrientation>" + picture.getOrientation() + "</pictureOrientation>");

        // Picture comments.
        out.println("<comments>");
        for (int i = 0; i < pictureCommentRecords.size(); i++) {
            Person person = new Person(pictureCommentRecords.get(i).getPersonId());
            out.println("<comment>");
            out.println("<firstName>" + Utils.htmlEscape(person.getFirstName()) + "</firstName>");
            out.println("<lastName>" + Utils.htmlEscape(person.getLastName()) + "</lastName>");
            out.println("<timeInterval>" + Utils.timeInterval(pictureCommentRecords.get(i).getCommentTimestamp()) + "</timeInterval>");
            out.println("<commentText>" + Utils.htmlEscape(pictureCommentRecords.get(i).getCommentText()) + "</commentText>");
            out.println("</comment>");
        }
        out.println("</comments>");
        
        // Picture metadata.
        out.println("<metadata>");
        for (int i = 0; i < pictureMDRecords.size(); i++) {
            out.println("<tag>");
            out.println("<directory>" + Utils.htmlEscape(pictureMDRecords.get(i).getDirectory()) + "</directory>");
            out.println("<tagId>0x" + Integer.toHexString(pictureMDRecords.get(i).getTagId()) + "</tagId>");
            out.println("<tagName>" + Utils.htmlEscape(pictureMDRecords.get(i).getTagName()) + "</tagName>");
            out.println("<tagValue>" + Utils.htmlEscape(pictureMDRecords.get(i).getTagValue()) + "</tagValue>");
            out.println("</tag>");
        }
        out.println("</metadata>");

        // Satellite.
        // Make sure the layer exists before sending it back.
        // Note this is now handled externally - show dummy value instead
        out.println("<satellite>");
        out.println("<layerNamePrefix>undefined</layerNamePrefix>");
        out.println("</satellite>");

        // Print the closing root element.
        out.println("</picture>");
    }
}
