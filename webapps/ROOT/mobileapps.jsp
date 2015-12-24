<%@ include file="/includes/common.jsp" %>
<%
if (! sessionuser.isLoggedIn()) {
  wu.sendLogin();
  return;
}

if ("savemobile".equals(wu.param("act"))) {
  sessionuser.setMobilePhone(wu.param("val"));
  sessionuser.dbUpdate();
  response.setContentType("text/plain");
  response.getWriter().write("OK");
  return;
}
%>
<%@ include file="/includes/header.jsp" %>


<div align=center>
  <a href="myaccount.jsp" class="btn btn-default pull-left"><span class="glyphicon glyphicon-menu-left" aria-hidden="true"></span> my account</a>

  <h1 style='display:inline-block;'>Mobile App</h1>
</div>

<%=wu.popNotifications()%>

<div id=devicealert class='alert alert-warning alert-dismissible' role='alert'><button type=button class=close data-dismiss=alert aria-label=Close><span aria-hidden=true>&times;</span></button>Currently the mobile app is only supported on Apple iOS (iPhone, iPad). If you are using another device, please use the web site.</div>

<div class=well style='max-width:600px;margin:auto;'>
  <p>
  <label>Enter your mobile phone number:
  <br>
  <input id=UserMobilePhone class="form-control" autofocus type=tel name=mobilephone placeholder='(###) ###-####' value="<%= WebUtil.esc(sessionuser.getMobilePhone()) %>">
  </label>

  <p>
  <a target=_blank href="https://itunes.apple.com/us/app/id849676550" type=button class="btn btn-primary">continue</a>
</div>

<script>
if (! hasNativeAppSupport()) {
  $("#devicealert").show();
}
$("#UserMobilePhone").change(function(){
  $.ajax({
    type: 'post',
    data: {
      act: 'savemobile',
      val: $.trim(this.value)
    }
  });
});
</script>

<%@ include file="/includes/footer.jsp" %>
