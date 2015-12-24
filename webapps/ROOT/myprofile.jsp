<%@ include file="/includes/common.jsp" %>
<%

if (! sessionuser.isLoggedIn()) {
  wu.sendLogin();
  return;
}

// get user to edit
Person edituser = sessionuser;
if (sessionuser.getAdmin() && wu.param_int("id",0) > 0) {
  edituser = new Person(wu.param_int("id",0));
}

// save record?
if ("save".equals(wu.param("act"))) {
  edituser.setFirstName(wu.param("first_name")); 
  edituser.setLastName(wu.param("last_name")); 
  edituser.setEmail(wu.param("email")); 
  edituser.setUsername(wu.param("username")); 
  if (edituser.dbUpdate()) {
    wu.addNotificationSuccess("record saved");
    wu.redirect("/news.jsp");
    return;
  }
  wu.reload("could not save record");
  return;
}

// load form state if not already loaded
if (! wu.pagestate) {
  wu.setparam("first_name", edituser.getFirstName()); 
  wu.setparam("last_name", edituser.getLastName()); 
  wu.setparam("email", edituser.getEmail()); 
  wu.setparam("username", edituser.getUsername()); 
}
%>
<%@ include file="/includes/header.jsp" %>

<div align=center>
  <h1 style='display:inline-block;'>My Profile</h1>
</div>

<%=wu.popNotifications()%>

<div class="panel panel-default" style='max-width:600px; margin: auto;'>
  <form method=post role="form" id=loginform class="panel-body">

    <p>
    <label>First Name
      <input type=text class="form-control" name=first_name required autofocus value='<%=wu.eparam("first_name")%>'>
    </label>

    <p>
    <label>Last Name
      <br>
      <input type=text class="form-control" name=last_name required value='<%=wu.eparam("last_name")%>'>
    </label>

    <p>
    <label>Email
      <br>
      <input type=text class="form-control" name=email required value='<%=wu.eparam("email")%>'>
    </label>

    <p>
    <label>Username
      <br>
      <input type=text class="form-control" name=username required value='<%=wu.eparam("username")%>'>
    </label>

    <p>
    <a class="btn btn-default" href=/>Cancel</a>
    <button type=submit name=act value=save class='btn btn-primary' tabindex=3>Submit</button>
  </form>
</div>
<%@ include file="/includes/footer.jsp" %>
