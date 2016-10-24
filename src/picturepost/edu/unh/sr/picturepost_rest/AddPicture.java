package edu.unh.sr.picturepost_rest;

import javax.servlet.*;
import javax.servlet.http.*;

import java.util.*;
import java.io.*;

import org.apache.commons.fileupload.*;
import org.apache.commons.fileupload.disk.*;
import org.apache.commons.fileupload.servlet.*;
import org.json.JSONArray;
import org.json.JSONObject;

import com.drew.metadata.*;

import edu.unh.sr.picturepost.*;

public class AddPicture extends HttpServlet {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);
	}

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
		//int pictureId = 0;
		int pictureSetId = 0;
		String orientation       = "";
		String imageFileOriginal = "";
		String fileType          = "JPEG";
		String fileExt           = ".jpg";

		boolean autoDeleteExisting = false;

		// Grab all form parameters, both regular parameters as well as file upload parameters,
		// and put them in their own separate Vectors.
		Vector<FileItem> parameterItems = new Vector<FileItem>();
		Vector<FileItem> fileUploadItems = new Vector<FileItem>();
		try {
			// Check that we have a file upload request (and the form has been submitted).
			if (ServletFileUpload.isMultipartContent(request)) {

				// Create a factory for disk-based file items.
				FileItemFactory factory = new DiskFileItemFactory();

				// Create a new file upload handler.
				ServletFileUpload upload = new ServletFileUpload(factory);

				// Parse the request.
				@SuppressWarnings("rawtypes")
				List items = upload.parseRequest(request);

				// Process the uploaded items.
				@SuppressWarnings("rawtypes")
				Iterator iter = items.iterator();

				while (iter.hasNext()) {
					FileItem item = (FileItem)iter.next();
					if (item.isFormField()) {
						parameterItems.add(item);
						//error.add("aaa: "+item.getFieldName() + " " + item.getString());
					}
					else {
						fileUploadItems.add(item);
						//error.add("bbb: "+item.getFieldName());
					}
				}
			}
			else {
				error.add("Request is not multipart content.");
			}
		}
		catch (Exception e) {
			error.add(e.toString());
		}
		// First, we need to grab the easy stuff.
		for (int i = 0; i < parameterItems.size(); i++) {
			FileItem item = parameterItems.get(i);
			String fieldName = item.getFieldName();
			String fieldValue = item.getString();
			if (fieldName.equals("pictureSetId")) {
				try {
					pictureSetId = Integer.parseInt(Utils.cleanup(fieldValue));
				}
				catch (Exception e) {
					error.add("Invalid value for pictureSetId, " + Utils.cleanup(fieldValue));
				}
			}
			else if ("autoDeleteExisting".equals(fieldName) && "1".equals(fieldValue)) {
				autoDeleteExisting = true;
			}

			else if (fieldName.equals("orientation")) {
				orientation = Utils.cleanup(fieldValue);
			}
		}

		// Check that what we got makes sense.
		if (!PictureSet.dbIsValidPictureSetId(pictureSetId)) {
			error.add("Missing or invalid pictureSetId value: " + String.valueOf(pictureSetId));
		}
		if (!orientation.equals("N") &&
				!orientation.equals("NE") &&
				!orientation.equals("E") &&
				!orientation.equals("SE") &&
				!orientation.equals("S") &&
				!orientation.equals("SW") &&
				!orientation.equals("W") &&
				!orientation.equals("NW") &&
				!orientation.equals("UP")) {
			error.add("Missing or invalid orientation value: " + orientation);
		}

		// Any errors?
		if (!error.isEmpty()) {
			String buf = new JSONObject()
			    .put("error", new JSONArray(error))
			    .toString();
			out.println(buf);        	
			return;
		}

		// Create a Picture instance.
		Picture picture = new Picture();

		// Create a PictureSet instance.
		PictureSet pictureSet = new PictureSet(pictureSetId);

		// Create a Post instance.
		Post post = new Post(pictureSet.getPostId());

		Picture existingPictureRecord = PictureSet.getPictureRecord(pictureSet, orientation);
		if (existingPictureRecord != null) {
			if (autoDeleteExisting) {
				existingPictureRecord.dbDelete();
			} else {
				error.add("A picture already exists for this pictureSet/orientation. Picture ID follows:");
				error.add(String.valueOf(existingPictureRecord.getPictureId()));

				String buf = new JSONObject()
				    .put("error", new JSONArray(error))
				    .toString();
				out.println(buf);              
				return;
			}
		}

		if (fileUploadItems.size() == 0) {
			error.add("No files found.");
			String buf = new JSONObject()
			    .put("error", new JSONArray(error))
			    .toString();
			out.println(buf);    
			return;
		}

		// Now do all the steps necessary for an upload.
		for (int i = 0; i < fileUploadItems.size(); i++) {
			FileItem item = fileUploadItems.get(i);
			//String fieldName = item.getFieldName();
			imageFileOriginal = item.getName();
			long fileSize = item.getSize();
			String imageFile = "";
			String imageFileThumb = "";
			String imageFileMedium = "";

			// Replace any spaces in the imageFileOriginal with underscores.
			imageFileOriginal = imageFileOriginal.replaceAll("\\s", "_");

			// Strip off the leading path.  Some browsers send the path as well.
			for (int x = imageFileOriginal.length() - 1; x >= 0; x--) {
				if (imageFileOriginal.charAt(x) == '/' || imageFileOriginal.charAt(x) == '\\') {
					imageFileOriginal = imageFileOriginal.substring(x + 1);
					break;
				}
			}

			// Do we have a real file name?
			if (imageFileOriginal.equals("")) {
				error.add("Invalid file name: " + imageFileOriginal);
				String buf = new JSONObject()
				    .put("error", new JSONArray(error))
				    .toString();
				out.println(buf);    
				return;
			}

			// Do we have a non-zero file size?
			if (fileSize == 0) {
				error.add("Empty file, " + imageFileOriginal);
				String buf = new JSONObject()
				    .put("error", new JSONArray(error))
				    .toString();
				out.println(buf);
				return;
			}

			// Is the file too big?
			if (fileSize > Integer.parseInt(Config.get("MAX_FILE_UPLOAD_SIZE"))) {
				error.add(imageFileOriginal + " is too big to upload. Files must be less than " + Config.get("MAX_FILE_UPLOAD_SIZE") + " bytes.");
				String buf = new JSONObject()
				    .put("error", new JSONArray(error))
				    .toString();
				out.println(buf);
				return;
			}

			// Figure out the prefix and suffix of the file name.
			//String prefix = imageFileOriginal;
			String suffix = null;
			int dot = imageFileOriginal.lastIndexOf(".");
			if (dot > 0 && dot < imageFileOriginal.length() - 1) {
				// TODO phil - wasn't actually used
				//prefix = imageFileOriginal.substring(0, dot);
				suffix = imageFileOriginal.substring(dot);
			}
			else {
				error.add("Invalid file name, " + imageFileOriginal);
				String buf = new JSONObject()
				    .put("error", new JSONArray(error))
				    .toString();
				out.println(buf);
				return;
			}

			// Make sure we have a valid file extension.
			if (suffix.toLowerCase().equals(".jpg") || suffix.toLowerCase().equals(".jpeg")) {
				fileType = "JPEG";
				fileExt = ".jpg";
			}
			else {
				error.add("Unsupported file type, " + imageFileOriginal);
				String buf = new JSONObject()
				    .put("error", new JSONArray(error))
				    .toString();
				out.println(buf);
				return;
			}

			// Populate the Picture instance.
			if (!picture.dbSetPictureId()) {
				error.add("Could not set pictureId.");
				String buf = new JSONObject()
				    .put("error", new JSONArray(error))
				    .toString();
				out.println(buf);
				return;
			}
			picture.setPictureSetId(pictureSetId);
			picture.setOrientation(orientation);
			picture.setImageFileOriginal(imageFileOriginal);
			picture.setFileType(fileType);
			picture.setFileExt(fileExt);

			// Insert this picture into the db.
			if (!picture.dbInsert()) {
				error.add("Could not insert picture record.");
				String buf = new JSONObject()
				    .put("error", new JSONArray(error))
				    .toString();
				out.println(buf);
				return;
			}

			// Save the file locally.
			imageFile       = "picture_" + String.valueOf(picture.getPictureId()) + fileExt;
			imageFileThumb  = "picture_" + String.valueOf(picture.getPictureId()) + "_thumb" + fileExt;
			imageFileMedium = "picture_" + String.valueOf(picture.getPictureId()) + "_medium" + fileExt;
			try {
				File myPostDirectory = new File(Config.get("PICTURE_DIR") + File.separator + post.getPostDir());
				if (!myPostDirectory.exists()) {
					myPostDirectory.mkdirs();
				}
				item.write(new File(myPostDirectory + File.separator + imageFile));
			}
			catch (Exception e) {
				error.add("Could not write image file to disk, " + e.toString());
				String buf = new JSONObject()
				    .put("error", new JSONArray(error))
				    .toString();
				out.println(buf);
				return;
			}

			// Make sure it is really the same file type as the extension indicates.
			try {
				Process p = Runtime.getRuntime().exec("/usr/bin/file -b " + Config.get("PICTURE_DIR") + "/" + post.getPostDir() + "/" + imageFile);
				p.waitFor();
				byte[] buffer = new byte[256];
				if (p.getInputStream().read(buffer) > 0) {
					String returnStr = new String(buffer);
					if (!returnStr.startsWith(fileType + " image data")) {
						error.add(imageFileOriginal + "  is not really a " + fileType + ".");
						picture.dbDelete();
						String buf = new JSONObject()
						    .put("error", new JSONArray(error))
						    .toString();
						out.println(buf);    
						return;
					}
				}
			}
			catch (Exception e) {
				error.add("Could not determine file type of file " + imageFileOriginal);
				picture.dbDelete();
				String buf = new JSONObject()
				    .put("error", new JSONArray(error))
				    .toString();
				out.println(buf);
				return;
			}

			// Make a thumbnail
			try {
				Process p = Runtime.getRuntime().exec("/usr/bin/convert " + Config.get("PICTURE_DIR") + "/" + post.getPostDir() + "/" + imageFile + " -auto-orient -thumbnail 80x80 " + Config.get("PICTURE_DIR") + "/" + post.getPostDir() + "/" + imageFileThumb);
				p.waitFor();
			}
			catch (Exception e) {
				error.add("Could not create thumbnail, " + e.toString());
				String buf = new JSONObject()
				    .put("error", new JSONArray(error))
				    .toString();
				out.println(buf);
				return;
			}

			// Make a medium picture.
			try {
				Process p = Runtime.getRuntime().exec("/usr/bin/convert " + Config.get("PICTURE_DIR") + "/" + post.getPostDir() + "/" + imageFile + " -auto-orient -thumbnail 400x300 " + Config.get("PICTURE_DIR") + "/" + post.getPostDir() + "/" + imageFileMedium);
				p.waitFor();
			}
			catch (Exception e) {
				error.add("Could not create medium picture, " + e.toString());
				String buf = new JSONObject()
				    .put("error", new JSONArray(error))
				    .toString();
				out.println(buf);
				return;
			}

			// Extract the metadata.
			try {
				File jpegFile = new File(Config.get("PICTURE_DIR") + "/" + post.getPostDir() + "/" + imageFile);
				Metadata metadata = com.drew.imaging.jpeg.JpegMetadataReader.readMetadata(jpegFile);
				Iterator<Directory> directories = metadata.getDirectories().iterator();
				while (directories.hasNext()) {
					Directory directory = directories.next();
					Iterator<Tag> tags = directory.getTags().iterator();
					while (tags.hasNext()) {
						com.drew.metadata.Tag tag = tags.next();
						PictureMD pictureMD = new PictureMD();
						if (!pictureMD.dbSetPictureMDId()) {
							error.add("Could not set pictureMDId.");
							continue;
						}
						pictureMD.setPictureId(picture.getPictureId());
						pictureMD.setDirectory(Utils.cleanup(tag.getDirectoryName()));
						pictureMD.setTagId(tag.getTagType());
						pictureMD.setTagName(Utils.cleanup(tag.getTagName()));
						pictureMD.setTagValue(Utils.cleanup(tag.getDescription()));
						if (!pictureMD.dbInsert()) {
							error.add("Could not insert picture_md record.");
							continue;
						}
					}
				}
			}
			catch (com.drew.imaging.jpeg.JpegProcessingException jpe) {
				error.add("Could not extract metadata, " + jpe.toString());
			}
		}

		if (!error.isEmpty()) {
			String buf = new JSONObject()
			    .put("error", new JSONArray(error))
			    .toString();
			out.println(buf);
			return;
		}

		String buf = new JSONObject()
		    .put("pictureId", picture.getPictureId())
		    .toString();
		out.println(buf);
	}
}
