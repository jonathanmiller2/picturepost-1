<%@ include file="/includes/common.jsp" %>
<%
// set user favorite
if (wu.param("act").equals("setfavorite")) {
    int user_id = Person.getInstance(session).getPersonId();
    int postId = wu.param_int("postId", 0);
    if (user_id > 0 && postId > 0) {
        FavoritePost fp = new FavoritePost(user_id, postId);
        fp.dbInsert();
    }
    response.setContentType("text/html");
    response.getWriter().write("ok");
    return;
}

// flag pictureset
if (wu.param("act").equals("flag")) {
  PictureSet ps = new PictureSet(wu.param_int("picset_id",0));
  ps.setFlagged(true);
  String rv = "ERROR";
  if (ps.dbUpdate()) {
    rv = "ok - picset flagged";
    wu.addNotificationSuccess("picture set flagged successfully");
  }
  response.setContentType("text/plain");
  response.getWriter().write(rv);
  return;
}

// unset favorite
if (wu.param("act").equals("unsetfavorite")) {
    int postId = wu.param_int("postId", 0);
    if (sessionuser.getPersonId() > 0 && postId > 0) {
        FavoritePost fp = new FavoritePost(sessionuser.getPersonId(), postId);
        fp.dbDelete();
    }
    response.setContentType("text/html");
    response.getWriter().write("ok");
    return;
}

// insert, update, delete a comment
if (wu.param("act").equals("savecomment")) {
  int comment_id = wu.param_int("comment_id", 0);
  PictureComment pc;
  if (comment_id > 0) {
    pc = new PictureComment(comment_id);
  } else {
    int pic_id = wu.param_int("pic_id", 0);
    pc = new PictureComment();
    pc.dbSetPictureCommentId();
    pc.setPictureId(pic_id);
    pc.setPersonId(sessionuser.getPersonId());
    pc.setCommentTimestamp(Utils.getCurrentTimestamp());
  }
  String text = wu.param("text","");
  String rv = "error";

  // make sure user can edit comment
  if (! pc.canEdit(sessionuser)) {
    rv = "invalid privileges";
  }

  // else if user is deleting comment
  else if ("".equals(text)) {
    if (comment_id > 0) {
      if (pc.dbDelete()) {
        rv = "ok - PictureComment=" + pc.getPictureCommentId()+ " deleted";
      }
    }
  }

  // else user is saving a comment
  else {
    pc.setCommentText(text);
    if (comment_id > 0) {
      if (pc.dbUpdate()) {
        rv = "ok - PictureComment=" + pc.getPictureCommentId()+ " updated";
      }
    } else {
      if (pc.dbInsert()) {
        rv = "ok - PictureComment=" + pc.getPictureCommentId()+ " inserted";
      }
    }
  }

  response.setContentType("text/html");
  response.getWriter().write(rv);
  return;
}
    
class PostPage {
    WebUtil wu = null;
    Connection dbh = null;
    int postId = 0;
    int user_id = 0;
 
    String logohtml = "";
    String post_name = "";
    String post_description = "";
    String install_dt = "";
    double lat = 0;
    double lon = 0;
    int postmaster_person_id = 0;
    String postmaster_name = "";
 
    boolean isFavorite = false;
 
    public PostPage() {
    }
    
    public PostPage(WebUtil wu, int postId, int user_id) throws Exception {
      this.wu = wu;
      this.dbh = wu.dbh();
      this.postId = postId;
      this.user_id = user_id;
      if (postId !=0) { 
        this.loadPostInfo();
        this.loadPostPics();
        this.loadPicSets();
        this.loadComments();
        this.loadIsFavorite();
      }
    }
    
    private void loadIsFavorite() throws Exception {
      String sql = "SELECT '1' FROM favorite_post WHERE person_id=? AND post_id=? LIMIT 1";
      PreparedStatement stmt = dbh.prepareStatement(sql);
      stmt.setInt(1, user_id);
      stmt.setInt(2, postId);
      ResultSet rs = stmt.executeQuery();
      if (rs.next()) {
        isFavorite = true;
      }
    }

  	  	
	private void loadPostInfo() throws Exception {
		String sql =
"SELECT post.name, " +
"  post.description, " +
"  TO_CHAR(COALESCE(post.install_date, '1970-01-01'), 'Mon fmDD, YYYY') INSTALL_DT, " +
"  ST_Y(post.location) lat, " +
"  ST_X(post.location) lon, " +
"  post.person_id, " +
"  CONCAT(person.first_name, ' ', person.last_name), " +
"  post.logohtml " +
"FROM post " +
"JOIN person ON (post.person_id=person.person_id) " +
"WHERE post_id=?";
		PreparedStatement stmt = dbh.prepareStatement(sql);
		stmt.setInt(1, postId);
    	ResultSet rs = stmt.executeQuery();
    	if (rs.next()) {
			post_name =  rs.getString(1);
			post_description = rs.getString(2);
			install_dt = rs.getString(3);
			lat = rs.getDouble(4);
			lon = rs.getDouble(5);
			postmaster_person_id = rs.getInt(6);
			postmaster_name = rs.getString(7);
			logohtml = WebUtil.str(rs.getString(8));
		} else {
			throw new Exception("post not found");
		}
	}
	
    String picsets = "[]";
	private void loadPicSets() throws Exception {
		String sql =
"SELECT picture_set.picture_set_id PICSET_ID, " +
"  TO_CHAR(COALESCE(picture_set.picture_set_timestamp, '1970-01-01'), 'YYYY-MM-DD HH24:MI') DT, " +
"  PIC_N,PIC_NE,PIC_E,PIC_SE,PIC_S,PIC_SW,PIC_W,PIC_NW,PIC_UP," +
"  picture_set.annotation, " +
"  CONCAT(person.first_name, ' ', person.last_name) " +
"FROM picture_set " +
"LEFT JOIN person ON (picture_set.person_id=person.person_id) " +
"LEFT JOIN ( " +
"  SELECT " +
"    picture_set_id, " +
"    MAX(CASE WHEN orientation = 'N'  THEN picture_id ELSE NULL END) PIC_N,  " +
"    MAX(CASE WHEN orientation = 'NE' THEN picture_id ELSE NULL END) PIC_NE, " +
"    MAX(CASE WHEN orientation = 'E'  THEN picture_id ELSE NULL END) PIC_E,  " +
"    MAX(CASE WHEN orientation = 'SE' THEN picture_id ELSE NULL END) PIC_SE, " +
"    MAX(CASE WHEN orientation = 'S'  THEN picture_id ELSE NULL END) PIC_S,  " +
"    MAX(CASE WHEN orientation = 'SW' THEN picture_id ELSE NULL END) PIC_SW, " +
"    MAX(CASE WHEN orientation = 'W'  THEN picture_id ELSE NULL END) PIC_W,  " +
"    MAX(CASE WHEN orientation = 'NW' THEN picture_id ELSE NULL END) PIC_NW, " +
"    MAX(CASE WHEN orientation = 'UP' THEN picture_id ELSE NULL END) PIC_UP  " +
"  FROM picture " +
"  GROUP BY picture_set_id " +
") pictures ON (picture_set.picture_set_id=pictures.picture_set_id) " +
"WHERE picture_set.post_id=? " +
"AND picture_set.ready = true " +
"AND picture_set.flagged = false " +
"ORDER BY picture_set.picture_set_timestamp";
		PreparedStatement stmt = dbh.prepareStatement(sql);
		stmt.setInt(1, postId);
		ResultSet rs = stmt.executeQuery();
		JSONArray ar = WebUtil.dbJsonArray(rs);
		picsets = ar.toString();
	}
 
    List<Integer> postPicIds = new ArrayList<Integer>();
    private void loadPostPics() throws Exception {
        Q q = wu.q().append("SELECT post_picture_id FROM post_picture WHERE active=true AND post_id=? ORDER BY seq_nbr LIMIT 100").bind(postId);
        while (q.fetch()) {
          postPicIds.add(q.getInt());
        }
    }
    
    class PicComment {
      int commentId;
      int pictureId;
      int pictureSetId;
      int personId;
      String orientation;
      String dt;
      String picsetdt;
      String comment;
      String userName;
    }
    List<PicComment> comments = new ArrayList<PicComment>();
    private void loadComments() throws Exception {
        String sql =
"SELECT picture_comment_id, " +
"  picture.picture_id, " +
"  picture_set.picture_set_id, " +
"  picture_comment.person_id, " +
"  picture.orientation, " +
"  TO_CHAR(COALESCE(picture_comment.comment_timestamp, '1970-01-01'), 'Mon fmDD, YYYY'), " +
"  TO_CHAR(COALESCE(picture_set.record_timestamp, '1970-01-01'), 'Mon fmDD, YYYY'), " +
"  picture_comment.comment_text, " +
"  CONCAT(person.first_name,' ',person.last_name) " +
"FROM picture_set " +
"JOIN picture ON (picture_set.picture_set_id=picture.picture_set_id) " +
"JOIN picture_comment ON (picture.picture_id=picture_comment.picture_id) " +
"JOIN person ON (picture_comment.person_id=person.person_id) " +
"WHERE picture_set.post_id=? " +
"ORDER BY comment_timestamp DESC " +
"LIMIT 100";
        PreparedStatement stmt = dbh.prepareStatement(sql);
        stmt.setInt(1, postId);
        ResultSet rs = stmt.executeQuery();
        while (rs.next()) {
          PicComment pc = new PicComment();
          pc.commentId = rs.getInt(1);
          pc.pictureId = rs.getInt(2);
          pc.pictureSetId = rs.getInt(3);
          pc.personId = rs.getInt(4);
          pc.orientation = rs.getString(5);
          pc.dt = rs.getString(6);
          pc.picsetdt = rs.getString(7);
          pc.comment = rs.getString(8);
          pc.userName = rs.getString(9);
          comments.add(pc);
        }
    }
}

PostPage p = null; 
try {
    int pic_id = wu.param_int("pic",0);
    int postId = 0;

    // if pic ID passed in, load from pic ID
    if (pic_id > 0) {
      Q q = wu.q().append("SELECT picture_set.post_id, picture_set.annotation FROM picture JOIN picture_set ON (picture.picture_set_id=picture_set.picture_set_id) WHERE picture.picture_id=?").bind(wu.param_int("pic",0)).append("LIMIT 1");
      postId = q.getInt();
      if (postId > 0) {
        og_description = q.get();
	    p = new PostPage(wu, postId, sessionuser.getPersonId());
        og_image = Config.get("URL") + "/images/pictures/post_" + postId + "/picture_" + pic_id + "_medium.jpg";
        og_title = p.post_name;
      }
    }
    if (!(postId > 0)) {
      postId = wu.param_int("postId", 0);
	  p = new PostPage(wu, postId, sessionuser.getPersonId());

      if (p.postPicIds.size() > 0) {
        og_image = Config.get("URL") + "/images/pictures/post_" + postId + "/post_picture_" + p.postPicIds.get(0) + "_medium.jpg";
      }
      og_title = p.post_name;
      og_description = p.post_description;
    }
    if (!(postId > 0)) {
      throw new Exception("post not found");
    }
}
catch (Exception e) {
	wu.handleError(e);
	p = null;
}
if (p == null) return;
%>
<%@ include file="/includes/header.jsp" %>
<link rel="stylesheet" type="text/css" href="css/post.css">

<div id=topbar class=clearfix>
  <% if ("".equals(WebUtil.str(p.logohtml))) { %>
    <h1><%= WebUtil.esc(p.post_name) %></h1>
  <% } else { %>
    <%=p.logohtml%>
  <% } %>
</div>

<%=wu.popNotifications()%>

<div id="PostContent" class="panel panel-default clearfix" style="background-color: #eee">
    <div class=pull-left style='min-width: 300px; text-align:center;'>
    <% if (p.postPicIds.size() > 0) { %>
      <img class=shadow data-i=0 data-pics="<%= p.postPicIds.toString()%>" style='margin:15px;max-width:calc(100% - 20px);' src="/images/pictures/post_<%=p.postId%>/post_picture_<%=p.postPicIds.get(0)%>_medium.jpg">
    <% } %>
    <% if (p.postPicIds.size() > 1) { %>
      <div id=postphotonav style='text-align: center; margin-bottom:10px;'>
        <button id=PrevPostPhoto type=button class="btn btn-default" title='show previous post photo'>
          <span class="glyphicon glyphicon-chevron-left"></span>
        </button>
        <button style='margin-left:50px;' id=NextPostPhoto type=button class="btn btn-default" title='show next post photo'>
          <span class="glyphicon glyphicon-chevron-right"></span>
        </button>
      </div>
    <% } %>
    </div>
    <blockquote style='border:0;'>
      <%=WebUtil.esc(p.post_description)%>
      <footer>
        <%=WebUtil.esc(p.postmaster_name)%>
        installed on <%=WebUtil.esc(p.install_dt)%>
      </footer>
    </blockquote>
    <hr style='clear:both;border-color: #ddd;'>
    <p>
      <a style='margin:10px;' class="desktoponly pull-right btn btn-default" title="analyze and view additional data at this post" href="analyze/post.jsp?postId=<%=p.postId%>">advanced</a>

      <a style='margin:10px;' class="pull-right btn btn-default" title="view location on map" href="http://maps.google.com/?q=<%=p.lat%>,<%=p.lon%>">map</a>

    <% if (sessionuser.getAdmin() || sessionuser.getPersonId()==p.postmaster_person_id){ %>
      <a style='margin:10px;' class="pull-right btn btn-default" href="managePost.jsp?postId=<%=p.postId%>">edit</a>
    <%} %>

    <% if (sessionuser.isLoggedIn()){ %>
      <label style='margin:10px;' class="btn btn-default"><input id=IsFavoriteCheckbox type=checkbox <%=(p.isFavorite) ? " checked":""%> > favorite</label>
    <%} %>
</div>

<div id=picpostviewer class="panel panel-default" style="background-color: #eee">
  <a class="btn btn-primary pull-right" href='picset.jsp?act=new&post=<%=p.postId%>' style='margin:10px;'><span class="glyphicon glyphicon-camera" aria-hidden="true"></span> upload your photos</a>

  <h2>Picture&nbsp;Sets</h2>
  <div class=panel-body>
  <div id=orientationCtrl title="Click on an orientation or press Shift-Left/Shift-Right hotkeys." align=center> 
    <h4 style='display: inline-block;'>look at</h4>
    <div style='display: inline-block; margin-left:6px;' id=picpostdir>
      <a id=ppdirN href=# class='btn btn-default' title="look north">N</a>
      <a id=ppdirNE href='#' class='btn btn-default' title="look northeast">NE</a>
      <a id=ppdirE href='#' class='btn btn-default' title="look east">E</a>
      <a id=ppdirSE href='#' class='btn btn-default' title="look southeast">SE</a>
      <a id=ppdirS href='#' class='btn btn-default' title="look south">S</a>
      <a id=ppdirSW href='#' class='btn btn-default' title="look southwest">SW</a>
      <a id=ppdirW href='#' class='btn btn-default' title="look west">W</a>
      <a id=ppdirNW href='#' class='btn btn-default' title="look northwest">NW</a>
      <a id=ppdirUP href='#' class='btn btn-default' title="look up up at the sky">Up</a>
    </div>
  </div>

  <img class=shadow id=ppimg alt='picturepost photo showing selected orientation' style='width:100%;'>

  <div id=picsetcaptionhtml></div>
        
  <div id=picsetCtrl class=justify style="clear: both;">
    <div>
      <button id=PrevBut type=button title='show older pictureset (swipe/press Left)' class="btn btn-primary">older</button>
    </div>

    <div id=picdtwidget>
      <a class="btn btn-default" role="button" data-toggle="collapse" href="#picposttimeslider" aria-expanded="false" aria-controls="picposttimeslider">
      <span id=picdt></span>
      <span class="caret"></span>
      </a>
    </div>

    <div>
      <div id=PlayButGrp class="btn-group dropdown">
        <button id=PlayBut type="button" class="btn btn-default" title="play picture sets"><span class="glyphicon glyphicon-play"></span></button>
        <button id=PlayButSpeedOpts type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
          <span class="caret"></span>
          <span class="sr-only">Toggle Dropdown</span>
        </button>
        <ul class="dropdown-menu">
          <li><a data-speed=8000 href="#">slowest</a></li>
          <li><a data-speed=4000 href="#">slower</a></li>
          <li><a data-speed=2000 href="#">normal</a></li>
          <li><a data-speed=1000 href="#">faster</a></li>
          <li><a data-speed=500 href="#">fastest</a></li>
        </ul>
      </div>
    </div>

    <div align=right>
      <button id=NextBut type=button title='show newer pictureset (swipe/press Right)' class="btn btn-primary">newer</button>
    </div>
  </div>

  <div id=picposttimeslider class="collapse well"></div>

  <hr style='border-color: #ddd;'>
  <div id=picsetcmds style='text-align:right;'>
    <a href=# class="btn btn-default btn-facebook shareActivePicsetOnFacebook" title="Share picture set on facebook"><img src=../images/facebookicon.png> share</a>

    <% if (sessionuser.getAdmin() || sessionuser.getPersonId()==p.postmaster_person_id){ %>
    <a class="btn btn-default" id=picsetEditBut href=#>edit</a>
    <% } %>

    <button id=picsetFlagBut class="btn btn-default" title="report offensive material in this pictureset">flag</a>
  </div>
  </div>
</div>


<% if (sessionuser.isLoggedIn()){ %>
<div id=picpostcomments>
  <div align=center>
    <h2>comments</h2>
    <button id=AddPostCommentBut type="button" class="btn btn-default">add</button>
  </div>

  <blockquote id="postcommentform" style='display:none;'>
    <img alt='selected picture to comment on' id=PostCommentPic style='vertical-align:top;'>
    <textarea id=newcomment class="form-control" style="display:inline;width:calc(100% - 100px); height:6em;" placeholder="share your comment.."></textarea> 
    <div class=justify>
      <div><button id=CancelPostCommentBut type=button class="btn btn-default">cancel</button></div>
      <div><button id=DeletePostCommentBut type=button class="btn btn-danger">delete</button></div>
      <div><button id=SavePostCommentBut type=button class="btn btn-primary">ok</button></div>
    </div>
  </blockquote>

  <div id=usercomments>
  <%for (PostPage.PicComment pc : p.comments) {%>
    <blockquote class=picusercomment>
    <a class=pull-left href="#picset=<%=pc.pictureSetId%>&orientation=<%=pc.orientation%>"><img src="/images/pictures/post_<%=p.postId%>/picture_<%=pc.pictureId%>_thumb.jpg"><div class=picsetcommentdt><%=WebUtil.esc(pc.picsetdt)%></div></a>
    <p class=commenttext><%=WebUtil.esc(pc.comment)%></p>
    <footer>
      <%=WebUtil.esc(pc.userName)%> on <%=WebUtil.esc(pc.dt)%>
      <% if (pc.personId==sessionuser.getPersonId() || sessionuser.getAdmin() || sessionuser.getPersonId()==p.postmaster_person_id) { %>
        <a href=# class="EditCommentBut btn btn-default" data-pic_id="<%=pc.pictureId%>" data-comment_id="<%=pc.commentId%>">edit</a>
      <% } %>
    </footer>
    </blockquote>
  <%}%>
  </div>
</div>
<% } %>

<script>
  var post_id = <%=p.postId%>;
  var picsets = <%=p.picsets%>;
</script>
<script src=js/jquery.mobile-events.min.js></script>
<script src=js/post.js></script>

<%@ include file="/includes/footer.jsp" %>
