<%@ page import="edu.unh.sr.picturepost.*" %>
<%@ page import="java.util.*" %>

<%@ include file="/includes/rememberMe.jsp" %>

<%
String returnPage = request.getParameter("returnPage"); if (returnPage == null || returnPage.equals("")) returnPage = "/index.jsp";
%>

<%
// Make sure the user is already logged in.
if (!Person.getInstance(session).isLoggedIn()) {
    response.sendRedirect("/login.jsp?returnPage=" + request.getRequestURI());
    return;
}
else if (!Person.getInstance(session).getAdmin()) {
    response.sendRedirect("../index.jsp");
    return;
}
%>

<%
Vector<String> error = new Vector<String>();
Post post = new Post();
int postId = 0;
try {
    postId = Integer.parseInt(Utils.cleanup(request.getParameter("postId")));
}
catch (Exception e) { }
if (!Post.dbIsValidPostId(postId)) {
    error.add("Invalid postId.");
}
else {
    post = new Post(postId);
}
%>

<%@ include file="/includes/doctype.jsp" %>
<HTML>
<HEAD>
<TITLE>Picture Post: Admin</TITLE>
<LINK REL="stylesheet" TYPE="text/css" HREF="/css/picturepost.css">
</HEAD>

<BODY>
<DIV id="container"> <!-- start container -->

<%
if (!error.isEmpty()) {
%>

<%=Utils.join(error, "<BR>")%>

<%
}
else {
%>

<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0">
  <TR>
    <TH ALIGN="right">post_id: </TH>
    <TD><%=String.valueOf(post.getPostId())%></TD>
  </TR>
  <TR>
    <TH ALIGN="right">person_id: </TH>
    <TD><%=String.valueOf(post.getPersonId())%></TD>
  </TR>
  <TR>
    <TH ALIGN="right">name: </TH>
    <TD><%=post.getName()%></TD>
  </TR>
  <TR>
    <TH ALIGN="right">description: </TH>
    <TD><%=post.getDescription()%></TD>
  </TR>
  <TR>
    <TH ALIGN="right">install_date: </TH>
    <TD><%=String.valueOf(post.getInstallDate())%></TD>
  </TR>
  <TR>
    <TH ALIGN="right">reference_picture_set_id: </TH>
    <TD><%=String.valueOf(post.getReferencePictureSetId())%></TD>
  </TR>
  <TR>
    <TH ALIGN="right">record_timestamp: </TH>
    <TD><%=String.valueOf(post.getRecordTimestamp())%></TD>
  </TR>
  <TR>
    <TH ALIGN="right">ready: </TH>
    <TD><%=String.valueOf(post.getReady())%></TD>
  </TR>
</TABLE>

<%
}
%>

</DIV> <!-- end container -->
</BODY>
</HTML>
