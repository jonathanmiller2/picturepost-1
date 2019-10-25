<%@ include file="/includes/common.jsp" %>

<%
// make sure user is logged in
if (! sessionuser.isLoggedIn()) {
  wu.sendLogin();
  return;
}

Q b = wu.q();

// user's favorite posts
b.append("SELECT 'myfav', favorite_post.post_id::text, post.name FROM favorite_post JOIN post ON (favorite_post.post_id=post.post_id) WHERE favorite_post.person_id=?").bind(sessionuser.getPersonId());

// my picturesets that aren't ready
// only include picturesets with at least one uploaded picture (as requested by Annette)
b.append("UNION SELECT 'mynotreadypicset', picture_set.picture_set_id::text, CONCAT(post.name,' ',COALESCE(picture_set.annotation,'')) FROM picture_set JOIN post ON (picture_set.post_id=post.post_id) JOIN person ON (picture_set.person_id=person.person_id) WHERE picture_set.ready=false AND picture_set.person_id=? AND EXISTS (SELECT 1 FROM picture WHERE picture_set.picture_set_id=picture.picture_set_id)").bind(sessionuser.getPersonId());

// my pictureset count
b.append("UNION SELECT 'mypicsetcount', NULL, COUNT(1)::text FROM picture_set WHERE picture_set.person_id=?").bind(sessionuser.getPersonId());;

// my posts
b.append("UNION SELECT 'mypost', post.post_id::text, CONCAT(post.name, (CASE WHEN post.ready=false THEN ' (not ready)' ELSE '' END)) FROM post WHERE post.person_id=?").bind(sessionuser.getPersonId());

// admin entries
if (sessionuser.getAdmin()) {
  // flagged picturesets
  b.append("UNION SELECT 'flaggedpicset', CONCAT(picture_set.post_id,'-',picture_set.picture_set_id), CONCAT(post.name,' ',COALESCE(picture_set.annotation,''),' ',COALESCE(person.username, person.email, CONCAT(person.first_name,' ',person.last_name))) FROM picture_set JOIN post ON (picture_set.post_id=post.post_id) JOIN person ON (picture_set.person_id=person.person_id) WHERE picture_set.flagged=true");

  b.append("UNION SELECT 'totalusers', NULL, COUNT(1)::text FROM person");
}

b.append("ORDER BY 1, 3");

class Rec {
  String id;
  String label; 
}

List<Rec> myFavPosts = new ArrayList<Rec>();
List<Rec> myPicSetsNotReady = new ArrayList<Rec>();
List<Rec> myPosts = new ArrayList<Rec>();
List<Rec> flaggedPicSets = new ArrayList<Rec>();
Integer myPicsetCount = 0;
Integer totalUsers = 0;

while (b.fetch()) {
  String type = b.get();
  Rec rec = new Rec();
  rec.id = b.get();
  rec.label = b.get();
  if ("myfav".equals(type)) myFavPosts.add(rec);
  else if ("mynotreadypicset".equals(type)) myPicSetsNotReady.add(rec);
  else if ("mypost".equals(type)) myPosts.add(rec);
  else if ("flaggedpicset".equals(type)) flaggedPicSets.add(rec); 
  else if ("mypicsetcount".equals(type)) myPicsetCount = Integer.parseInt(rec.label);
  else if ("totalusers".equals(type)) totalUsers = Integer.parseInt(rec.label);
}

%>
<%@ include file="/includes/header.jsp" %>
<style>

#dashboard > a {
  display: block;
  padding: 14px;
  border-top: 1px solid #ccc;
  background-color: #f5f5f5;
}
a.alert {
  background-color: #F2DEDE;
}
#dashboard > a:hover {
  background-color: #eee;
}

#myprofilecmds {
  position: relative;
  width: 12em;
  margin-left: 10px;
}
#myprofilecmds a {
  margin: 4px;
  width: 96%;
}

dd + dt {
  margin-top: 6px;
}
h2 {
  font-size: 20px;
}

</style>
<div class=clearfix id=topbar>
  <h1>My Account</h1>
</div>
<%=wu.popNotifications()%>

<div id=dashboard class="panel panel-default" style='max-width:600px; padding:20px; margin: auto;'>

  <% if (flaggedPicSets.size() > 0) { %>
    <h2>Flagged picture sets</h2>
    <% for (Rec rec : flaggedPicSets) {
      String[] x = rec.id.split("-");
      String picset_id = x[1]; %>
      <a class=alert href="picset.jsp?id=<%=picset_id%>"><%= WebUtil.esc(rec.label) %></a>
    <% } %> 
  <% } %>

  <% if (myPicSetsNotReady.size() > 0) { %>
    <h2>Unfinished Uploads</h2>
    <% for (Rec rec : myPicSetsNotReady) { %>
      <a href="picset.jsp?id=<%=rec.id%>"><%= WebUtil.esc(rec.label) %></a>
    <% } %> 
  <% } %>

  <% if (myFavPosts.size() > 0) { %>
    <h2>Favorite Posts</h2>
    <% for (Rec rec : myFavPosts) { %>
      <a href="post.jsp?postId=<%=rec.id%>"><%= WebUtil.esc(rec.label) %></a>
    <% } %> 
  <% } %>

  <% if (myPosts.size() > 0) { %>
    <div class=header>
      <h2>Posts I Manage
        <a href=managePost.jsp class="btn btn-default">add post</a>
      </h2>
    </div>
    <% for (Rec rec : myPosts) { %>
      <a href="post.jsp?postId=<%=rec.id%>"><%= WebUtil.esc(rec.label) %></a>
    <% } %> 
  <% } %>

  <h2>My Profile</h2>
  <div class='well clearfix'>
    <div class='pull-left'>
    <dl>
    <% if (!("".equals(WebUtil.str(sessionuser.getFirstName())) || "".equals(WebUtil.str(sessionuser.getLastName())))) { %>
    <dt>Name:</dt>
    <dd><%= wu.esc(sessionuser.getFirstName()) + " " + wu.esc(sessionuser.getLastName()) %></dd>
    <% } if (! "".equals(sessionuser.getEmail())) { %>
    <dt>Email:</dt>
    <dd><%= wu.esc(sessionuser.getEmail()) %></dd>
    <% } if (! "".equals(WebUtil.str(sessionuser.getMobilePhone()))) { %>
    <dt>Mobile Phone to use app:</dt>
    <dd><%= wu.esc(sessionuser.getMobilePhone()) %> <a class="btn btn-default" href=mobileapps.jsp>update</a></dd>
    <% } if (! "".equals(WebUtil.str(sessionuser.getUsername()))) { %>
    <dt>Username:</dt>
    <dd><%= wu.esc(sessionuser.getUsername()) %></dd>
    <% } %>
    </dl>
    </div>
    <div class='pull-left' id=myprofilecmds>
      <a class="btn btn-default" href=/myprofile.jsp>edit my profile</a>
      <a class="btn btn-default" href=/changepassword.jsp>change password</a>
      <!-- <a class="btn btn-default" href=/newslettersignup.jsp>newsletter signup</a> -->
      <a class="btn btn-default" id=MobileAppDownloadLink href=/mobileapps.jsp>download mobile app</a>
      <a class="btn btn-default" href=/login.jsp>logout</a>
    </div>
  </div>

  <% if (sessionuser.getAdmin()) { %>
  <h2>Admin Tools</h2>
    <a href=admin/pics2ftp/index.jsp>export pictures</a>
    <a href=admin/postOwners.jsp>post owners</a>
    <a href=admin/personList.jsp>all users</a>
    <a href=admin/postInfo.jsp>all posts</a>
    <a href=admin/adminfunctions.jsp>admin functions</a>
  <% } %>
</div>
<script>
if (hasNativeAppSupport()) {
  $("#MobileAppDownloadLink").show();
}
</script>

<%@ include file="/includes/footer.jsp" %>
