<%@ include file="/includes/common.jsp" %>
<%
if (! sessionuser.isLoggedIn()) {
  wu.redirect("/login.jsp");
  return; 
}

Person edituser = (sessionuser.getAdmin() && wu.param_int("id",0) > 0) ? new Person(wu.param_int("id",0)) : sessionuser;

if ("submit".equals(wu.param("act"))) {
  String err = null;
  if ("".equals(wu.param("p1"))) {
    err = "Enter a password.";
  } else if (! wu.param("p1").equals(wu.param("p2"))) {
    err = "New passwords do not match. Try again.";
  } else if (! sessionuser.getAdmin() &&
      ! edituser.getEncryptedPassword().equals(Utils.digest(wu.param("p0"), edituser.getPasswordSalt()))) {
    err = "Invalid current password.";
  }

  if (err == null) {
    String passwordSalt = Utils.generateSalt();
    String encryptedPassword = Utils.digest(wu.param("p1"), passwordSalt);
    edituser.setPasswordSalt(passwordSalt);
    edituser.setEncryptedPassword(encryptedPassword);
    if (edituser.dbUpdate()) {
      wu.addNotificationSuccess("password updated");
      wu.redirect("/news.jsp");
    } else {
      err = "could not save record";
    }
  }

  if (err != null) {
    wu.reload(err);
  }

  return;
}
%>
<%@ include file="/includes/header.jsp" %>


<h1 align=center>Change Password</h1>

<%=wu.popNotifications()%>

<div class="panel panel-default" style='max-width:600px; margin: auto;'>
  <form method=post role="form" id=loginform class="panel-body">

    <% if (wu.param_int("id",0) > 0 && sessionuser.getAdmin()) { %>
    <input type=hidden name=id value="<%=wu.param_int("id",0)%>">
    <p>
    <strong>Updating password for: <%=WebUtil.esc(edituser.getPublicName())%></strong>
    <%} else {%>
      <label>current password<br><input class="form-control" required type=password name=p0></label>
    <%}%>

    <p>
    <label>new password<br><input class="form-control" required type=password name=p1></label>

    <p>
    <label>retype new password<br><input class="form-control" required type=password name=p2></label>

    <p>
    <a class="btn btn-default" href=/news.jsp>cancel</a>
    <button type=submit name=act value=submit class='btn btn-primary' tabindex=3>submit</button>
  </form>
</div>

<%@ include file="/includes/footer.jsp" %>
