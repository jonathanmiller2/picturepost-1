<%@ include file="/includes/common.jsp" %>
<%@ include file="/includes/header.jsp" %>

<div class=clearfix id=topbar>
  <h1>Contact Us</h1>
</div>

<div class=well style='max-width: 800px; margin:auto;'>
<p>You can reach us by <a href='mailto:<%=WebUtil.esc(Config.get("SUPPORT_EMAIL"))%>'>email</a> or by phone at <%=Config.get("SUPPORT_PHONE")%>.

<p>
Please feel free to ask for help -- we know that websites may be hard to figure out.
<p>Please let us know how we can do better!
</div>
  
<%@ include file="/includes/footer.jsp" %>
