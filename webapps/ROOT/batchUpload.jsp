<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="org.apache.commons.fileupload.disk.*" %>
<%@ page import="org.apache.commons.fileupload.servlet.*" %>
<%@ page import="com.drew.metadata.*" %>
<%@ page import="com.google.common.primitives.*" %>
<%@ page import="com.google.common.io.*"%>
<%@ page import="com.google.common.collect.*"%>
<%@ page import="net.lingala.zip4j.core.*" %>
<%@ page import="net.lingala.zip4j.exception.*" %>
<%@ page import="net.lingala.zip4j.model.*" %>
<%@ include file="/includes/common.jsp" %>
<%

// make sure user is logged in
if (! sessionuser.isLoggedIn()) {
  wu.sendLogin();
  return;
}

int postId = wu.param_int("postId",0);
if (postId == 0 || !Post.dbIsValidPostId(postId)) {
  wu.addNotificationError("Sorry, this is not a valid post.");
  wu.redirect("/news.jsp");
  return;
}

SimpleDateFormat format_pictureset_dt = new SimpleDateFormat("EEE, d MMM yyyy HH:mm");

BatchUpload.picture_sets_created_map = new HashMap<Integer, PictureSet>();

String ignore_filenames = "";

// All the orientations.
Vector<String> orientations = BatchUpload.orientations;

int SIMPLE_FORMAT_FILE_UPLOAD_LIMIT = Integer.parseInt(
Config.get("SIMPLE_FORMAT_FILE_UPLOAD_LIMIT","10"));

int ADVANCED_FORMAT_FILE_UPLOAD_LIMIT = Integer.parseInt(
Config.get("ADVANCED_FORMAT_FILE_UPLOAD_LIMIT","10"));

int SIMPLE_FILES_IN_ADVANCED_FORMAT_FILE_LIMIT = Integer.parseInt(
Config.get("SIMPLE_FILES_IN_ADVANCED_FORMAT_FILE_LIMIT","10"));

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
        List items = upload.parseRequest(request);

        // Process the uploaded items.
        Iterator iter = items.iterator();

        while (iter.hasNext()) {
            FileItem item = (FileItem)iter.next();
            if (item.isFormField()) {
                parameterItems.add(item);
            }
            else {
                fileUploadItems.add(item);
            }
        }
    }
}
catch (Exception e) {
    Log.writeLog(e.toString());
}

// Handle form submission.
String submitted = "";
for (int i = 0; i < parameterItems.size(); i++) {
    FileItem item = parameterItems.get(i);
    String fieldName = item.getFieldName();
    String fieldValue = item.getString();
    if (fieldName.equals("submitted")) {
        submitted = Utils.cleanup(fieldValue);
        break;
    }
    if (fieldName.equals("ignore_filenames")) {
        ignore_filenames = Utils.cleanup(fieldValue);
    }
}

// The user submitted the form somehow.
if (!submitted.equals("")) {
    // The user clicked the Upload button.  Do all the steps necessary for an upload.
    if (submitted.equals("Upload")) {
        // Log the upload.
        //Log.writeLog("Pictures uploaded! personId = " + String.valueOf(Person.getInstance(session).getPersonId()));

        for (int i = 0; i < fileUploadItems.size(); i++) {
            //Log.writeLog("\n");
            FileItem item = fileUploadItems.get(i);
            String fieldName = item.getFieldName();
            String fileName = item.getName();
            Long fileSize = item.getSize();
            Integer index = new Integer(i);
            //Log.writeLog("index " + index + " filename " + fileName + " fileSize " + fileSize.toString());

            if (fileSize == 0) {
                //Log.writeLog("skip");
                continue;
            }

            File zipFileTemp;
            try {
                zipFileTemp = File.createTempFile("zipUpload", null);
            } catch (Exception e) {
                wu.addNotificationError("Could not save zip file " + fileName);
                //Log.writeLog("ERROR, " + request.getRequestURI() + ": Could not create temp file: " + e.toString());
                break;
            }
            //Log.writeLog("temp file name " + zipFileTemp.getAbsolutePath());

            try {
                item.write(zipFileTemp);
            } catch (Exception e) {
                wu.addNotificationError("Could not save zip file " + fileName);
                //Log.writeLog("ERROR, " + request.getRequestURI() + ": Could not save image file " + fileName + ", " + e.toString());
                break;
            }

            //Log.writeLog("temp file size " + zipFileTemp.length());
            //Log.writeLog("temp file path " + zipFileTemp.getAbsolutePath());

            BatchUpload batch_upload = new BatchUpload(zipFileTemp, fileName,
                                       request, response, session, "simple", ignore_filenames);
            try {
				if (!batch_upload.upload())
                	wu.addNotificationError("No photos found in " + fileName);
				else
					batch_upload.cleanup();
            } catch (RuntimeException e) {
                wu.addNotificationError(e.getMessage());
                continue;
            }
        }
    }
}
%>
<%@ include file="/includes/header.jsp" %>
<script src="/multifile.js"></script>

<div class=clearfix id=topbar style='text-align: center;'>
  <a href="post.jsp?postId=<%=postId%>" class="btn btn-default pull-left"><span class="glyphicon glyphicon-menu-left" aria-hidden="true"></span> post</a>
  <h1>Multiple picture set Upload</h1>
</div>

<%=wu.popNotifications()%>

<form method=post action='?postId=<%=request.getParameter("postId")%>' enctype="multipart/form-data">
  <input type="hidden" value="yes" name="ignore_filenames">

  <% if (BatchUpload.picture_sets_created_map.isEmpty()) { %>
  
    <div id="fileSelectDiv" class=well style='float:left; margin-right: 20px;'>
      <h3 style='margin: 0; margin-bottom:20px; text-align:center;'>Upload Files</h3>
      
    <div id="fileList"></div>

    <div id="fileUploads">
    <% for(int i=0; i < SIMPLE_FORMAT_FILE_UPLOAD_LIMIT; i++) {
         String fieldname = "simple_format_file_"+i;
    %>
      <input type=file id='<%=fieldname%>' name='<%=fieldname%>'><br>
    <% } %>
    </div>
  
    <div id="uploadDiv">
      <input class="btn btn-primary" type="submit" name="submitted" value="Upload">
    </div>
  
    </div>
    <div class="alert alert-info" role="alert" style='float:left;'>
    <span class="glyphicon glyphicon-info-sign" aria-hidden="true"></span>
    <strong>Help</strong>
    <ul>
      <li>Select zip files  you created for each picture set you want to upload.
      <li>Each file must end in ".zip" and contain up to 9 JPEG images.<Br>
      <li>Locate your zip file and select it. Once selected, the file name appears in the list below.
      <li>Repeat for up to 10 picture sets.   
      <li>When you have made your selections, click "Upload".<br>
      <li>Once uploaded, each picture set will appear as a link.<br>
      <li>Click on the links to review and finalize your picture sets.
    </ul>
    <p style='margin-top:2em;'>
    <a href=/howtoUpload_photos.jsp class="btn btn-default">view more help</a>
    </div>
  <% } else { %>
    <div class="alert alert-success" role="alert">
      The following is a list of all of the picture set(s) created from the upload.  You can click on the links to open the "picture set" in a new window.  This will allow you to review and submit the picture set.
      <ul>
      <% for(PictureSet ps : BatchUpload.picture_sets_created_map.values()) {
            Timestamp ts = ps.getPictureSetTimestamp();
            String dt = format_pictureset_dt.format(ts);
          %>
        <li><a href="/picset.jsp?id=<%=ps.getPictureSetId()%>">Post ID: <%=ps.getPostId()%>, Date/Time <%= dt %></a>
      <% } %>
     </ul>
    </div>
  
    <p>
    <a class="btn btn-default" href='batchUpload.jsp'>upload more picture sets</a>
  <% } %>
</form>
<%@ include file="/includes/footer.jsp" %>
