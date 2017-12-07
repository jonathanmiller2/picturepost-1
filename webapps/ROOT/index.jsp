<%@ include file="/includes/common.jsp" %>
<%
String sql = "SELECT q1.post_id, q1.name, q1.post_picture_id FROM ( SELECT post.post_id, post.name, post_picture.post_picture_id, random() RND FROM ( SELECT post_id, count(1) FROM picture_set WHERE ready=true AND flagged=false GROUP BY post_id HAVING COUNT(1) > 5) okpost JOIN post ON (okpost.post_id=post.post_id) JOIN post_picture ON (post.post_id=post_picture.post_id AND post_picture.seq_nbr=1) WHERE post.ready=true) q1 ORDER BY q1.RND LIMIT 50";

PreparedStatement stmt = wu.dbh().prepareStatement(sql);
ResultSet rs = stmt.executeQuery();
String picsJSON = WebUtil.dbJsonArray(rs).toString();
%>
<%@ include file="/includes/header.jsp" %>

<%=wu.popNotifications()%>

<div class="jumbotron">
  <div class="container">
    <div class="row">
      <div class="col-lg-7">
        <h1 id=aboutheader><img src=images/logo.png alt="picture post logo"><span>picture post</span></h1>
        <p>Picture Posts are installed at forests, parks, and schools - even your backyard. Each post guides visitors to photograph a location in nine orientations. Photos are dated, geotagged, uploaded, and shared on this site. Picture Post is a part of the <a href=about.jsp>Digital Earth Watch (DEW) network</a>. DEW supports environmental monitoring by everyone!
      </div>
      <div class="col-lg-5">
        <div id=piccontainer style='text-align:center; height:300px; overflow:hidden;'></div>
        <div id=piccaption style='padding: 10px; height:2em; text-align:center; overflow:hidden;'></div>
      </div> 
    </div>
  </div>
</div>

<script>
(function(){
  var pics = <%=picsJSON%>;
  if (pics.length==0) return;
  var i = 0, timer;
  function showNext() {
    clearTimeout(timer);
    if (i == pics.length) i = 0;
    $("#piccontainer").empty().append(
      $("<img class=shadow>").attr('src', "/images/pictures/post_"+pics[i][0]+"/post_picture_"+pics[i][2]+"_medium.jpg")
    );
    $("#piccaption").empty().append($("<a href=/post.jsp?postId="+pics[i][0]+" />").text(pics[i][1]));
    i++;
    timer = setTimeout(showNext, 10000);
  }
  showNext();

  $("#piccontainer").click(showNext);
})();
</script>




<div class="container">
  <div class="row">
    <div align=center>
      <h2>Introduction</h2>
      <div class=aspect-ratio>
        <iframe class='shadow' src="https://www.youtube.com/embed/0yQBVJSpzBM" frameborder="0" allowfullscreen></iframe>
      </div>
    </div>
  </div>

  <div class="row">
    <div class="col-md-4">
      <h2>Find</h2>
      <p class=clearfix>
        <a href="/map.jsp">
          <img class='shadow pull-left' src=/images/map.png style='margin:0 16px 16px 0;' alt="map of picturepost locations">
        </a>
        Locate <a href='/nearme.jsp'>posts near me</a>, or simply find <a href="/map.jsp">posts on a map</a>. After finding a post, you can view historical photos and share your own picture sets with the community.<BR>
        
      <p><a class="btn btn-default" href="/map.jsp" role="button">View details</a></p>
    </div>

    <div class="col-md-4">
      <h2>News</h2>
      <p class=clearfix>
        <a href='/news.jsp'>
         <img class='shadow pull-left' src=/images/panoramic.jpg style='margin:0 16px 16px 0;' alt="aligning the camera">
        </a>
        View the latest articles, uploaded picture sets, and new post installations. Search the picturepost digital archives by keyword. <a href=/newslettersignup.jsp>Sign up for the monthly newsletter.</a> <a href=http://panopicturepost.tumblr.com/ target=_blank>Follow us on Tumblr.</a>
      <p><a class="btn btn-default" href="/news.jsp" role="button">View details</a></p> 
    </div>

    <div class="col-md-4">
      <h2>Join In!</h2>
      <p class=clearfix>
        <a href='/buy.jsp'>
          <img class='shadow pull-left' src=images/plasticpost_install200.jpg style='margin:0 16px 16px 0;' alt="plastic post install">
        </a>
         <a href=/help.jsp>Plan</a> a Picture Post project.
<a href=/buy.jsp>Buy</a> or <a href=/build.jsp>build</a> your own picture post. After the picture post is installed, <a href=/help_addpost.jsp>register</a> your post so the picture post community can visit and upload picture sets at your post.    </div>
<div align=center>
  <h4>We host 100,000 pictures and counting.</h4><p>Help us keep our photo archive freely available to everyone!</p>
  <a class="btn btn-primary" href=https://picturepost.unh.edu/community-donate.jsp>Give</a>
</div>

  </div>
</div>



<%@ include file="/includes/footer.jsp" %>
