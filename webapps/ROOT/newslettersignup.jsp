<%@ include file="/includes/common.jsp" %>
<%@ include file="/includes/header.jsp" %>

<div id=topbar class=clearfix>
  <h1>Newsletter Signup</h1>
</div>

<%=wu.popNotifications()%>

<div class="panel panel-default" style="max-width:600px;padding:20px; margin:auto;">

<form method="post" action="http://oi.vresp.com?fid=1e6a91020f" target="vr_optin_popup" onSubmit="window.open('http://www.verticalresponse.com', 'vr_optin_popup', 'scrollbars=yes,width=600,height=450' ); return true;">

<p>
<label>Email Address:
  <br><input class=form-control type=email required name="email_address" value="<%=WebUtil.esc(sessionuser.getEmail())%>">
</label>

<p>
<label>First Name:
  <br><input type=text name="first_name" class=form-control required value="<%=WebUtil.esc(sessionuser.getFirstName())%>">
</label>

<p>
<label>Last Name:
  <br><input type=text name="last_name" class=form-control required value="<%=WebUtil.esc(sessionuser.getLastName())%>">
</label>

<p>
<strong>Enter the letters shown: </strong>
<br>
<img id="vrCaptchaImage" src="https://img.verticalresponse.com/blank.gif" height="35" width="125">
<input size="10" name="captcha_guess" required class=form-control style="width:125px; display:inline-block;position:relative;top:2px;">

<input type=hidden id="vrCaptchaHash" name="captcha_hash" value="">
<script>hex_chars=Array('0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f');hash='';hash_length=20;for(h=0;h<hash_length;h++){hash=hash+hex_chars[Math.floor(16*Math.random())];}document.getElementById('vrCaptchaHash').value=hash;captcha_image_url='https://captcha.vresp.com/produce/'+hash;document.getElementById('vrCaptchaImage').src=captcha_image_url;</script>

<p>
<input class="btn btn-primary" type="submit" value="Join Now">

<hr>
<p><a title="Email Marketing by VerticalResponse" href="http://www.verticalresponse.com"><small>Email Marketing</a> by VerticalResponse</small></a>

</form>
</div>
<%@ include file="/includes/footer.jsp" %>
