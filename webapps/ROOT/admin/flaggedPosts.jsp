<%@ page import="edu.unh.sr.picturepost.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>

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

<%@ page import="org.apache.commons.fileupload.*" %>
<%
//Handle form submission.
Vector<Integer> selectedValues = new Vector<Integer>();

Vector<String> error = new Vector<String>();
%>

<%
//Did the user click any unflag or delete links?
String unflagId = Utils.cleanup(request.getParameter("unflagId"));
String deleteId = Utils.cleanup(request.getParameter("deleteId"));

String del = Utils.cleanup(request.getParameter("deleteIds"));
String unflag = Utils.cleanup(request.getParameter("unflagIds"));
if (!del.equals("") || !unflag.equals("")) {
	int num = Integer.parseInt(Utils.cleanup(request.getParameter("num")));
	error.add("num: "+num);
	error.add("unflag: "+unflag);
	error.add("del: "+del);
	if (num == 0)
		error.add("Please select some picture sets.");
	else {
		for (int i=0; i<num; i++) {
			error.add("i: "+i);
			selectedValues.add(Integer.parseInt(Utils.cleanup(request.getParameter("setId"+i))));
		}
	}
}
%>

<%
String[] orientations = {"N", "NE", "E", "SE", "S", "SW", "W", "NW", "UP" };

Vector<PictureSet> list = PictureSet.dbGetFlaggedPostRecords();

int id = 0;
Post post = new Post();

if (!unflagId.equals("") || (!selectedValues.isEmpty() && !unflag.equals(""))) {
    try {
    	if (!unflagId.equals(""))
        	selectedValues.add(Integer.parseInt(unflagId));
    	for (int i = 0; i < selectedValues.size(); i++) {
	        if (!PictureSet.dbIsValidPictureSetId(selectedValues.get(i), post.getPostId())) {
	            Log.writeLog("ERROR, " + request.getRequestURI() + ": pictureSetId " + selectedValues.get(i) + " does not belong to post " + post.getPostId());
	            error.add("An error occured while processing your request.");
	        }
	        PictureSet pictureSet = new PictureSet(selectedValues.get(i));
	        pictureSet.setFlagged(false);
	        if (!pictureSet.dbUpdate()) {
	            Log.writeLog("ERROR, " + request.getRequestURI() + ": Could not clear flag field.");
	            error.add("An error occured while processing your request.");
	        }
	    }
        response.sendRedirect("/admin/flaggedPosts.jsp");
        return;
    }
    catch (Exception e) { }
}
else if (!deleteId.equals("") || (!selectedValues.isEmpty() && !del.equals(""))) {
    try {
    	if (!deleteId.equals(""))
        	selectedValues.add(Integer.parseInt(deleteId));
    	for (int i = 0; i < selectedValues.size(); i++) {
	        if (!PictureSet.dbIsValidPictureSetId(selectedValues.get(i), post.getPostId())) {
	            Log.writeLog("ERROR, " + request.getRequestURI() + ": pictureSetId " + selectedValues.get(i) + " does not belong to post " + post.getPostId());
	            error.add("An error occured while processing your request.");
	        }
	        PictureSet pictureSet = new PictureSet(selectedValues.get(i));
	        if (!pictureSet.dbDelete()) {
	            Log.writeLog("ERROR, " + request.getRequestURI() + ": Could not delete PictureSet.");
	            error.add("An error occured while processing your request.");
	        }
	    }
        response.sendRedirect("/admin/flaggedPosts.jsp");
        return;
    }
    catch (Exception e) { }
}
%>

<%@ include file="/includes/doctype.jsp" %>
<HTML>
<HEAD>

<script>
	function actionSelected(action) {
		var sel=document.getElementsByName("selected");
		var num=0;
		var str="";
		for (var i=0; i<sel.length; i++) {
			if (sel[i].checked) {
				str=str+"&setId"+num+"="+sel[i].value;
				num++;
			}
		}
		var newurl="/admin/flaggedPosts.jsp?"+action+"Ids=1"+str+"&num="+num;
		window.location.href=newurl;
	}
</script>

<TITLE>Picture Post: Manage PictureSets</TITLE>
<LINK REL="stylesheet" TYPE="text/css" HREF="/css/picturepost.css">
</HEAD>

<BODY>
<%@ include file="/includes/header.jsp" %>

<DIV id="container" style="padding-left:10px; border:0; width: 1200px;"> <!-- start container -->

<%
if (!error.isEmpty()) {
%>

  <SPAN CLASS="errorColor"><B><%=Utils.join(error, "<BR>")%></B></SPAN><BR>

<%
}
%>

<%
if (list.size() == 0) {
%>

  <DIV ALIGN="center">
  Currently there are no flagged picture sets.
  </DIV>

<%
}
else {
%>
	<DIV ALIGN="center">All flagged posts</DIV>
  <BUTTON ONCLICK="actionSelected('delete')">Delete Selected</BUTTON>
  <BUTTON ONCLICK="actionSelected('unflag')">Unflag Selected</BUTTON>
  <FORM METHOD="post" ACTION="<%=request.getRequestURI()%>">
  <BR>

  <TABLE BORDER="1" CELLPADDING="0" CELLSPACING="0">
    <TR>
      <TH ALIGN="center">  </TH>
      <TH ALIGN="center">Post ID</TH>
      <TH WIDTH="80" ALIGN="center">N</TH>
      <TH WIDTH="80" ALIGN="center">NE</TH>
      <TH WIDTH="80" ALIGN="center">E</TH>
      <TH WIDTH="80" ALIGN="center">SE</TH>
      <TH WIDTH="80" ALIGN="center">S</TH>
      <TH WIDTH="80" ALIGN="center">SW</TH>
      <TH WIDTH="80" ALIGN="center">W</TH>
      <TH WIDTH="80" ALIGN="center">NW</TH>
      <TH WIDTH="80" ALIGN="center">UP</TH>
      <TH ALIGN="center">Local Date/Time</TH>
      <TH ALIGN="center">Upload Date/Time</TH>
      <TH ALIGN="center">Person</TH>
      <TH ALIGN="center">Status</TH>
      <TH ALIGN="center">Action</TH>
    </TR>

<%
    for (int ps = 0; ps < list.size(); ps++) {
        Vector<Picture> pictureRecords = list.get(ps).dbGetPictureRecords();
        post = new Post(list.get(ps).getPostId());
        Person person = new Person(list.get(ps).getPersonId());
%>
  	  <TR>
    	  <TD ALIGN="center" VALIGN="middle"> <INPUT TYPE='checkbox' NAME="selected" VALUE=<%=list.get(ps).getPictureSetId()%>></TD>
    	  <TD ALIGN="center" VALIGN="middle"><%=list.get(ps).getPostId()%></TD>
<%
        for (int i = 0; i < orientations.length; i++) {
            if (PictureSet.pictureRecordExists(pictureRecords, orientations[i])) {
                int pictureId = PictureSet.getPictureRecord(pictureRecords, orientations[i]).getPictureId();
%>
      			<TD WIDTH="80"><IMG ID="picture_<%=String.valueOf(pictureId)%>" SRC="/images/pictures/<%=post.getPostDir()%>/<%=PictureSet.getPictureRecord(pictureRecords, orientations[i]).getImageFileThumb()%>" ALT="<%=Utils.htmlEscape(post.getName())%>, <%=list.get(ps).getPictureSetTimestamp()%>, <%=orientations[i]%>" STYLE="border: 2px solid black;"></TD>
<%
            }
            else {
%>
      <TD><BR></TD>
<%
            }
        }
%>

      <TD><SPAN CLASS="smallText"><LABEL FOR="referencePictureSetId_<%=String.valueOf(list.get(ps).getPictureSetId())%>"><%=list.get(ps).getPictureSetTimestamp()%></LABEL></SPAN></TD>
      <TD><SPAN CLASS="smallText"><%=list.get(ps).getRecordTimestamp()%></SPAN></TD>
      <TD><SPAN CLASS="smallText"><%=person.getFirstName()%> <%=person.getLastName()%></SPAN></TD>
      <TD>
        <SPAN CLASS=smallText>
          <%=(list.get(ps).getReady() == true) ? "<SPAN STYLE=\"color: green;\">Ready</SPAN>" : "<SPAN STYLE=\"color: red;\">Not_Ready</SPAN>"%>
          <%=(list.get(ps).getFlagged() == true) ? "<SPAN STYLE=\"color: red;\">Flagged</SPAN>" : ""%>
        </SPAN>
      </TD>
      <TD>
        <SPAN CLASS=smallText>
<%
        if (list.get(ps).getFlagged() == true) {
%>
          <A HREF="<%=request.getRequestURI()%>?unflagId=<%=list.get(ps).getPictureSetId()%>">unflag</A>
<%
        }
%>
          <A HREF="<%=request.getRequestURI()%>?deleteId=<%=list.get(ps).getPictureSetId()%>">delete</A>
        </SPAN>
      </TD>
    </TR>
<%
    }
%>
  </TABLE>
  </FORM>

<%
}
%>

</DIV> <!-- end container -->

<%@ include file="/includes/footer.jsp" %>
</BODY>
</HTML>
