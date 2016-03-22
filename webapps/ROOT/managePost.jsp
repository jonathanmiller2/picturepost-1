<%@ include file="/includes/common.jsp" %>

<%
// make sure user is logged in
if (! sessionuser.isLoggedIn()) {
  wu.sendLogin();
  return;
}


// create new post?
if ("".equals(wu.param("postId"))) {

  // does this user have another post they are making in progress?
  { String sql = "SELECT post_id FROM post WHERE person_id=? AND name='' AND ready=false ORDER BY post_id DESC LIMIT 1";
    PreparedStatement stmt = wu.dbh().prepareStatement(sql);
    stmt.setInt(1, sessionuser.getPersonId());
    ResultSet rs = stmt.executeQuery();
    if (rs.next()) {
      int postId = rs.getInt(1);
      wu.redirect("/managePost.jsp?postId="+postId);
      return;
    }
  }

  Post p = new Post();
  p.setPersonId(sessionuser.getPersonId());
  p.dbSetPostId(); 
  p.setRecordTimestamp(Utils.getCurrentTimestamp());
  p.setInstallDate(new java.sql.Date(Calendar.getInstance().getTimeInMillis()));

  if (p.dbInsert()) {
    wu.redirect("/managePost.jsp?postId="+p.getPostId());
  } else {
    wu.addNotificationError("Could not create new post.");
    wu.redirect("/notify.jsp");
  }
  return;
}

// load post record
Post p = new Post();
if (wu.param_int("postId",0) > 0) {
  p = new Post();
  p.dbSelect(wu.param_int("postId",0));
}
if (!(p.getPostId() > 0)) {
  wu.addNotificationError("Post ID does not exist");
  wu.redirect("/notify.jsp");
  return;
}

// make sure use has access to edit post
if (!(sessionuser.getAdmin() || p.getPersonId() == sessionuser.getPersonId())) {
  wu.redirect("/post.jsp?postId="+p.getPostId()); 
  return;
}

// save post?
if ("save".equals(wu.param("act"))) {
  if (! "".equals(wu.param("owneremail"))) {
    int newowner_id = Person.dbGetPersonIdFromEmail(wu.param("owneremail")); 
    if (newowner_id == 0) {
      wu.reload("Could not find user with email: " + wu.param("owneremail")); 
      return;
    }
    p.setPersonId(newowner_id);
  }

  p.setName(wu.param("name")); 
  p.setDescription(wu.param("descr")); 

  if (sessionuser.getAdmin()) {
    p.setLogoHtml(wu.param("logohtml"));
    p.setThankyouHtml(wu.param("thankyouhtml"));
  }

  try {
    p.setInstallDate(new java.sql.Date(Utils.parseDate(wu.param("installdt")).getTime())); 
  } catch(Exception e) {
    p.setInstallDate(null);
  }

  if (! "".equals(wu.param("lon")) && ! "".equals(wu.param("lat"))) {
    double lon = Double.parseDouble(wu.param("lon"));
    double lat = Double.parseDouble(wu.param("lat"));
    if (lon>-180.0 && lon<180.0 && lat>-90.0 && lat<90.0) {
      p.setLon(lon);
      p.setLat(lat);
    }
  }

  if (p.dbUpdate()) {
    wu.addNotificationSuccess("post saved");
    wu.redirect("post.jsp?postId="+p.getPostId()); 
  } else {
    wu.reload("could not save record");
  }
  return;
}

// delete post?
if ("delete".equals(wu.param("act"))) {
  if (p.dbDelete()) {
    wu.addNotificationSuccess("post deleted");
    wu.redirect("notify.jsp"); 
  } else {
    wu.reload("could not delete record");
  }
  return;
}

if ("deletepostpic".equals(wu.param("act"))) {
  String rv = "";
  int id = wu.param_int("id", 0);
  PostPicture pp = new PostPicture(id);
  if (pp.dbDelete()) {
    rv = "OK - post_picture_id="+id+" deleted";
  } else {
    rv = "ERROR - could not delete picture";
  }
  response.setContentType("text/plain");
  response.getWriter().write(rv);
  return;
}

if ("uploadpostpic".equals(wu.param("act"))) {
  String rv = "";
  
  try {
    PostPicture pp = new PostPicture();
    pp.setPostId(p.getPostId());
    pp.setImageFileOriginal(WebUtil.fix_filename(wu.param("fn")));
    pp.setFileType("JPEG");
    pp.setActive(true);
    pp.dbSetPostPictureId();
    pp.dbSetSeqNbr();
    File dir = new File(Config.get("PICTURE_DIR") + File.separator + p.getPostDir());
    wu.uploadbase64photo(wu.param("photo"), dir, "post_picture_" + pp.getPostPictureId());
    if (! pp.dbInsert()) throw new Exception();
    rv = "OK - post_picture_id="+pp.getPostPictureId();
  } catch (Exception e) {
    Log.writeLog("could not upload picture: " + e.getMessage());
    rv = "ERROR - could not save picture";
  }
  response.setContentType("text/plain");
  response.getWriter().write(rv);
  return;
}

// provide default values for form elements if page state is not loaded
if (! wu.pagestate) {
  wu.setparam("name", p.getName());
  wu.setparam("descr", p.getDescription());
  wu.setparam("installdt", p.getInstallDate());
  wu.setparam("lat", p.getLat());
  wu.setparam("lon", p.getLon());
  wu.setparam("thankyouhtml", p.getThankyouHtml());
  wu.setparam("logohtml", p.getLogoHtml());
  wu.setparam("owneremail", "");
  if (p.getPersonId() > 0) {
    Person ownerPerson = new Person(p.getPersonId());
    wu.setparam("owneremail", ownerPerson.getEmail());
  }
}


// load post pictures
List<Integer> postpics = new ArrayList<Integer>();
{ String sql = "SELECT post_picture_id FROM post_picture WHERE post_id=? AND active=true ORDER BY seq_nbr DESC";
  PreparedStatement stmt = wu.dbh().prepareStatement(sql);
  stmt.setInt(1, p.getPostId());
  ResultSet rs = stmt.executeQuery();
  while (rs.next()) {
    Integer x = rs.getInt(1);
    postpics.add(x);
  }
}
%>
<%@ include file="/includes/header.jsp" %>
<style>
#postphotos img {
  margin: 6px;
  border: 2px solid transparent;
  cursor: pointer;
}
#postphotos img.selected {
  border-color: red;
}
label {
  display: block;
}

</style>
<div class=clearfix id=topbar>
  <a href="post.jsp?postId=<%=p.getPostId()%>" class="btn btn-default pull-left"><span class="glyphicon glyphicon-menu-left" aria-hidden="true"></span>
 back</a>
  <h1><%= (p.getName()==null || "".equals(p.getName())) ? "New Post" : WebUtil.esc(p.getName()) %></h1>
</div>
<%=wu.popNotifications()%>

<div class="panel panel-default" style='max-width:600px; margin:auto;'>

<form method=post class=panel-body>
  <input type=hidden name=postId value='<%=wu.eparam("postId")%>'>

  <p>
  <label>post name
    <input class=form-control type=text name=name maxlength=255 required value='<%=wu.eparam("name")%>'>
  </label>

  <p>
  <label>description 
    <textarea rows=5 class=form-control name=descr maxlength=4096 required><%=wu.eparam("descr")%></textarea>
  </label>

  <p>
  <label>install date
    <input class=form-control type=date name=installdt required value='<%=wu.eparam("installdt")%>'>
  </label>

  <p>
  <label>owner email
    <input class=form-control type=email name=owneremail required value='<%=wu.eparam("owneremail")%>'>
  </label>

  <fieldset>
    <legend>location</legend>
    <div style='width:10em;display:inline-block;'>
      <label>latitude<input type=text class=form-control name=lat id=lat required value='<%=wu.eparam("lat")%>'></label>
      <label>longitude<input type=text class=form-control name=lon required value='<%=wu.eparam("lon")%>'></label>
    </div>
    <button style='position:relative;top:-2em;'type=button class="btn btn-default SelectLocationWidget">find</button>
  </fieldset>

  <fieldset>
    <legend>post photos</legend>
    <div id=postphotos style='max-height:200px; overflow:auto;'>
      <% for (int id : postpics) { %>
        <img data-id="<%=id%>" src="/images/pictures/post_<%=p.getPostId()%>/post_picture_<%=id%>_thumb.jpg">
      <% } %>
    </div>
    <div class=formfileuploadbut>
      <button type=button class="btn btn-default">upload</button>
      <input id=postphotoupload type=file accept='image/jpeg'>
    </div>
    <span id=photoops style='visibility:hidden;'>
      <button id=DeletePhotoBut type=button class="btn btn-danger">delete photo</button>
    </span>
  </fieldset>

  <% if (sessionuser.getAdmin()) { %>
  <p>
  <label>logo HTML
    <textarea rows=5 class=form-control name=logohtml maxlength=4096><%=wu.eparam("logohtml")%></textarea>
  </label>

  <p>
  <label>thank you HTML
    <textarea rows=5 class=form-control name=thankyouhtml maxlength=4096><%=wu.eparam("thankyouhtml")%></textarea>
  </label>
  <% } %>

  <hr>
  <a href="post.jsp?postId=<%=p.getPostId()%>" class="btn btn-default">cancel</a>
  <button id=DeletePostBut class="btn btn-danger" type=button value=delete>delete post</button>
  <button class="btn btn-primary" type=submit name=act value=save>save</button>

</form>
</div>

<script src=js/load-image.all.min.js></script>
<script>

var MAX_WIDTH = 1024;
var postId = '<%=p.getPostId()%>';

$("#DeletePostBut").click(function(){
  if (confirm("Are you sure you want to delete this record?")) {
    $(this.form)
      .append($('<input type=hidden name=act value=delete>'))
      .submit();
  }
});

$("#postphotos").on("click", "img", function(){
  $(this).siblings('.selected').removeClass('selected');
  var $t = $(this).toggleClass('selected');
  if ($t.hasClass("selected")) {
    $("#photoops").css('visibility','visible');
  } else {
    $("#photoops").css('visibility','hidden');
  }
});
$("#DeletePhotoBut").click(function(){
  $("#photoops").css('visibility','hidden');
  var $img = $('#postphotos img.selected');
  var id = $img.attr('data-id');
  if (! id) return;
  $.ajax({
    type: 'post',
    data: { act: 'deletepostpic', postId: postId, id: id },
    success: function() { $img.remove(); },
    error: function(){ alert('Sorry, could not remove photo.'); }
  });
});

$("#postphotoupload").change(function(e){
  var $e = $(this);
  var file = e.target.files[0];
  var $but = $(this).prev();

  loadImage.parseMetaData(file, function (data) {
    var opts = { maxWidth: MAX_WIDTH };
    var exif;
    var lastProgress;
    if (data.exif) {
      exif = data.exif.getAll();
      opts.orientation = data.exif.get('Orientation');
    }
    loadImage(file, function(img) {
      if (img.type == "error") {
        alert("could not load img");
        return;
      }
      $.ajax({
        type: 'post',
        data: {
          act: "uploadpostpic",
          postId: postId,
          photo: img.toDataURL("image/jpeg").replace(/^[^\,]*\,/,''),
          fn: $e.val()
        },
        xhr: function() {
          var xhr = $.ajaxSettings.xhr();
          xhr.upload.onprogress = function(e) {
            var p = (e.total > 0) ? Math.round(e.loaded/e.total*100) : 0;
            if (p == lastProgress) return;
            lastProgress = p;
            $but.text(p + '%');
          };
          return xhr;
        },
        success: function(d) {
          console.log(["upload complete", d]);
          if (/post_picture_id\=(\d+)/.test(d)) {
            var id = RegExp.$1; 
            $('#postphotos').prepend('<img data-id="'+id+'" src="/images/pictures/post_'+postId+'/post_picture_'+id+'_thumb.jpg">');
            $but.text('upload');
          } else {
            $but.text('upload error');
          }
        },
        error: function() {
          $but.text('upload error');
        }
      });
    }, opts);
  });
});
</script>
<script src=/locpicker/main.js></script>
<%@ include file="/includes/footer.jsp" %>

