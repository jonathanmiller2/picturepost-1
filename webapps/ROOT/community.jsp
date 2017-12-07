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
    <div class="col-md-6" style="font-size:small">
 

        <ul>
          <li><a href="https://www.instagram.com/dewpicpost/" title="instagram blog of panoramas">Instagram - we share your pics here!</a></li>
          <Li><A href="gallery-newsletters.jsp" title="newsletters">Newsletters</A>
         <Li><A href="gallery-media.jsp" title="media archive">Blogs, Popular Articles, Research Articles</A>
        <Li><A href="gallery-downloadables.jsp" title="Materials for Download">Downloadable Picture Post Logos, Promotional Materials, Brochures</A>
         </ul> 
</div> 
    <div class="col-md-6" style="font-size:small">
 
         <ul>
         <li><A href="gallery-posttypes.jsp" title="Types of Picture Posts and Informational Signs">Gallery of Post Designs and Informational Signs</A>
           <Li><A href="stuffYouCanDo.jsp" title="stuffyoucando">Stuff I Can Do</A>
         <Li><A href="community-educators.jsp" title="educators">Projects for Educators</A>
         <Li><A href="help.jsp" title="help">Help!</A>
         </ul>
 </div>
</div>

<hr>
  <div class="row">
  <h2 align="center">Birds of a Feather Groups</h2>
    <div class="col-md-3">
    <h3>For Educators</h3>
    <a href="resources/BOF-Educators1.pdf" target="_blank" title="pdf file with links to resources"><img src="images/BOF-Educators1.jpg" width="90%"  alt="thumbnail"  border="1px"></a>
    <li style="font-size:small"><strong>Using Pictures in Educational Settings, 07/12/17</strong><br>Conversation with John Pickle<p>Click on the image to get PDF file with links to recording & resources discussed.</p></li>
 </div>
  </div>
 
</DIV> <!-- end container -->

<%@ include file="/includes/footer.jsp" %>
</BODY>
</HTML>
