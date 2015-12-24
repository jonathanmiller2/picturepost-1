<%@ include file="/includes/common.jsp" %>
<%@ include file="/includes/header.jsp" %>

<div id=topbar class=clearfix>
  <h1>Build a Post</h1>
</div>

<div class=well>
     A Picture Post is an 8-sided platform for taking repeat photographs of the entire landscape and an Up picture of the sky. Check out <a href="/buy.jsp" name="link to purchase plastic lumber page">pre-made post tops that you can buy</a>, or use this page to get ideas for building your own post from scratch.
</div>

<style>
#recipes a {
  display: block; 
  cursor: pointer;
  padding: 30px;
  clear: both;
  overflow: auto;
}
#recipes a + a {
  border-top: 1px solid #ddd;
}
#recipes a:hover {
  background-color: #eee;
}
#recipes img {
  background-color: white;
  float: left;
  margin: 0 20px 20px 20px;
  width:200px;
}
</style>
<div id=recipes>
<a href="build_perm1.jsp">
  <img class=shadow src="/images/post-orig.png" alt="link to build instructions">
  Instructions to build a permanent post, by John Pickle.
</a>

<a href="build_mobile1.jsp">
  <img class=shadow src="/images/post-paulmobile.png" alt="link to build instructions">
  Instructions to build a mobile post top, by Paul Alaback.
</a>

<a href="build_mobile2.jsp">
  <img class=shadow src="/images/vlad-postpic205.jpg" alt="link to build instructions">
  Instructions to build a mobile post platform, by Vladimir Sanchez.
</a>

<a href="/resources/pictureposttemplate9in.pdf" target="_blank">
  <img src="/images/pictureposttemplate.png" alt="post top diagram">
  Do It Yourself Template.
</a>

<a href="/resources/Posttop-multi-instructions.pdf" target="_blank">
  <img src="/images/pictureposttemplatemulti.png" alt="post top diagram">
Do It Yourself Template. A post top with multiple picture angles.
</a>
</div>

<%@ include file="/includes/footer.jsp" %>
