<%@ include file="/includes/common.jsp" %>
<%@ page import="org.apache.commons.net.ftp.*" %>
<%
String returnPage = request.getParameter("returnPage"); if (returnPage == null || returnPage.equals("")) returnPage = "index.jsp";
%>

<%
// Make sure the user is already logged in.
if (!Person.getInstance(session).isLoggedIn()) {
    response.sendRedirect("/login.jsp?returnPage=" + request.getRequestURI());
    return;
}

String ftpServer = Config.get("EXPORT_FTP_SERVER");
String username  = Config.get("EXPORT_FTP_USER");
String password  = Config.get("EXPORT_FTP_PASS");
String ftpPath   = Config.get("EXPORT_FTP_PATH");
if ("".equals(ftpServer) || "".equals(username) || "".equals(password) || "".equals(ftpPath)) {
  wu.addNotificationError("Cannot export files. Please check export ftp configuration settings.");
  wu.redirect("/myaccount.jsp");
  return;
}
%>

<%!
    private String uploadImage(FTPClient ftpClient, String fileName, String pictureName, String postDir, String filePath) {
      try {
      String ret = "Putting " + fileName + " as " + pictureName + " ... ";
      FTPFile[] files = ftpClient.listFiles();
      boolean fileExists = false;
      for (int i = 0; i < files.length; i++) {
        if (files[i].getName().equals(pictureName)) {
          fileExists = true;
          break;
        }
      }
      if (fileExists) {
        ret += "already exists";
        return ret;
      }
      else {
        FileInputStream fileInputStream = new FileInputStream(Config.get("PICTURE_DIR") + File.separator + postDir + File.separator + fileName);
        try {
          if (!ftpClient.storeFile(pictureName, fileInputStream)) {
            throw new Exception("Could not put file.");
          }
          else {
              ret += "OK";
          }
        }
        catch (Exception e) {
          ret += e.toString();
        }
        finally {
          fileInputStream.close();
          return ret;
        }
      }
      }
      catch (Exception e) {
        return "uploadImage exception: "+e.toString();
      }
    }
%>

<%
String newline = System.getProperty("line.separator");
Vector<String> error = new Vector<String>();
Vector<Post> postRecords = Post.dbGetPostRecords();
String[] orientations = {"N", "NE", "E", "SE", "S", "SW", "W", "NW", "UP" };
int postId = 0;
Post post = null;
String ftpDir = "";
boolean selectImageFileThumb  = true;
boolean selectImageFileMedium = true;
boolean selectImageFileFull   = true;
Vector<PictureSet> pictureSetRecords = new Vector<PictureSet>();

class PictureSetCheckbox {
    int pictureSetId;
    boolean checked;

    PictureSetCheckbox(int pictureSetId, boolean checked) {
        this.pictureSetId = pictureSetId;
        this.checked      = checked;
    }
}
Vector<PictureSetCheckbox> pictureSetCheckbox = new Vector<PictureSetCheckbox>();

class OrientationCheckbox {
    String orientation;
    boolean checked;

    OrientationCheckbox(String orientation, boolean checked) {
        this.orientation = orientation;
        this.checked     = checked;
    }
}
Vector<OrientationCheckbox> orientationCheckbox = new Vector<OrientationCheckbox>();
orientationCheckbox.add(new OrientationCheckbox("N",  true));
orientationCheckbox.add(new OrientationCheckbox("NE", true));
orientationCheckbox.add(new OrientationCheckbox("E",  true));
orientationCheckbox.add(new OrientationCheckbox("SE", true));
orientationCheckbox.add(new OrientationCheckbox("S",  true));
orientationCheckbox.add(new OrientationCheckbox("SW", true));
orientationCheckbox.add(new OrientationCheckbox("W",  true));
orientationCheckbox.add(new OrientationCheckbox("NW", true));
orientationCheckbox.add(new OrientationCheckbox("UP", true));


// Handle form submission.
String submitted = Utils.cleanup(request.getParameter("submitted"));
if (submitted.equals("selectPost") || submitted.equals("doFTP")) {

    // Get the postId.
    try {
        postId = Integer.parseInt(Utils.cleanup(request.getParameter("postId")));
        if (!Post.dbIsValidPostId(postId)) {
            submitted = "";
        }
        else {
            post = new Post(postId);
            pictureSetRecords = post.dbGetViewablePictureSetRecords(); 
            for (int ps = 0; ps < pictureSetRecords.size(); ps++) {
                pictureSetCheckbox.add(new PictureSetCheckbox(pictureSetRecords.get(ps).getPictureSetId(), true));
            }
        }
    }
    catch (Exception e) {
        submitted = "";
    }

    if (error.isEmpty()) {
        if (submitted.equals("selectPost")) {
            ftpDir = "post_" + String.valueOf(post.getPostId());
        }
        else if (submitted.equals("doFTP")) {
            ftpDir = Utils.cleanup(request.getParameter("ftpDir"));

            selectImageFileThumb  = (!Utils.cleanup(request.getParameter("selectImageFileThumb")).equals(""))  ? true : false;
            selectImageFileMedium = (!Utils.cleanup(request.getParameter("selectImageFileMedium")).equals("")) ? true : false;
            selectImageFileFull   = (!Utils.cleanup(request.getParameter("selectImageFileFull")).equals(""))   ? true : false;

            boolean anyOrientationsSelected = false;
            for (int r = 0; r < orientationCheckbox.size(); r++) {
                orientationCheckbox.get(r).checked = false;
                if (!Utils.cleanup(request.getParameter("orientation_" + orientationCheckbox.get(r).orientation)).equals("")) {
                    orientationCheckbox.get(r).checked = true;
                    anyOrientationsSelected = true;
                }
            }

            boolean anyPictureSetsSelected = false;
            for (int ps = 0; ps < pictureSetCheckbox.size(); ps++) {
                pictureSetCheckbox.get(ps).checked = false;
                if (!Utils.cleanup(request.getParameter("pictureSetId_" + String.valueOf(pictureSetCheckbox.get(ps).pictureSetId))).equals("")) {
                    pictureSetCheckbox.get(ps).checked = true;
                    anyPictureSetsSelected = true;
                }
            }

            // A little error checking.
            if (ftpDir.equals("")) {
                error.add("Missing FTP directory.");
            }
            else if (ftpDir.indexOf("/") > -1 || ftpDir.indexOf("\"") > -1) {
                error.add("Invalid FTP directory value.");
            }

            if (!selectImageFileThumb && !selectImageFileMedium && !selectImageFileFull) {
                error.add("Please select at least one image size.");
            }

            if (!anyOrientationsSelected) {
                error.add("Please select at least one orientation.");
            }

            if (!anyPictureSetsSelected) {
                error.add("Please select at least one picture set.");
            }
        }
    }
}
%>
<%@ include file="/includes/header.jsp" %>
<SCRIPT TYPE="text/javascript">
<!--

function selectPost() {
    document.getElementById("submitted").value = "selectPost";
    document.getElementById("theForm").submit();
}

function doFTP() {
    document.getElementById("submitted").value = "doFTP";
    document.getElementById("theForm").submit();
}

function selectAllPictureSets() {
    document.getElementById("selectDiv").innerHTML = "<A HREF=\"javascript:clearAllPictureSets();\">Clear All</A>";

<%
for (int ps = 0; ps < pictureSetCheckbox.size(); ps++) {
%>

    document.getElementById("pictureSetId_<%=String.valueOf(pictureSetCheckbox.get(ps).pictureSetId)%>").checked = true;

<%
}
%>

}

function clearAllPictureSets() {
    document.getElementById("selectDiv").innerHTML = "<A HREF=\"javascript:selectAllPictureSets();\">Select All</A>";

<%
for (int ps = 0; ps < pictureSetCheckbox.size(); ps++) {
%>

    document.getElementById("pictureSetId_<%=String.valueOf(pictureSetCheckbox.get(ps).pictureSetId)%>").checked = false;

<%
}
%>

}

//-->
</SCRIPT>
<div id=topbar class=clearfix>
  <h1>Export Pictures</h1>
</div>

<%=wu.popNotifications()%>


<DIV ID="container"> <!-- start container -->

<%
if (!submitted.equals("doFTP") || !error.isEmpty()) {
    if (!error.isEmpty()) {
%>

<SPAN CLASS="errorColor"><%=Utils.join(error, "<BR>")%></SPAN>
<DIV STYLE="height: 20px;"></DIV>

<%
    }
%>

<FORM ID="theForm" METHOD="post">

<DIV STYLE="margin-top: 20px;">
Post:
<SELECT ID="postId" NAME="postId" SIZE="1" onchange="selectPost();">
  <OPTION VALUE="0"> Please select a post

<%
    for (int i = 0; i < postRecords.size(); i++) {
%>

  <OPTION VALUE="<%=String.valueOf(postRecords.get(i).getPostId())%>" <%=(postRecords.get(i).getPostId() == postId) ? "SELECTED" : ""%>> <%=postRecords.get(i).getName()%>

<%
    }
%>

</SELECT>
</DIV>
<INPUT ID="submitted" NAME="submitted" TYPE="hidden">

<DIV STYLE="height: 20px;"></DIV>

<%
    if (submitted.equals("selectPost") || submitted.equals("doFTP")) {
%>

<TABLE BORDER="0">
  <TR>
    <TD><INPUT TYPE="checkbox" NAME="selectImageFileThumb" VALUE="1" <%=(selectImageFileThumb) ? "CHECKED" : ""%>></TD>
    <TD>Include thumbnail images</TD>
  </TR>
  <TR>
    <TD><INPUT TYPE="checkbox" NAME="selectImageFileMedium" VALUE="1" <%=(selectImageFileMedium) ? "CHECKED" : ""%>></TD>
    <TD>Include medium images</TD>
  </TR>
  <TR>
    <TD><INPUT TYPE="checkbox" NAME="selectImageFileFull" VALUE="1" <%=(selectImageFileFull) ? "CHECKED" : ""%>></TD>
    <TD>Include full images</TD>
  </TR>
</TABLE>

<DIV STYLE="height: 20px;"></DIV>

FTP directory on <%=ftpServer%>: <SPAN STYLE="font-weight: bold;"><%=ftpPath%></SPAN> <INPUT TYPE="text" NAME="ftpDir" VALUE="<%=ftpDir%>" SIZE="30"> <INPUT TYPE="button" VALUE="Create FTP directory and copy images over" onclick="doFTP();">

<DIV STYLE="height: 20px;"></DIV>

<%=String.valueOf(pictureSetRecords.size())%> picture sets
<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="1">
  <TR>
    <TH WIDTH="80" ALIGN="center" NOWRAP><DIV ID="selectDiv"><A HREF="javascript:clearAllPictureSets();">Clear All</A></DIV></TH>

<%
        for (int r = 0; r < orientationCheckbox.size(); r++) {
%>

    <TH WIDTH="80" ALIGN="center"><%=orientationCheckbox.get(r).orientation%> <INPUT TYPE="checkbox" NAME="orientation_<%=orientationCheckbox.get(r).orientation%>" VALUE="1" <%=(orientationCheckbox.get(r).checked) ? "CHECKED" : ""%>></TH>

<%
        }
%>

    <TH ALIGN="center">picture set<BR>Timestamp</TH>
    <TH ALIGN="center">Upload<BR>Timestamp</TH>
    <TH ALIGN="center">Person</TH>
  </TR>

<%
        for (int ps = 0; ps < pictureSetRecords.size(); ps++) {
            Vector<Picture> pictureRecords = pictureSetRecords.get(ps).dbGetPictureRecords();
            Person person = new Person(pictureSetRecords.get(ps).getPersonId());
%>

  <TR>
    <TD ALIGN="center" VALIGN="middle"><INPUT TYPE="checkbox" ID="pictureSetId_<%=String.valueOf(pictureSetCheckbox.get(ps).pictureSetId)%>" NAME="pictureSetId_<%=String.valueOf(pictureSetCheckbox.get(ps).pictureSetId)%>" VALUE="1" <%=(pictureSetCheckbox.get(ps).checked) ? "CHECKED" : ""%>></TD>

<%
            for (int i = 0; i < orientations.length; i++) {
                if (PictureSet.pictureRecordExists(pictureRecords, orientations[i])) {
                    int pictureId = PictureSet.getPictureRecord(pictureRecords, orientations[i]).getPictureId();
%>

    <TD STYLE="padding: 0px;"><IMG ID="picture_<%=String.valueOf(pictureId)%>" SRC="/images/pictures/<%=post.getPostDir()%>/<%=PictureSet.getPictureRecord(pictureRecords, orientations[i]).getImageFileThumb()%>" ALT="<%=Utils.htmlEscape(post.getName())%>, <%=String.valueOf(pictureSetRecords.get(ps).getPictureSetTimestamp()).substring(0, 19)%>, <%=orientations[i]%>" STYLE="border: 2px solid black;"></TD>

<%
                }
                else {
%>

    <TD><BR></TD>

<%
                }
            }
%>

    <TD><SPAN CLASS="smallText"><LABEL FOR="pictureSetId_<%=String.valueOf(pictureSetRecords.get(ps).getPictureSetId())%>"><%=String.valueOf(pictureSetRecords.get(ps).getPictureSetTimestamp()).substring(0, 19)%></LABEL></SPAN></TD>
    <TD><SPAN CLASS="smallText"><%=String.valueOf(pictureSetRecords.get(ps).getRecordTimestamp()).substring(0, 19)%></SPAN></TD>
    <TD><SPAN CLASS="smallText"><%=person.getFirstName()%> <%=person.getLastName()%></SPAN></TD>
  </TR>

<%
        }
%>

</TABLE>

</FORM>

<%
    }
}
else  {
%>

<H1>Doing the FTP now!!!</H1>
<PRE>

<%
    FTPClient ftpClient = new FTPClient();
    int replyCode;
    InputStream in;
    try {
        out.print("Connecting to " + ftpServer + "... "); out.flush();
        ftpClient.connect(ftpServer);
        replyCode = ftpClient.getReplyCode();
        if (!FTPReply.isPositiveCompletion(replyCode)) {
            ftpClient.disconnect();
        }
    }
    catch (IOException e) {
        if (ftpClient.isConnected()) {
            try {
                ftpClient.disconnect();
            }
            catch (Exception f) { }
        }
    }

    try {
        if (!ftpClient.isConnected()) {
            throw new Exception("Could not connect to the server");
        }
        out.println("OK"); out.flush();

        out.print("Logging in ... "); out.flush();
        if (!ftpClient.login(username, password)) {
            throw new Exception("Could not login to the server.");
        }
        out.println("OK"); out.flush();

        out.print("Changing to binary mode ... "); out.flush();
        if (!ftpClient.setFileType(FTP.BINARY_FILE_TYPE)) {
            throw new Exception("Could not change to binary mode.");
        }
        out.println("OK"); out.flush();

        ftpClient.makeDirectory(ftpPath);

        out.print("Changing working directory to " + ftpPath + " ... "); out.flush();
        if (!ftpClient.changeWorkingDirectory(ftpPath)) {
            throw new Exception("Could not cd to " + ftpPath);
        }
        out.println("OK"); out.flush();

        // Does the subdirectory (ftpDir) already exist?
        FTPFile[] subDirs = ftpClient.listDirectories();
        boolean ftpDirExists = false;
        for (int i = 0; i < subDirs.length; i++) {
            if (subDirs[i].getName().equals(ftpDir)) {
                ftpDirExists = true;
                break;
            }
        }
        if (!ftpDirExists) {
            out.print("Creating remote directory " + ftpDir + " ... "); out.flush();
            if (!ftpClient.makeDirectory(ftpDir)) {
                throw new Exception("Could not create remote directory, " + ftpDir);
            }
            out.println("OK"); out.flush();
        }

        out.print("Changing working directory to " + ftpDir + " ... "); out.flush();
        if (!ftpClient.changeWorkingDirectory(ftpDir)) {
            throw new Exception("Could not cd to " + ftpDir);
        }
        out.println("OK"); out.flush();

        // Keep track of which file is which in a separate text file.
        File tempFile = File.createTempFile("listFile", "tmp");
        BufferedWriter listFile = new BufferedWriter(new FileWriter(tempFile));
        String listFileName = "listFile." + String.valueOf(Utils.getCurrentTimestamp()).substring(0, 19).replaceAll(" ", "_");
        listFileName = listFileName.replaceAll(":", "_");
        listFileName = listFileName.replace('.', '_');
        listFile.write("pictureId,pictureSetTimestamp,orientation" + newline);

        // Start putting files.
        for (int ps = 0; ps < pictureSetCheckbox.size(); ps++) {
            if (pictureSetCheckbox.get(ps).checked) {
                PictureSet pictureSet = new PictureSet(pictureSetCheckbox.get(ps).pictureSetId);
                Vector<Picture> pictureRecords = pictureSet.dbGetPictureRecords();
                for (int r = 0; r < orientationCheckbox.size(); r++) {
                    if (orientationCheckbox.get(r).checked && PictureSet.pictureRecordExists(pictureRecords, orientationCheckbox.get(r).orientation)) {
                        Picture picture = PictureSet.getPictureRecord(pictureRecords, orientationCheckbox.get(r).orientation);
                        String ftpPostId = "p" + Utils.padString(String.valueOf(post.getPostId()), '0', 4);
                        String ftpOrientation = orientationCheckbox.get(r).orientation;
                        if      (ftpOrientation.equals("N")) ftpOrientation = "NN";
                        else if (ftpOrientation.equals("E")) ftpOrientation = "EE";
                        else if (ftpOrientation.equals("S")) ftpOrientation = "SS";
                        else if (ftpOrientation.equals("W")) ftpOrientation = "WW";
                        /*String ftpTimestamp = Utils.padString(String.valueOf(pictureSet.getPictureSetTimestampYear()),   '0', 4) +
                                              Utils.padString(String.valueOf(pictureSet.getPictureSetTimestampMonth()),  '0', 2) +
                                              Utils.padString(String.valueOf(pictureSet.getPictureSetTimestampDay()),    '0', 2) +
                                              Utils.padString(String.valueOf(pictureSet.getPictureSetTimestampHour()),   '0', 2) +
                                              Utils.padString(String.valueOf(pictureSet.getPictureSetTimestampMinute()), '0', 2);*/
                        String ftpTimestamp = pictureSet.getPictureSetTimestamp().toString();
                        String ftpImageFileBasename = ftpPostId + ftpOrientation + ftpTimestamp;
                        ftpImageFileBasename = ftpImageFileBasename.replaceAll(":", "_");
                        ftpImageFileBasename = ftpImageFileBasename.replaceAll(" ", "_");
                        ftpImageFileBasename = ftpImageFileBasename.replace('.', '_');
                        String ftpImageFileThumb  = ftpImageFileBasename + "_thumb.jpeg";
                        String ftpImageFileMedium = ftpImageFileBasename + "_medium.jpeg";
                        String ftpImageFile       = ftpImageFileBasename + ".jpeg";
                        if (selectImageFileThumb) {
                          out.println(uploadImage(ftpClient, picture.getImageFileThumb(), ftpImageFileThumb, post.getPostDir(), ftpPath+ftpDir));
                        }
                        if (selectImageFileMedium) {
                          out.println(uploadImage(ftpClient, picture.getImageFileMedium(), ftpImageFileMedium, post.getPostDir(), ftpPath+ftpDir));
                        }
                        if (selectImageFileFull) {
                          out.println(uploadImage(ftpClient, picture.getImageFile(), ftpImageFile, post.getPostDir(), ftpPath+ftpDir));
                        }

                        // Log this in the listFile.
                        listFile.write(ftpImageFileBasename + "," + pictureSetRecords.get(ps).getPictureSetTimestamp() + "," + orientationCheckbox.get(r).orientation + newline);
                    }
                }
            }
        }
        listFile.close();

        // Put the listFile too.
        out.print("Putting " + listFileName + " ... "); out.flush();
        FileInputStream fileInputStream = new FileInputStream(tempFile);
        try {
            if (!ftpClient.storeFile(listFileName, fileInputStream)) {
                throw new Exception("Could not put file.");
            }
            out.println("OK"); out.flush();
        }
        catch (Exception e) {
            out.println(e.toString()); out.flush();
        }
        finally {
            fileInputStream.close();
        }
    }
    catch (Exception e) {
        out.println(e.toString()); out.flush();
    }
    finally {
        ftpClient.logout();
        if (ftpClient.isConnected()) {
            try {
                ftpClient.disconnect();
            }
            catch (Exception f) {
                // do nothing
            }
        }
    }
}
%>

</PRE>

</DIV> <!-- end container -->

<%@ include file="/includes/footer.jsp" %>
