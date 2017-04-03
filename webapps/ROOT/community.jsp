<%@ include file="/includes/common.jsp" %>
<%@ include file="/includes/header.jsp" %>

<div align=center>
  <h1 style='display:inline-block;'>Picture Post Community Page</h1>
</div>

<%=wu.popNotifications()%>

<style>
#helppagecontent ul {
  padding: 0 0 0 20px;
}
#helppagecontent li + li {
  margin-top: 10px;
}
#helppagecontent img {
  max-width: 100%;
}
</style>


<div class="container" id=helppagecontent>
  <div class="row">
    <div class="col-md-4">

        <ul>
          <li><a href="http://panopicturepost.tumblr.com" title="tumblr blog of panoramas">Tumblr Blog - Last Week in Panoramas</a></li>
          <Li><A href="gallery-newsletters.jsp" title="newsletters">Newsletters</A>
         <Li><A href="gallery-media.jsp" title="media archive">Blogs, Popular Articles, Research Articles</A>
        <Li><A href="gallery-downloadables.jsp" title="Materials for Download">Downloadable Picture Post Logos, Promotional Materials, Brochures</A>
         <li><A href="gallery-posttypes.jsp" title="Types of Picture Posts and Informational Signs">Gallery of Post Designs and Informational Signs</A>
          </ul>
 </div>
 
    <div class="col-md-4">

        <ul>
          <Li><A href="stuffYouCanDo.jsp" title="stuffyoucando">Stuff I Can Do</A>
         <Li><A href="community-educators.jsp" title="educators">Projects for Educators</A>
         <Li><A href="help.jsp" title="help">Help!</A>
</div>
</div>

 
</DIV> <!-- end container -->

<%@ include file="/includes/footer.jsp" %>
</BODY>
</HTML>
