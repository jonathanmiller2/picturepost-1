<%@ page import="edu.unh.sr.picturepost.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.io.*" %>

<%@ include file="/includes/rememberMe.jsp" %>

<%
NumberFormat nf = NumberFormat.getInstance();
nf.setMinimumFractionDigits(6);
nf.setMaximumFractionDigits(6);
%>

<%
// Make sure we have a valid postId.
int postId = 0;
try {
    postId = Integer.parseInt(Utils.cleanup(request.getParameter("postId")));
}
catch (Exception e) { }
if (!Post.dbIsValidPostId(postId)) {
    Log.writeLog("ERROR, " + request.getRequestURI() + ": Invalid postId, " + String.valueOf(postId));
    response.sendRedirect("/index.jsp");
    return;
}
Post post = new Post(postId);
Person postOwner = new Person(post.getPersonId());
Person person = new Person(Person.getInstance(session).getPersonId());
Vector<PostPicture> postPictureRecords = post.dbGetActivePostPictureRecords();
%>

<%@ include file="/includes/doctype.jsp" %>
<HTML>
<HEAD>
<TITLE>Picture Post: Post Info</TITLE>
<LINK REL="stylesheet" TYPE="text/css" HREF="/css/picturepost.css">
<SCRIPT TYPE="text/javascript">
<!--

function swapPostPicture(imageFile, imageFileMedium) {
    document.getElementById("postPictureMediumDiv").innerHTML = "<A HREF=\"<%=Config.get("PICTURE_DIR_URL")%>/<%=post.getPostDir()%>/" + imageFile + "\"><IMG SRC=\"<%=Config.get("PICTURE_DIR_URL")%>/<%=post.getPostDir()%>/" + imageFileMedium + "\" ALT=\"<%=Utils.htmlEscape(post.getName())%>\" STYLE=\"border: 2px solid black;\"></A>";
}

//-->
</SCRIPT>
</HEAD>

<BODY BGCOLOR="#FFFFFF">
<%@ include file="/includes/header.jsp" %>

<DIV id="container" style="padding-left:10px"> <!-- start container -->
<TABLE BORDER=0>
  <TR>
    <TD VALIGN="top">

<%
if (!postPictureRecords.isEmpty() &&
    new File(Config.get("PICTURE_DIR") + "/" + post.getPostDir() + "/" + postPictureRecords.get(0).getImageFile()).isFile() &&
    new File(Config.get("PICTURE_DIR") + "/" + post.getPostDir() + "/" + postPictureRecords.get(0).getImageFileMedium()).isFile() &&
    new File(Config.get("PICTURE_DIR") + "/" + post.getPostDir() + "/" + postPictureRecords.get(0).getImageFileThumb()).isFile()
   ) {
%>

      <DIV ID="postPictureMediumDiv">
        <A HREF="<%=Config.get("PICTURE_DIR_URL")%>/<%=post.getPostDir()%>/<%=postPictureRecords.get(0).getImageFile()%>"><IMG SRC="<%=Config.get("PICTURE_DIR_URL")%>/<%=post.getPostDir()%>/<%=postPictureRecords.get(0).getImageFileMedium()%>" ALT="<%=Utils.htmlEscape(post.getName())%>" STYLE="border: 2px solid black;"></A>
      </DIV>
      <DIV ID="postPictureThumbsDiv" STYLE="margin-top: 10px;">
        <TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
          <TR>

<%
    for (int i = 0; i < postPictureRecords.size(); i++) {
%>

            <TD><IMG SRC="<%=Config.get("PICTURE_DIR_URL")%>/<%=post.getPostDir()%>/<%=postPictureRecords.get(i).getImageFileThumb()%>" ALT="<%=Utils.htmlEscape(post.getName())%>" STYLE="border: 2px solid black;" onclick="javascript:swapPostPicture('<%=postPictureRecords.get(i).getImageFile()%>', '<%=postPictureRecords.get(i).getImageFileMedium()%>');"></TD>
<%
    }
%>

          </TR>
        </TABLE>
      </DIV>

<%
}
else {
%>

      <BR>

<%
}
%>

    </TD>
    <TD VALIGN="top">
      <TABLE>
        <TR>
          <TH ALIGN=left VALIGN=top WIDTH="175px">Name:</TH>
          <TD><%=Utils.htmlEscape(post.getName())%></TD>
        </TR>
        <TR>
          <TH ALIGN=left VALIGN=top>Description:</TH>
          <TD><%=Utils.htmlEscape(post.getDescription())%></TD>
        </TR>
        <TR>
          <TH ALIGN=left VALIGN=top>Longitude, Latitude:</TH>
          <TD><%=nf.format(post.getLon())%>, <%=nf.format(post.getLat())%></TD>
        </TR>
        <TR>
          <TH ALIGN=left VALIGN=top>Install Date:</TH>
          <TD><%=post.getInstallDate().toString()%></TD>
        </TR>
        <TR>
          <TH ALIGN=left VALIGN=top>Post Master:</TH>
          <TD>
            <TABLE BORDER=0>
              <TR>
                <TD><%=Utils.htmlEscape(postOwner.getFirstName())%> <%=Utils.htmlEscape(postOwner.getLastName())%></TD>
              </TR>
            </TABLE>
          </TD>
        </TR>

<%
if (Post.dbIsValidPostId(post.getPostId(), person.getPersonId())) {
%>

        <TR>
          <TD COLSPAN="2">As the owner of this post, you can click <A HREF="/managePost.jsp?postId=<%=post.getPostId()%>">here</A> to update this post or add more pictures of the post.</TD>
        </TR>

<%
}
else if (Post.dbIsValidPostId(post.getPostId()) && person.getAdmin() == true) {
%>

        <TR>
          <TD COLSPAN="2">As an administrator, you can click <A HREF="/managePost.jsp?postId=<%=post.getPostId()%>">here</A> to update this post or add more pictures of the post.</TD>
        </TR>

<%
}
%>

      </TABLE>
    </TD>
  </TR>

</TABLE>

</DIV> <!-- end container -->

<%@ include file="/includes/footer.jsp" %>
</BODY>
</HTML>
