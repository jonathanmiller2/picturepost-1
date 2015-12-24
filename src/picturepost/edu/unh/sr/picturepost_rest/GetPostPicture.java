package edu.unh.sr.picturepost_rest;

import javax.servlet.*;
import javax.servlet.http.*;
import java.util.*;
import java.io.*;
import edu.unh.sr.picturepost.*;

public class GetPostPicture extends HttpServlet {

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
        PostPicture postPicture       = null;
        Post        post              = null;
        int         postPictureId     = 0;
        String      size              = "full";

        if (!Utils.cleanup(request.getParameter("postPictureId")).equals("")) {
            try {
                postPictureId = Integer.parseInt(Utils.cleanup(request.getParameter("postPictureId")));
                if (!PostPicture.dbIsValidPostPictureId(postPictureId)) {
                    error.add("Invalid postPictureId");
                }
            }
            catch (Exception e) {
                error.add("Invalid postPictureId, " + Utils.cleanup(request.getParameter("postPictureId")));
            }
        }
        size = Utils.cleanup(request.getParameter("size"));
        if (!size.equals("medium") && !size.equals("thumb")) {
            size = "full";
        }

        // Any errors?
        if (!error.isEmpty()) {
            // Nowhere to send error messages...
            return;
        }

        // Get the picture record.
        postPicture = new PostPicture(postPictureId);
        post = new Post(postPicture.getPostId());

        // Print out the image.
        try {
            String file = Config.get("PICTURE_DIR") + "/" + post.getPostDir() + "/";
            if (size.equals("full"))        file += postPicture.getImageFile();
            else if (size.equals("medium")) file += postPicture.getImageFileMedium();
            else if (size.equals("thumb"))  file += postPicture.getImageFileThumb();
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
