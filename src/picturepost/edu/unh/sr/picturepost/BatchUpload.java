package edu.unh.sr.picturepost;

import com.google.common.io.*;

import net.lingala.zip4j.core.*;
import net.lingala.zip4j.exception.*;

import java.io.*;
import java.util.*;
import java.util.regex.*;

import com.drew.metadata.*;
import com.drew.metadata.exif.ExifSubIFDDirectory;

import javax.servlet.http.*;

import org.apache.commons.fileupload.*;
import org.apache.commons.io.*;


public class BatchUpload {
    public File zipfile;
    public Vector<File> zipDstDirs = new Vector<File>();
    public String upload_filename;
    public FileItem zip_file_item;
    public File zipFileTemp;
    public String upload_access;
    public HttpServletRequest request;
    public HttpServletResponse response;
    public HttpSession session;
    public String ignore_filenames;
    public static final Comparator<String> alphanum_compatator = new AlphanumComparator();

    //public Vector<PictureSet> picture_sets_created = new Vector<PictureSet>();
    public static Map<Integer, PictureSet> picture_sets_created_map = new HashMap<Integer, PictureSet>();

    // Handle errors.
    public Vector<String> error = new Vector<String>();

    public static final Vector<String> orientations = new Vector<String>(Arrays.asList(new String[] { "N", "NE", "E", "SE", "S", "SW", "W", "NW", "UP", "Swap" }));

    public BatchUpload(File zipFileTemp, String upload_filename,
                       HttpServletRequest request, HttpServletResponse response, HttpSession session,
                       String upload_access, String ignore_filenames) {
        this.zipFileTemp = zipFileTemp;
        //Log.writeLog("zipFileTemp " + zipFileTemp);
        this.session = session;
        this.request = request;
        this.response = response;
        this.upload_access = upload_access;
        this.upload_filename = upload_filename;
        this.ignore_filenames = ignore_filenames;
        //Log.writeLog("ignore filenames " + this.ignore_filenames);
    }            

    public void cleanup() {
        try {

            if (zipDstDirs != null) {
                //Log.writeLog("deleting " + zipFileTemp.getName());
                boolean rt = zipFileTemp.delete();
                if (! rt) {
                	Log.writeLog("could not remove temp dir: zipFileTemp");
                }
            }

            if (zipDstDirs != null) {
                for (File d : zipDstDirs) {
                    if (d == null) {
                        continue;
                    }
                    //Log.writeLog("deleting zipDstDir " + d.getName());
                    FileUtils.deleteDirectory(d);
                }
            }
        }
        catch (Exception e){
            Log.writeLog("ERROR: " + e.toString());
            Log.writeLog(exceptionToString(e));
        }
    }

    private String exceptionToString(Throwable t) {
        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);
        t.printStackTrace(pw);
        return sw.toString(); // stack trace as a string
    }

    public Post getPostFromFilename(String filename) {
        //Log.writeLog("getPostFromFilename filename " + filename);
        Pattern p = Pattern.compile("[a-zA-Z-_ ]*(\\d+)\\.zip");
        Matcher m = p.matcher(filename.toLowerCase());
        //Log.writeLog("Log.writeLog matcher " + m + " " + m.matches());
        if (m.matches()) {
            String postid = m.group(1);
            if (postid != null) {
                int post_id = Integer.parseInt(postid);
                if (Post.dbIsValidPostId(post_id)) {
                    Log.writeLog("getPostFromFilename postid " + postid);
                    return new Post(post_id);
                }
                else {
                    throw new BatchUploadException("Invalid/unknown postId, " + post_id + " for file " + filename);
                }
            }
        }
        return null;
    }

    PictureSet picture_set = null;

    PictureSet pictureSetFactory(int postId) {
        if (picture_set != null) {
            return picture_set;
        }
        else {
            // create PictureSet
            PictureSet pictureSet = new PictureSet();
            if (!pictureSet.dbSetPictureSetId()) {
                //Log.writeLog("ERROR: " + request.getRequestURI() + ", Could not set pictureSetId.");
                //response.sendRedirect("/index.jsp");
                return null;
            }

            pictureSet.setPostId(postId);
            pictureSet.setPersonId(Person.getInstance(session).getPersonId());
            pictureSet.setRecordTimestamp(Utils.getCurrentTimestamp());

            // save to DB, we'll be using the picture_set_id for the pictures.
            Log.writeLog("PSF pictureSet dbInsert " + pictureSet.getPictureSetId());
            pictureSet.dbInsert();
            return pictureSet;
        }
    }

    public boolean process_image_file(File image_file, Post post, PictureSet pictureSet) {
        // Populate the pictureRecords Vector with records from the database.
        Vector<Picture> pictureRecords = pictureSet.dbGetPictureRecords();
        Date pictureSetDate = null;

        try {
            if (image_file == null) {
                Log.writeLog("image_file is null, returning");
                return false;
            }
            String imageFileOriginal = image_file.getName();
            long file_size = image_file.length();
            String imageFile = "";
            String imageFileThumb = "";
            String imageFileMedium = "";
                
            // Replace any spaces in the imageFileOriginal with underscores.
            imageFileOriginal = imageFileOriginal.replaceAll("\\s", "_");

            // Strip off the leading path.  Some browsers send the path as well.
            for (int x = imageFileOriginal.length() - 1; x >= 0; x--) {
                if (imageFileOriginal.charAt(x) == '/' || imageFileOriginal.charAt(x) == '\\') { // '
                    imageFileOriginal = imageFileOriginal.substring(x + 1);
                    return true;
                }
            }

            // Do we have a real file name?
            if (imageFileOriginal.equals("")) {
                Log.writeLog("image file original is empty, returning");
                return false;
            }

            // Do we have a non-zero file size?
            if (file_size == 0) {
                error.add("Empty file, " + imageFileOriginal);
                Log.writeLog("ERROR, " + request.getRequestURI() + ": Empty file, " + imageFileOriginal);
                return false;
            }

            // Is the file too big?
            if (upload_access.equals("simple") && file_size > Integer.parseInt(Config.get("MAX_FILE_UPLOAD_SIZE"))) {
                error.add(imageFileOriginal + " is too big to upload. Files must be less than " + Config.get("MAX_FILE_UPLOAD_SIZE") + " bytes.");
                Log.writeLog("ERROR, " + request.getRequestURI() + ": " + imageFileOriginal + " is too big to upload.");
                return false;
            }

            // Figure out the prefix and suffix of the file name.
            String suffix = null;
            int dot = imageFileOriginal.lastIndexOf(".");
            if (dot > 0 && dot < imageFileOriginal.length() - 1) {
                suffix = imageFileOriginal.substring(dot);
            }
            else {
                error.add("Invalid file name, " + imageFileOriginal);
                Log.writeLog("ERROR, " + request.getRequestURI() + ": Invalid file name, " + imageFileOriginal);
                return false;
            }
            Log.writeLog("SUFFIX " + suffix);

            // Make sure we have a valid file extension.
            String fileType = "?";
            String fileExt = "?";
            if (suffix.toLowerCase().equals(".jpg") || suffix.toLowerCase().equals(".jpeg")) {
                fileType = "JPEG";
                fileExt = ".jpg";
            } else {
                error.add("Unsupported file type, " + imageFileOriginal);
                Log.writeLog("ERROR, " + request.getRequestURI() + ": Unsupported file type, " + imageFileOriginal);
                return false;
            }

            // Create a Picture instance to hold this.
            Picture picture = new Picture();
            if (!picture.dbSetPictureId()) {
                error.add("An error occured.");
                Log.writeLog("ERROR, " + request.getRequestURI() + ": Could not set pictureId");
                return false;
            }
            Log.writeLog("pif picture set " + pictureSet.getPictureSetId());
            picture.setPictureSetId(pictureSet.getPictureSetId());
            picture.setImageFileOriginal(imageFileOriginal);
            picture.setFileType(fileType);
            picture.setFileExt(fileExt);

            // Determine the orientation for this picture.  Use the first available.
            boolean vacant;
            for (int z = 0; z < orientations.size() && !orientations.get(z).equals("Swap"); z++) {
                vacant = true;
                for (int p = 0; p < pictureRecords.size(); p++) {
                    if (pictureRecords.get(p).getOrientation().equals(orientations.get(z))) {
                        vacant = false;
                        break;
                    }
                }
                if (vacant) {
                    picture.setOrientation(orientations.get(z));
                    break;
                }
            }

            Log.writeLog("pif: saving file locally");

            // Save the file locally.
            imageFile       = "picture_" + String.valueOf(picture.getPictureId()) + fileExt;
            imageFileThumb  = "picture_" + String.valueOf(picture.getPictureId()) + "_thumb" + fileExt;
            imageFileMedium = "picture_" + String.valueOf(picture.getPictureId()) + "_medium" + fileExt;
            try {

                File dstdir = new File(Config.get("PICTURE_DIR") + "/" + post.getPostDir());;
                if (!dstdir.exists()) {
                    dstdir.mkdirs();
                }
                
                //item.write(new File(Config.get("PICTURE_DIR") + "/" + post.getPostDir() + "/" + imageFile));
                Files.copy(image_file, new File(Config.get("PICTURE_DIR") + "/" + post.getPostDir() + "/" + imageFile));
            }
            catch (Exception e) {
                error.add("Could not save image file " + imageFileOriginal);
                Log.writeLog("ERROR, " + request.getRequestURI() + ": Could not save image file " + imageFileOriginal + ", " + e.toString());
                return false;
            }

            Log.writeLog("pif: check file's type by inspecting the file");

            // Make sure it is really the same file type as the extension indicates.
            try {
                Process p = Runtime.getRuntime().exec("/usr/bin/file -b " + Config.get("PICTURE_DIR") + "/" + post.getPostDir() + "/" + imageFile);
                p.waitFor();
                byte[] buffer = new byte[256];
                if (p.getInputStream().read(buffer) > 0) {
                    String returnStr = new String(buffer);
                    if (!returnStr.startsWith(fileType + " image data")) {
                        error.add(imageFileOriginal + "  is not really a " + fileType + ".");
                        Log.writeLog("ERROR, " + request.getRequestURI() + ": " + imageFileOriginal + "  is not really a " + fileType + ".");
                        picture.dbDelete();
                        return false;
                    }
                }
            }
            catch (Exception e) {
                error.add("Could not determine file type of file " + imageFileOriginal);
                Log.writeLog("ERROR, " + request.getRequestURI() + ": Could not determine file type of file " + imageFileOriginal + ", " + e.toString());
                picture.dbDelete();
                return false;
            }

            // Insert this Picture instance into the db.
            if (!picture.dbInsert()) {
                Log.writeLog("ERROR, " + request.getRequestURI() + ": Could not insert picture record.");
                return false;
            }

            // Add this Picture instance to the pictureRecords Vector.
            pictureRecords.add(picture);

            // Make a thumbnail
            try {
                Process p = Runtime.getRuntime().exec("/usr/bin/convert " + Config.get("PICTURE_DIR") + "/" + post.getPostDir() + "/" + imageFile + " -auto-orient -thumbnail 80x80 " + Config.get("PICTURE_DIR") + "/" + post.getPostDir() + "/" + imageFileThumb);
                p.waitFor();
            }
            catch (Exception e) {
                Log.writeLog("ERROR, " + request.getRequestURI() + ": Could not create thumbnail, " + e.toString());
            }

            // Make a medium picture.
            try {
                Process p = Runtime.getRuntime().exec("/usr/bin/convert " + Config.get("PICTURE_DIR") + "/" + post.getPostDir() + "/" + imageFile + " -auto-orient -thumbnail 400x300 " + Config.get("PICTURE_DIR") + "/" + post.getPostDir() + "/" + imageFileMedium);
                p.waitFor();
            }
            catch (Exception e) {
                Log.writeLog("ERROR, " + request.getRequestURI() + ": Could not create medium picture, " + e.toString());
            }

            // Extract the metadata.
            try {
                File jpegFile = new File(Config.get("PICTURE_DIR") + "/" + post.getPostDir() + "/" + imageFile);
                Metadata metadata = com.drew.imaging.jpeg.JpegMetadataReader.readMetadata(jpegFile);
                Iterator<Directory> directories = metadata.getDirectories().iterator();
                while (directories.hasNext()) {
                    Directory directory = (Directory)directories.next();
                    Iterator<Tag> tags = directory.getTags().iterator();
                    while (tags.hasNext()) {
                        com.drew.metadata.Tag tag = (Tag)tags.next();
                        //Log.writeLog("Tag name " + tag.getTagName() + " Tag Desc. " + tag.getDescription());
                        PictureMD pictureMD = new PictureMD();
                        if (!pictureMD.dbSetPictureMDId()) {
                            Log.writeLog("ERROR: " + request.getRequestURI() + ", Could not set pictureMDId.");
                            continue;
                        }
                        pictureMD.setPictureId(picture.getPictureId());
                        pictureMD.setDirectory(Utils.cleanup(tag.getDirectoryName()));
                        pictureMD.setTagId(tag.getTagType());
                        pictureMD.setTagName(Utils.cleanup(tag.getTagName()));
                        //pictureMD.setTagValue(Utils.cleanup(tag.getDescription()));
                        if (!pictureMD.dbInsert()) {
                            Log.writeLog("ERROR: " + request.getRequestURI() + ", Could not insert picture_md record.");
                            continue;
                        }

                        // For the first picture uploaded, if this is the Date/Time field, use it to set pictureSetTimestamp.
                        if (pictureSetDate == null) {
                        	ExifSubIFDDirectory directory2 = metadata.getDirectory(ExifSubIFDDirectory.class);
                            if (directory2 != null) {
                            	pictureSetDate = directory2.getDate(ExifSubIFDDirectory.TAG_DATETIME_ORIGINAL);                    
                            }
                        }
                    }
                }
            }
            catch (com.drew.imaging.jpeg.JpegProcessingException jpe) {
                Log.writeLog("1ERROR: " + request.getRequestURI() + ", Could not extract metadata, " + jpe.toString());
            }
        } catch (Exception e) {
            Log.writeLog("ERROR: " + e.toString());
            Log.writeLog(exceptionToString(e));
        }
        Log.writeLog("leaving process image file.");
        
        if (pictureSetDate == null) {
        	pictureSetDate = new Date();
        }
		pictureSet.setPictureSetDate(pictureSetDate);

        return true;
    }
    
    private String[] ALLOWED_PHOTO_EXT = {"jpg","jpeg","JPG","JPEG"};

    @SuppressWarnings("unchecked")
	public boolean upload() throws IOException {
        try {
            // create tmp directory and extract zip file to it.
            File zipDstDir = Files.createTempDir();
            //Log.writeLog("temp dir path " + zipDstDir.getAbsolutePath());
            
            
            ZipFile zip_file = new ZipFile(zipFileTemp.getAbsolutePath());
            zip_file.extractAll(zipDstDir.getAbsolutePath());
            
            Iterator<File> fileIt = FileUtils.iterateFiles(zipDstDir, ALLOWED_PHOTO_EXT, true);
            
            HashMap<String,File> filemap = new HashMap<String,File>();

            while (fileIt.hasNext()) {
            	File f = fileIt.next();
            	//Log.writeLog("found file: " + f.getAbsolutePath());
                filemap.put(f.getName(), f);
            }

            List<String> keys = new ArrayList<String>(filemap.keySet());
            Collections.sort(keys, alphanum_compatator);

            Post post = new Post();
            if (ignore_filenames.equals("yes")) {
                // Make sure we have a valid postId.
                int postId = 0;
                try {
                    postId = Integer.parseInt(Utils.cleanup(request.getParameter("postId")));
                }
                catch (Exception e) { }
                if (!Post.dbIsValidPostId(postId)) {
                    throw new BatchUploadException("Invalid/unknown postId, " + String.valueOf(postId));
                }
                //Log.writeLog("postId " + postId);
                post = new Post(postId);
            }
            else if (ignore_filenames.equals("no")) {
                post = getPostFromFilename(upload_filename);
            }

            int cnt = 1;
            if (keys.size() == 0)
            	return false;
            for(String key: keys) {
                File image_file = filemap.get(key);
                
                
	            picture_set = pictureSetFactory(post.getPostId());
	            if (process_image_file(image_file, post, picture_set)) {
		            picture_sets_created_map.put(picture_set.getPictureSetId(), picture_set);
		            picture_set.dbUpdate();
		            
	                String filename = image_file.getName();
	                Log.writeLog("adding " + filename);
		            
		            if (cnt == 9) {
		            	break;
		            }
		            cnt++;
	            }
            }
       } catch (ZipException e) {
            Log.writeLog("ERROR: " + e.toString());
       }
       return true;
    }
}
