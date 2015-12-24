<%@ page import="edu.unh.sr.picturepost.*" %>
<%@ page import="java.util.*" %>

<%@ include file="/includes/rememberMe.jsp" %>

<%
// Generate a Vector of all posts.
Vector<Person> personRecords = Person.dbGetPersonRecords();
%>

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

<%@ include file="/includes/doctype.jsp" %>
<HTML>
<HEAD>
<TITLE>Picture Post: Admin</TITLE>
<LINK REL="stylesheet" TYPE="text/css" HREF="/css/picturepost.css">
</HEAD>

<BODY>
<%@ include file="/includes/header.jsp" %>

<DIV id="container"> <!-- start container -->

<TABLE BORDER="1">
  <TR>
    <TH>Person Id</TH>
    <TH>First Name</TH>
    <TH>Last Name</TH>
    <TH>Username</TH>
    <TH>Email</TH>
    <TH>Phone</TH>
    <TH>Mobile Phone</TH>
    <TH>Signup Timestamp</TH>
    <TH>Confirmed</TH>
    <TH>Admin</TH>
  </TR>

<%
for (int p = 0; p < personRecords.size(); p++) {
    Person person = personRecords.get(p);
%>

  <TR>
    <TD><a href="/admin/personDetail.jsp?personId=<%=String.valueOf(person.getPersonId())%>"><%=String.valueOf(person.getPersonId())%></a></TD>
    <TD><%=person.getFirstName()%></TD>
    <TD><%=person.getLastName()%></TD>
    <TD><%=person.getUsername()%></TD>
    <TD><%=person.getEmail()%></TD>
    <TD><%=person.getPhone()%></TD>
    <TD><%=person.getMobilePhone()%></TD>
    <TD><%=person.getSignupTimestamp()%></TD>
    <TD><%=person.getConfirmed()%></TD>
    <TD><%=person.getAdmin()%></TD>
  </TR>

<%
}
%>

</TABLE>

</DIV> <!-- end container -->

<%@ include file="/includes/footer.jsp" %>
</BODY>
</HTML>
