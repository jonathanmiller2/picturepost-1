<%@ include file="/includes/common.jsp" %>
<%
  int postId = wu.param_int("postId", 0);
  if (postId > 0) {
    wu.redirect("/post.jsp?postId=" + postId);
  } else {
    wu.redirect("/news.jsp");
  }
%>
