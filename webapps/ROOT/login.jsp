<%@ include file="/includes/common.jsp" %>
<%

// if we are currently logged in, logout
if (sessionuser.isLoggedIn()) {
  sessionuser.logout();
  wu.forgetMe();
}

// if user logged in with facebook
if ("facebooklogin".equals(wu.param("act"))) {
  JSONObject dat = new JSONObject(wu.param("dat","{}"));
  String facebook_id = WebUtil.str(dat.get("id"));
  if (facebook_id.length() > 0) {
    String facebook_email = dat.has("email") ? WebUtil.str(dat.get("email")) : "";
    String facebook_name  = dat.has("name")  ? WebUtil.str(dat.get("name"))  : "";
    String sql = "SELECT person_id FROM person WHERE facebook_id=? OR UPPER(email)=UPPER(?) LIMIT 1";
    PreparedStatement stmt = wu.dbh().prepareStatement(sql);
    stmt.setString(1, facebook_id);
    stmt.setString(2, facebook_email);
    ResultSet rs = stmt.executeQuery();

    // if user exists
    if (rs.next()) {
      int person_id = rs.getInt(1);
      boolean updateDB = false;
      if (! "".equals(facebook_email) && "".equals(sessionuser.getEmail())) {
        sessionuser.setEmail(facebook_email);
        updateDB = true;
      }
      if ("".equals(sessionuser.getFacebookId())) {
        sessionuser.setFacebookId(facebook_id);
        updateDB = true;
      }
      if (updateDB) {
        sessionuser.dbUpdate();
      }
      sessionuser.login(person_id);
      wu.addNotificationSuccess("logged in with facebook successfully");
      wu.redirectPostLogin();
      return;
    }

    // else provision new facebook account
    else {
      sessionuser.dbSetPersonId();
      Pattern p = Pattern.compile("^(\\S+)\\s*(.*)$");
      Matcher m = p.matcher(facebook_name);
      if (m.find()) {
        sessionuser.setFirstName(WebUtil.str(m.group(1), "firstname"));
        sessionuser.setLastName(WebUtil.str(m.group(2), "lastname"));
      } else {
        sessionuser.setFirstName("firstname");
        sessionuser.setLastName("lastname");
      }
      sessionuser.setSignupTimestamp(Utils.getCurrentTimestamp());
      sessionuser.setUsername(sessionuser.getFirstName() + sessionuser.getPersonId());
      sessionuser.setEmail(facebook_email);
      sessionuser.setFacebookId(facebook_id);
      sessionuser.setEncryptedPassword("-");
      sessionuser.setPasswordSalt("-");
      sessionuser.setConfirmed(true);
      sessionuser.dbInsert();
      sessionuser.login(sessionuser.getPersonId());
      wu.addNotificationSuccess("login successful");
      wu.redirectPostLogin();
      return;
    }
  }

  if (! sessionuser.isLoggedIn()) {
    wu.reload("could not login with facebook");
    return;
  }
}

// if user is logging in using internal auth
else if ("internallogin".equals(wu.param("act"))) {
  sessionuser.login(wu.param("username"), wu.param("pass"));
  if (! sessionuser.isLoggedIn()) {
    wu.reload("invalid username/password");
    return;
  }
  wu.addNotificationSuccess("login successful");
  wu.redirectPostLogin();
  return;
}
%>
<%@ include file="/includes/header.jsp" %>

<h1 align=center>Login</h1>

<%=wu.popNotifications()%>

<div class="panel panel-default" style='max-width:600px; margin: auto; background-color: #eee'>
  <form method=post role="form" id=loginform class="panel-body">
    <input type=hidden name=act value=internallogin>
    <input type=hidden name=dat>

    <div class=pull-left>
    <p>
    <label>email or username
      <input type=text class="form-control" name=username required autofocus value='<%=wu.esc(wu.param("username"))%>'>
    </label>

    <p>
    <label>password
      <br>
      <input class="form-control" type=password name=pass required>
    </label>
    <p>
    <button type=submit class='btn btn-primary' tabindex=3>Submit</button>
    </div>

    <div class=pull-left style='margin:20px;'>
      <p><a href=/registration.jsp>Create Account</a>
      <p><a href=/forgotPassword.jsp>Forgot your password?</a>
    </div>
     

    <!--<hr style='border-color: #ddd; clear:both;'>
    <a id=Facebooklogin href=# class="btn btn-default btn-facebook"><img src=../images/facebookicon.png> Log In with Facebook</a> -->
  </form>
</div>

<script>
  var facebookinitialized=false;
  var facebookloginbut=false;
  var doFacebooklogin = function(){
    if (!(facebookinitialized && facebookloginbut)) return;

    FB.login(function(response) {
      if (response.status === 'connected') {
        FB.api('/me', function(dat) {
          var f = $('#loginform')[0];
          f.act.value = 'facebooklogin';
          f.dat.value = JSON.stringify(dat);
          f.submit();
        });
      }
    }, {scope: 'public_profile,email'});

/*
    FB.getLoginStatus(function(response) {
      console.log(['statusChangeCallback',response]);
      if (response.status === 'connected') {
        FB.api('/me', function(dat) {
          var f = $('#loginform')[0];
          f.act.value = 'facebooklogin';
          f.dat.value = JSON.stringify(dat);
          f.submit();
        });
      } else if (response.status === 'not_authorized') {
        //FB.login();
      } else {
        //console.log('not logged into facebook');
      }
    });
*/
  };
  $(document).on('facebookinit', function(){
    facebookinitialized=true;
    doFacebooklogin();
  });
  $("#Facebooklogin").click(function(){
    facebookloginbut=true;
    doFacebooklogin();
  });
</script>
<%@ include file="/includes/footer.jsp" %>
