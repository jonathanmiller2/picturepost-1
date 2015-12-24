package edu.unh.sr.picturepost_rest;

import javax.servlet.*;
import javax.servlet.http.*;
import java.util.*;
import java.io.*;
import edu.unh.sr.picturepost.*;

public class GetPicture extends HttpServlet {

    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // Prevent the browser from caching this page.
        response.addHeader("Cache-control", "no-store");

        // Set the content type.
        response.setContentType("image/jpeg");

        // Handle errors.
        Vector<String> error = new Vector<String>();

        // Some parameters.
        Picture    picture    = null;
        PictureSet pictureSet = null;
        Post       post       = null;
        boolean havePictureId    = false;
        boolean havePictureSetId = false;
        boolean haveOrientation  = false;
        int pictureId = 0;
        int pictureSetId = 0;
        String orientation = "";
        String size = "full";

        if (!Utils.cleanup(request.getParameter("pictureId")).equals("")) {
            try {
                pictureId = Integer.parseInt(Utils.cleanup(request.getParameter("pictureId")));
                if (!Picture.dbIsValidPictureId(pictureId)) {
                    error.add("Invalid pictureId");
                }
                else {
                    havePictureId = true;
                }
            }
            catch (Exception e) {
                error.add("Invalid pictureId, " + Utils.cleanup(request.getParameter("pictureId")));
            }
        }
        if (!Utils.cleanup(request.getParameter("pictureSetId")).equals("")) {
            try {
                pictureSetId = Integer.parseInt(Utils.cleanup(request.getParameter("pictureSetId")));
                if (!PictureSet.dbIsValidPictureSetId(pictureSetId)) {
                    error.add("Invalid pictureSetId");
                }
                else {
                    havePictureSetId = true;
                }
            }
            catch (Exception e) {
                error.add("Invalid pictureSetId, " + Utils.cleanup(request.getParameter("pictureSetId")));
            }
        }
        if (!Utils.cleanup(request.getParameter("orientation")).equals("")) {
            orientation = Utils.cleanup(request.getParameter("orientation"));
            orientation = orientation.toUpperCase();
            if (!orientation.equals("N")  &&
                !orientation.equals("NE") &&
                !orientation.equals("E")  &&
                !orientation.equals("SE") &&
                !orientation.equals("S")  &&
                !orientation.equals("SW") &&
                !orientation.equals("W")  &&
                !orientation.equals("NW") &&
                !orientation.equals("UP")) {
                error.add("Invalid orientation, " + orientation);
            }
            else {
                haveOrientation = true;
            }
        }
        size = Utils.cleanup(request.getParameter("size"));
        if (!size.equals("medium") && !size.equals("thumb")) {
            size = "full";
        }

        // Check that what we got makes sense.
        if (!havePictureId && !(havePictureSetId && haveOrientation)) {
            error.add("Either pictureId or (pictureSet and orientation) required");
        }
        else if (havePictureId && !Picture.dbIsValidPictureId(pictureId)) {
            error.add("Invalid pictureId");
        }
        else if (havePictureSetId && !PictureSet.dbIsValidPictureSetId(pictureSetId)) {
            error.add("Invalid pictureSetId");
        }

        // Any errors?
        if (!error.isEmpty()) {
            // Nowhere to send error messages...
            return;
        }

        // Get the picture record.
        if (havePictureId) {
            picture = new Picture(pictureId);
            pictureSet = new PictureSet(picture.getPictureSetId());
            post = new Post(pictureSet.getPostId());
        }
        else if (havePictureSetId && haveOrientation) {
            pictureSet = new PictureSet(pictureSetId);
            picture = PictureSet.getPictureRecord(pictureSet, orientation);
            post = new Post(pictureSet.getPostId());
        }

        // Print out the image.
        try {
            String file = Config.get("PICTURE_DIR") + "/" + post.getPostDir() + "/";
            if (size.equals("full")) file += picture.getImageFile();
            else if (size.equals("medium")) file += picture.getImageFileMedium();
            else if (size.equals("thumb")) file += picture.getImageFileThumb();
            byte[] buffer = new byte[10240];
            int numBytes;
            BufferedInputStream  in = new BufferedInputStream(new FileInputStream(file));
            ServletOutputStream out = response.getOutputStream();
            while ((numBytes = in.read(buffer)) != -1) {
                out.write(buffer, 0, numBytes);
            }
            in.close();
            out.close();
        }
        catch (Exception e) {
            return;
        }
    }
}
