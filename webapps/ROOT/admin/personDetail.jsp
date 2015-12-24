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
Person person = new Person();
int personId = 0;
try {
    personId = Integer.parseInt(Utils.cleanup(request.getParameter("personId")));
}
catch (Exception e) { }
if (!Person.dbIsValidPersonId(personId)) {
    error.add("Invalid personId.");
}
else {
    person = new Person(personId);
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
    <TH ALIGN="right">person_id: </TH>
    <TD><%=String.valueOf(person.getPersonId())%></TD>
  </TR>
  <TR>
    <TH ALIGN="right">email: </TH>
    <TD><%=person.getEmail()%></TD>
  </TR>
  <TR>
    <TH ALIGN="right">first_name: </TH>
    <TD><%=person.getFirstName()%></TD>
  </TR>
  <TR>
    <TH ALIGN="right">last_name: </TH>
    <TD><%=person.getLastName()%></TD>
  </TR>
  <TR>
    <TH ALIGN="right">phone: </TH>
    <TD><%=person.getPhone()%></TD>
  </TR>
  <TR>
    <TH ALIGN="right">mobile_phone: </TH>
    <TD><%=person.getMobilePhone()%></TD>
  </TR>
  <TR>
    <TH ALIGN="right">signup_timestamp: </TH>
    <TD><%=String.valueOf(person.getSignupTimestamp())%></TD>
  </TR>
  <TR>
    <TH ALIGN="right">admin: </TH>
    <TD><%=String.valueOf(person.getAdmin())%></TD>
  </TR>
  <TR>
    <TH ALIGN="right">confirmation_key: </TH>
    <TD><%=person.getConfirmationKey()%></TD>
  </TR>
  <TR>
    <TH ALIGN="right">confirmed: </TH>
    <TD><%=String.valueOf(person.getConfirmed())%></TD>
  </TR>
</TABLE>

<%
}
%>

</DIV> <!-- end container -->
</BODY>
</HTML>
