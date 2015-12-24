<%@ include file="/includes/common.jsp" %>
<%
// if we are currently logged in, logout
if (sessionuser.isLoggedIn()) {
  wu.redirect("/news.jsp");
  return; 
}

// Handle form submission.
if ("submit".equals(wu.param("act"))) {
  try {
    ReCaptcha.verify(request);
  }
  catch (Exception e) {
    wu.reload("Could not verify that you are not a bot. Please try again.");
    return;
  }

  int personId = Person.dbGetPersonIdFromEmail(wu.param("email"));

  if (! Person.dbIsValidPersonId(personId)) {
    wu.reload("Sorry, email not recognized.");
    return;
  }

  Person person = new Person(personId);
  String resetPasswordKey = Utils.generateRandomString(32);
  person.setResetPasswordKey(resetPasswordKey);
  person.setResetPasswordTimestamp(Utils.getCurrentTimestamp());
  if (! person.dbUpdate()) {
    wu.reload("Could not update record.");
    return;
  }

  String from = Config.get("SUPPORT_EMAIL");
  String to = person.getEmail();
  String subject = "PicturePost support";
  String body = "Please click on the link below to set your new PicturePost password.\n\n" + 
    Config.get("URL") + "/resetPassword.jsp?resetPasswordKey=" + resetPasswordKey;
  Log.sendEmail(from, to, subject, body);
  wu.addNotificationSuccess("An email has been sent to you with instructions on setting a new password.");
  wu.redirect("/index.jsp");
  return;
}
%>
<%@ include file="/includes/header.jsp" %>

<div class=clearfix id=topbar>
  <h1>Forgot Password</h1>
</div>

<%=wu.popNotifications()%>

<div class="panel panel-default" style='max-width:600px; margin: auto; background-color: #eee'>
  <form method=post role="form" id=loginform class="panel-body">
    <p>
    <label>Email <input autofocus class="form-control" required type=email name=email value='<%=wu.eparam("email")%>'></label>
    <%= ReCaptcha.getWidgetHtml() %>
    <p style='margin-top:1em;'>
    <a href=/login.jsp class='btn btn-default' tabindex=3>cancel</a>
    <button type=submit name=act value=submit class='btn btn-primary' tabindex=3>submit</button>
  </form>
</div>
<%@ include file="/includes/footer.jsp" %>
