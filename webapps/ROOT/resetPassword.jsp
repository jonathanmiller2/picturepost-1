<%@ include file="/includes/common.jsp" %>
<%
if (sessionuser.isLoggedIn()) {
  sessionuser.logout();
}

// verify resetPasswordKey
int personId = Person.dbGetPersonIdFromResetPasswordKey(wu.param("resetPasswordKey"));
if (!Person.dbIsValidPersonId(personId)) {
  wu.addNotificationError("Reset password key is not longer valid. Please request another key.");
  wu.redirect("/forgotPassword.jsp");
  return;
}

// check token expiration
Person p = new Person(personId);
java.sql.Timestamp resetPasswordTimestamp = p.getResetPasswordTimestamp();
if (resetPasswordTimestamp == null ||
    Utils.getCurrentTimestamp().getTime() -
      resetPasswordTimestamp.getTime() > 1000 * 60 * 20) {
  wu.addNotificationError("Reset password key has expired. Please request another key.");
  wu.redirect("/forgotPassword.jsp");
  return;
}
  
// if user submited form
if ("submit".equals(wu.param("act"))) {
  String errmsg = null;
  String pw1 = wu.param("pw1");
  String pw2 = wu.param("pw2");
  if ("".equals(pw1) || ! pw1.equals(pw2)) {
    wu.reload("Invalid password. Try again.");
    return;
  }
  String passwordSalt = Utils.generateSalt();
  String encryptedPassword = Utils.digest(pw1, passwordSalt);
  p.setEncryptedPassword(encryptedPassword);
  p.setPasswordSalt(passwordSalt);
  p.setResetPasswordKey("");
  p.setResetPasswordTimestamp(null);
  if (p.dbUpdate()) {
    sessionuser.login(p.getPersonId());
    wu.addNotificationSuccess("Your password has been changed.");
    wu.redirect("/news.jsp");
    return;
  }
  wu.reload("could not update record");
  return;
}
%>
<%@ include file="/includes/header.jsp" %>
<div align=center>
  <h1>Reset Password</h1>
</div>

<%=wu.popNotifications()%>

<div class="panel panel-default" style='max-width:600px; margin: auto;'>
  <form method=post role="form" id=loginform class="panel-body">
    <input type=hidden name=resetPasswordKey value='<%=wu.eparam("resetPasswordKey")%>'>
    <p>
    <label>Enter New Password
    <br><input class=form-control type=password name=pw1>
    </label>
    <p>
    <label>Retype New Password 
    <br><input class=form-control type=password name=pw2>
    </label>
    <p>
    <button type=submit name=act value=submit class='btn btn-primary' tabindex=3>submit</button>
  </form>
</div>
<%@ include file="/includes/footer.jsp" %>
