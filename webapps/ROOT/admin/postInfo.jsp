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
// Sort by what? 
String sortBy = Utils.cleanup(request.getParameter("sortBy"));
if (!sortBy.equals("nameAsc") &&
    !sortBy.equals("nameDesc") &&
    !sortBy.equals("lastNameAsc") &&
    !sortBy.equals("lastNameDesc") &&
    !sortBy.equals("numPictureSetsAsc") &&
    !sortBy.equals("numPictureSetsDesc") &&
    !sortBy.equals("tStampMostRecentPictureSetAsc") &&
    !sortBy.equals("tStampMostRecentPictureSetDesc")) {
    sortBy = "nameAsc";
}

// Generate a Vector of Post records.
Vector<Post> postRecords = Post.dbGetPostRecords();

// Generate a Vector of PostInfo records.
Vector<PostInfo> postInfoRecords = new Vector<PostInfo>();
for (int i = 0; i < postRecords.size(); i++) {
    Person person = new Person(postRecords.get(i).getPersonId());

    PostInfo postInfo = new PostInfo();
    postInfo.setPostId(postRecords.get(i).getPostId());
    postInfo.setName(postRecords.get(i).getName());
    postInfo.setPersonId(postRecords.get(i).getPersonId());
    postInfo.setFirstName(person.getFirstName());
    postInfo.setLastName(person.getLastName());
    postInfo.setEmail(person.getEmail());
    postInfo.setNumPictureSets(postRecords.get(i).dbGetNumViewablePictureSetRecords());
    postInfo.setTStampMostRecentPictureSet(postRecords.get(i).dbGetDateMostRecentPictureSet());

    postInfoRecords.add(postInfo);
}

// Sort the PostInfo records.
if (sortBy.equals("nameAsc")) {
    Collections.sort(postInfoRecords, new PostInfoSortByNameAsc());
}
else if (sortBy.equals("nameDesc")) {
    Collections.sort(postInfoRecords, new PostInfoSortByNameDesc());
}
else if (sortBy.equals("lastNameAsc")) {
    Collections.sort(postInfoRecords, new PostInfoSortByLastNameAsc());
}
else if (sortBy.equals("lastNameDesc")) {
    Collections.sort(postInfoRecords, new PostInfoSortByLastNameDesc());
}
else if (sortBy.equals("numPictureSetsAsc")) {
    Collections.sort(postInfoRecords, new PostInfoSortByNumPictureSetsAsc());
}
else if (sortBy.equals("numPictureSetsDesc")) {
    Collections.sort(postInfoRecords, new PostInfoSortByNumPictureSetsDesc());
}
else if (sortBy.equals("tStampMostRecentPictureSetAsc")) {
    Collections.sort(postInfoRecords, new PostInfoSortByTStampMostRecentPictureSetAsc());
}
else if (sortBy.equals("tStampMostRecentPictureSetDesc")) {
    Collections.sort(postInfoRecords, new PostInfoSortByTStampMostRecentPictureSetDesc());
}

%>

<%@ include file="/includes/doctype.jsp" %>
<HTML>
<HEAD>
<TITLE>Picture Post: Admin</TITLE>
<LINK REL="stylesheet" TYPE="text/css" HREF="/css/picturepost.css">
<SCRIPT TYPE="text/javascript">
<!--

function postDetail(postId) {
    window.open("/admin/postDetail.jsp?postId=" + postId, "", "width=800,height=400,resizable,scrollbars")
}

function personDetail(personId) {
    window.open("/admin/personDetail.jsp?personId=" + personId, "", "width=800,height=400,resizable,scrollbars")
}

//-->
</SCRIPT>
</HEAD>

<BODY>
<%@ include file="/includes/header.jsp" %>

<DIV id="container"> <!-- start container -->

<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="1">
  <TR>
    <TH>Post Id</TH>
    <TH><A HREF="<%=request.getRequestURI()%>?sortBy=<%=(sortBy.equals("nameAsc")) ? "nameDesc" : "nameAsc"%>">Post Name</A></TH>
    <TH>Person Id</TH>
    <TH>First Name</TH>
    <TH><A HREF="<%=request.getRequestURI()%>?sortBy=<%=(sortBy.equals("lastNameAsc")) ? "lastNameDesc" : "lastNameAsc"%>">Last Name</A></TH>
    <TH>Email</TH>
    <TH><A HREF="<%=request.getRequestURI()%>?sortBy=<%=(sortBy.equals("numPictureSetsAsc")) ? "numPictureSetsDesc" : "numPictureSetsAsc"%>">Number of picture sets</A></TH>
    <TH><A HREF="<%=request.getRequestURI()%>?sortBy=<%=(sortBy.equals("tStampMostRecentPictureSetAsc")) ? "tStampMostRecentPictureSetDesc" : "tStampMostRecentPictureSetAsc"%>">Most Recent picture set</A></TH>
  </TR>

<%
long totalNumPictureSets = 0;
for (int i = 0; i < postInfoRecords.size(); i++) {
    totalNumPictureSets += postRecords.get(i).dbGetNumViewablePictureSetRecords();
    String postId = String.valueOf(postInfoRecords.get(i).getPostId());
%>

  <TR>
    <TD><A HREF="javascript:postDetail(<%=String.valueOf(postInfoRecords.get(i).getPostId())%>);"><%=postId%></A></TD>
    <TD><a href="/post.jsp?postId=<%=postId%>"><%=postInfoRecords.get(i).getName()%></a></TD>
    <TD><A HREF="javascript:personDetail(<%=String.valueOf(postInfoRecords.get(i).getPersonId())%>);"><%=String.valueOf(postInfoRecords.get(i).getPersonId())%></A></TD>
    <TD><%=postInfoRecords.get(i).getFirstName()%></TD>
    <TD><%=postInfoRecords.get(i).getLastName()%></TD>
    <TD><%=postInfoRecords.get(i).getEmail()%></TD>
    <TD><%=String.valueOf(postInfoRecords.get(i).getNumPictureSets())%></TD>
    <TD NOWRAP><%=(postInfoRecords.get(i).getTStampMostRecentPictureSet() != null) ? String.valueOf(postInfoRecords.get(i).getTStampMostRecentPictureSet()).substring(0, 10) : "<BR>"%></TD>
  </TR>

<%
}
%>

  <TR>
    <TD><BR></TD>
    <TD><BR></TD>
    <TD><BR></TD>
    <TD><BR></TD>
    <TD><BR></TD>
    <TD><BR></TD>
    <TH><%=String.valueOf(totalNumPictureSets)%></TH>
    <TD><BR></TD>

</TABLE>

</DIV> <!-- end container -->

<%@ include file="/includes/footer.jsp" %>
</BODY>
</HTML>
