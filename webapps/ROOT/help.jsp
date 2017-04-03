<%@ include file="/includes/common.jsp" %>
<%@ include file="/includes/header.jsp" %>

<div align=center>
  <h1 style='display:inline-block;'>Picture Post Help</h1>
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
      <h3>Plan My Project</h3>
      <p class=clearfix>
        <img class='shadow pull-left' src=/images/USM_031710_b.jpg style='margin:0 16px 16px 0;' alt="plan project pic">
        <ul>
        <li><a href="help_tips.jsp" title="Plan your project tips">Tips on placing a new picture post, deciding what to monitor, and how often.</a>
        <li><a href="/images/DigitalCameraToolv6.pdf" title="Primer on taking measurements in pictures">Guide to align a post for taking measurements (PDF).</a>
        </ul>
     </div>

    <div class="col-md-4">
      <h3>Buy, Build, Make a Sign, Go!</h3>
      <p class=clearfix>
        <img class='shadow pull-left' src=/images/Wells_postdig3.jpg style='margin:0 16px 16px 0;' alt="digging a post">
        <ul>
         <Li><A href="buy.jsp" title="Buy or build your post">Purchase recycled plastic post tops</A>
         <Li><A href="build.jsp" title="Buy or build your post">Instructions for building and installing posts</A>
         <Li><A href="gallery-posttypes.jsp" title="Gallery of post & sign designs">Gallery of posts and signs - get inspired!</A>
          <Li><A href="post-signage.jsp" title="Buy or build your post">Make a sign; get our logo</A>
        </ul>
    </div>

    <div class="col-md-4">
      <h3>Register a Post: My Responsibilities</h3>
      <p class=clearfix>
        <img class='shadow pull-left' src=/images/EarthDaythumb2013.png style='margin:0 16px 16px 0;' alt="picturepost network">
        <p><a class="btn btn-default" href="/help_addpost.jsp" role="button">View details</a></p>
    </div>
</div>

  <div class="row">
    <div class="col-md-4">
      <h3><span class="h3blue">Tips for Taking Good Pictures</span></h3>
      <p class=clearfix>
        <img class='shadow pull-left' src=/images/picsonpost.png style='margin:0 16px 16px 0;' alt="take good pictures">
        <ul>
         <Li><A href="/taking_photos.jsp" title="taking pictures">Tips on how and when to take pictures</A>
         <Li><A href="/picture_scale.jsp" title="Add a scale to your pictures">How to add a scale to pictures for making measurements</A>        </ul>
     </div>

    <div class="col-md-4">
      <h3><span class="h3blue">How Can I Participate?</span></h3>
      <p class=clearfix>
        <img class='shadow pull-left' src=/images/Wells_postdig1.jpg style='margin:0 16px 16px 0;' alt="digging a post">
       <p><a class="btn btn-default" href="/stuffYouCanDo.jsp" role="button">View details</a></p>
     </div>
  
   <div class="col-md-4">
      <h3><span class="h3blue">Community Resources</span></h3>
      <p class=clearfix>
        <img class='shadow pull-left' src=/images/ppostflyerpic300.jpg style='margin:0 16px 16px 0;' alt="resource page">
      <p><a class="btn btn-default" href="community.jsp" role="button">View details</a></p>
    </div>
   
     
  </div>
</div>



</DIV> <!-- end container -->

<%@ include file="/includes/footer.jsp" %>
</BODY>
</HTML>
