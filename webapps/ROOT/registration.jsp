<%@ include file="/includes/common.jsp" %>

<%

// if we are currently logged in, logout
if (sessionuser.isLoggedIn()) {
  sessionuser.logout();
  sessionuser = Person.getInstance(session);
}

// did user submit form
if ("submit".equals(wu.param("act"))) {
  String errmsg = null;
  
  String[] required = { "username", "email", "fname", "lname", "tos", "pass1", "pass2" };
  for (String f : required) {
    if ("".equals(wu.param(f))) {
      wu.reload("Please complete all required fields.");
      return;
    }
  }
  
  if (Person.isUsernameTaken(wu.param("username"))) {
    wu.reload("Sorry, this username is already in use.");
    return;
  }

  if (Person.dbIsValidEmail(wu.param("email"))) {
    wu.reload("An account with this email already exists.");
    return;
  }

  if (! wu.param("pass1").equals(wu.param("pass2"))) {
    wu.reload("Sorry, passwords do not match.");
    return;
  }   

  if (! wu.param("tos").equals("1")) {
    wu.reload("Please agree to the terms of service.");
    return;
  }
  
  try {
    ReCaptcha.verify(request);
  }
  catch (Exception e) {
    wu.reload("Could not verify that you are not a bot. Please try again.");
    return;
  }
  
  // if we passed all validation, save record
  sessionuser.setEmail(wu.param("email"));
  sessionuser.setUsername(wu.param("username"));
  sessionuser.setFirstName(wu.param("fname"));
  sessionuser.setLastName(wu.param("lname"));
  sessionuser.setSignupTimestamp(Utils.getCurrentTimestamp());
  String passwordSalt = Utils.generateSalt();
  String encryptedPassword = Utils.digest(wu.param("pass1"), passwordSalt);
  sessionuser.setPasswordSalt(passwordSalt);
  sessionuser.setEncryptedPassword(encryptedPassword);
  sessionuser.setConfirmed(true);
  sessionuser.dbSetPersonId();
  if (! sessionuser.dbInsert()) {
    Log.writeLog("ERROR: " + request.getRequestURI() + ", INSERT failed.");
    wu.reload("An error occured while processing your registration.");
    return;
  }

  // send welcome email
  Log.sendEmail(
    Config.get("SUPPORT_EMAIL"),
    sessionuser.getEmail(),
    "Welcome to Picture Post!",
    "Welcome to Picture Post!\n\n" + 
    "Here's some links to get you started.\n" +
    "Login: "+ Config.get("URL") + "/login.jsp\n" +
    "Find a Post Near You: "+ Config.get("URL") + "/map.jsp\n" +
    "Latest News: "+ Config.get("URL") + "/news.jsp\n\n" +
    "If you need help, please contact " + Config.get("SUPPORT_EMAIL") + ".\n\n" +
    "Thanks for being a citizen scientist!");

  sessionuser.login(sessionuser.getPersonId());
  wu.addNotificationSuccess("account created");
  wu.redirectPostLogin();
  return;
}
%>
<%@ include file="/includes/header.jsp" %>

<div align=center>
  <h1 style='display:inline-block;'>Create Account</h1>
</div>

<%=wu.popNotifications()%>

<div class="panel panel-default" style='max-width:600px; margin: auto;'>
  <form method=post role="form" id=loginform class="panel-body">
    <small class=pull-right>(* required field)</small>

    <p>
    <label>* First Name
      <input type=text class="form-control" name=fname required autofocus value='<%=wu.esc(wu.param("fname"))%>'>
    </label>

    <p>
    <label>* Last Name
      <input type=text class="form-control" name=lname required value='<%=wu.esc(wu.param("fname"))%>'>
    </label>

    <p>
    <label>* Email
      <input type=email class="form-control" name=email required value='<%=wu.esc(wu.param("email"))%>'>
    </label>

    <p>
    <label>* Username
      <input type=text class="form-control" name=username required value='<%=wu.esc(wu.param("username"))%>'>
    </label>

    <p>
    <label>* Password
      <input class="form-control" type=password name=pass1 required>
    </label>

    <p>
    <label>* Retype Password
      <input class="form-control" type=password name=pass2 required>
    </label>

    <p>
    <label>
      <input type=checkbox name=tos value=1 required<%="1".equals(wu.param("tos"))?" checked":""%>>
      I agree to the <a href="/termsofservice.jsp" target=_blank>Terms Of Service</a>.
    </label>

    <%= ReCaptcha.getWidgetHtml() %>

    <p style='margin-top:1em;'>
    <a href=/login.jsp class='btn btn-default' tabindex=3>cancel</a>
    <button type=submit name=act value=submit class='btn btn-primary' tabindex=3>submit</button>

  </form>
</div>
<%@ include file="/includes/footer.jsp" %>
