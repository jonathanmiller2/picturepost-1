<%@ include file="/includes/common.jsp" %>

<%
if (! sessionuser.getAdmin()) {
  wu.sendLogin();
  return;
}

if ("setadmin".equals(wu.param("act"))) {
  String val = wu.param("val");
  boolean isAdmin = "1".equals(wu.param("isAdmin")) ? true : false;
  String msg = "Error";
  if (! "".equals(val)) {
    int personId = wu.q()
      .select("person_id")
      .from("person")
      .where("email=? OR username=?")
      .bind(val).bind(val)
      .append("LIMIT 1")
      .getInt();
    if (personId > 0) {
      Person p = new Person(personId);
      if (p != null) {
        p.setAdmin(isAdmin);
        if (p.dbUpdate()) {
          msg = "User updated successfully";
        }
      }
    }
  }
  wu.reload(msg);
  return;
}


if ("loginas".equals(wu.param("act"))) {
  String val = wu.param("val");
  String msg = "Error";
  if ("".equals(val)) {
    wu.reload(msg);
  } else {
    int personId = wu.q()
      .select("person_id")
      .from("person")
      .where("email=? OR username=?")
      .bind(val).bind(val)
      .append("LIMIT 1")
      .getInt();
    if (personId > 0) {
      Person p = new Person();
      p.login(personId);
      session.setAttribute("person", p);
      wu.addNotificationSuccess("logged in as user successfully");
      wu.redirect("/myaccount.jsp");
    } else {
      wu.reload("Could not find user.");
    }
  }
  return;
}
%>
<%@ include file="/includes/header.jsp" %>

<div class=clearfix id=topbar>
  <a href="../myaccount.jsp" class="btn btn-default pull-left"><span class="glyphicon glyphicon-menu-left" aria-hidden="true"></span> my account</a>
  <h1>Admin Functions</h1>
</div>

<%=wu.popNotifications()%>

<style>
h2 {
  margin-top: 0;
}
</style>

<div class=well>
  <h2>Make/Demote Admin</h2>
  <form method=post>
    <label>
      <input type=text name=val class=form-control placeholder='username OR email'>
    </label>
    <p>
    <label class="btn btn-default"><input type=radio name=isAdmin value=0 checked> demote</label>
    <label class="btn btn-default"><input type=radio name=isAdmin value=1> make</label>
    <p>
    <button type=submit name=act value=setadmin>submit</button>
  </form>
</div>

<div class=well>
  <h2>Login as User</h2>
  <form method=post>
    <label>
      <input type=text name=val class=form-control placeholder='username OR email'>
    </label>
    <p>
    <button type=submit name=act value=loginas>submit</button>
  </form>
</div>

<%@ include file="/includes/footer.jsp" %>
