<%@ include file="/includes/common.jsp" %>
<%@ include file="/includes/header.jsp" %>
<div class=row id=topbar>
  <button type=button class="btn btn-default pull-left" onclick='history.back(); return false;'><span class="glyphicon glyphicon-menu-left" aria-hidden="true"></span>
 back</button>
</div>
<%=wu.popNotifications()%>
<%@ include file="/includes/footer.jsp" %>
