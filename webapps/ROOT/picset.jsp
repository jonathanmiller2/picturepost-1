<%@ include file="/includes/common.jsp" %>
<%
if (! sessionuser.isLoggedIn()) {
  wu.sendLogin();
  return;
}

String act = wu.param("act");

// create new pictureset
if ("new".equals(act)) {
  try {
    int postId = wu.param_int("post", 0);
    if (postId == 0) throw new Exception("missing post param");

    // does a non-ready pictureset rec already exist for this user?
    int pictureSetId = wu.q()
      .select("picture_set_id")
      .from("picture_set")
      .where("person_id=?").bind(sessionuser.getPersonId())
      .where("post_id=?").bind(postId)
      .where("ready=false")
      .append("LIMIT 1")
      .getInt();

    // if a non-ready picset does not exti, create one
    if (pictureSetId==0) {
      PictureSet ps = new PictureSet();
      ps.setPostId(postId);
      ps.dbSetPictureSetId();
      ps.setPersonId(sessionuser.getPersonId());
      boolean rv = ps.dbInsert();
      if (rv == false) throw new Exception("could not insert pictureset");
      pictureSetId = ps.getPictureSetId();
    }

    wu.redirect("/picset.jsp?id="+pictureSetId);
  }
  catch(Exception e) {
    wu.handleError(e);
  }
  return;
}

// check priv must be owner or admin to use this record
int id = wu.param_int("id",0);

Q q = wu.q().append("SELECT picture_set.person_id, post.person_id FROM picture_set JOIN post ON (picture_set.post_id=post.post_id) WHERE picture_set_id=? LIMIT 1").bind(id);
int pictureset_owner = q.getInt();
int post_owner = q.getInt();
if (! sessionuser.getAdmin() && sessionuser.getPersonId() != pictureset_owner && sessionuser.getPersonId() != post_owner) {
  wu.addNotificationError("Sorry, you do not have access to this pictureset.");
  wu.redirect("/notify.jsp");
  return;
}


// if upload picture
if ("upload".equals(act)) {
  int pictureSetId = wu.param_int("picset",0);
  String photoB64Jpeg = wu.param("photo");
  String orientation = wu.param("orientation");
  String rv; 
  try {
    PictureSet pictureSet = new PictureSet(pictureSetId);
    if (pictureSet.getPictureSetId()==0) {
      throw new Exception("pictureset does not exist");
    }

    Post post = new Post(pictureSet.getPostId());
    Picture picture = new Picture();
    picture.setPictureSetId(pictureSetId);
    picture.setOrientation(orientation);
    picture.setImageFileOriginal(WebUtil.fix_filename(wu.param("fn")));
    picture.setFileType("JPEG");
    picture.setFileExt(".jpg");
    picture.dbSetPictureId();

    File dir = new File(Config.get("PICTURE_DIR") + File.separator + post.getPostDir());
    wu.uploadbase64photo(photoB64Jpeg, dir, "picture_" + picture.getPictureId());

    // delete existing picture for this orientation
    Picture existingPictureRecord = PictureSet.getPictureRecord(pictureSet, orientation);
    if (existingPictureRecord != null) {
      existingPictureRecord.dbDelete();
    }
  
    // save record
    if (! picture.dbInsert()) {
      throw new Exception("could not insert picture record");
    }

    // insert metadata
    try {
      JSONObject o = new JSONObject(wu.param("exif"));
      for (Object k : o.names()) {
        String name = k.toString();
        String val = o.getString(name);
        PictureMD pictureMD = new PictureMD();
        pictureMD.setPictureId(picture.getPictureId());
        pictureMD.setDirectory("-");
        pictureMD.setTagId(-99);
        pictureMD.setTagName(name);
        pictureMD.setTagValue(val);
        pictureMD.dbSetPictureMDId();
        if (! pictureMD.dbInsert()) {
          throw new Exception("could not insert metadata");
        }
      }
    } catch(Exception e) {
      Log.writeLog("could not save metadata: " + e.getMessage());
    }

    rv = "OK - picture_id="+picture.getPictureId();
  } catch (Exception e) {
    Log.writeLog("could not upload picture: " + e.getMessage());
    rv = "ERROR - could not save picture";
  }
  response.setContentType("text/plain");
  response.getWriter().write(rv);
  return;
}

// if save pictureset
if ("setdt".equals(act)) {
  java.util.Date picture_set_timestamp = Utils.parseDate(wu.param("picture_set_timestamp"));
  PictureSet ps = new PictureSet(id);
  ps.setPictureSetDate(picture_set_timestamp);
  ps.dbUpdate();
  response.setContentType("text/plain");
  response.getWriter().write("ok");
  return;
}

// if save pictureset
if ("save".equals(act)) {
  PictureSet ps = new PictureSet(id);
  ps.setAnnotation(wu.param("annotation"));
  ps.setReady(true);
  if (sessionuser.getAdmin() || sessionuser.getPersonId() == post_owner) {
    ps.setFlagged("1".equals(wu.param("flagged")) ? true : false);
  }

  java.util.Date picture_set_timestamp = Utils.parseDate(wu.param("picture_set_timestamp"));
  if (picture_set_timestamp != null) {
    ps.setPictureSetDate(picture_set_timestamp);
  }

  Post post = new Post(ps.getPostId());

  if (! ps.dbUpdate()) {
    wu.reload("Could not save record.");
    return;
  }

  // request to set this pictureset as the reference pictureset?
  if ("1".equals(wu.param("makerefpicset")) && (sessionuser.getAdmin() || sessionuser.getPersonId() == post_owner)) {
    post.setReferencePictureSetId(id);
    post.dbUpdate();
  }
  
  wu.addNotification("<div class='alert alert-success alert-dismissible' role='alert'><button type=button class=close data-dismiss=alert aria-label=Close><span aria-hidden=true>&times;</span></button><strong>pictureset saved</strong><span id=thankyouhtml>" + post.getThankyouHtml() + "</span></div>");
  wu.redirect("/post.jsp?postId="+ps.getPostId()+"#picset="+ps.getPictureSetId());
  return;
}

// if delete pictureset
if ("delete".equals(act)) {
  PictureSet ps = new PictureSet(id);
  int postId = ps.getPostId();
  ps.dbDelete();
  wu.addNotificationSuccess("pictureset deleted");
  wu.redirect("/post.jsp?postId="+postId);
  return;
}

// we create our own model because the existing models are too slow
class PicSetPage {
  WebUtil wu = null;
  int postId=0;
  int picSetId=0;
  int picN=0;
  int picNE=0;
  int picE=0;
  int picSE=0;
  int picS=0;
  int picSW=0;
  int picW=0;
  int picNW=0;
  int picUP=0;
  int refPicSetId=0;
  int rpicN=0;
  int rpicNE=0;
  int rpicE=0;
  int rpicSE=0;
  int rpicS=0;
  int rpicSW=0;
  int rpicW=0;
  int rpicNW=0;
  int rpicUP=0;
  String postName="";
  String picture_set_timestamp="";
  String annotation="";
  
  boolean flagged=false;
  boolean ready=false;

  public PicSetPage(int loadPicSetId, WebUtil wu) throws Exception {
    this.wu = wu;
    Q q = wu.q();
    q.select("picture_set.post_id")
     .select("post.name")
     .select("TO_CHAR(picture_set.picture_set_timestamp,'YYYY-MM-DD\"T\"HH24:MI')")
     .select("picture_set.annotation")
     .select("picture_set.ready")
     .select("picture_set.flagged")
     .select("post.reference_picture_set_id")
     .from("picture_set")
     .join("post ON (picture_set.post_id=post.post_id)")
     .where("picture_set.picture_set_id=?").bind(loadPicSetId)
     .append("LIMIT 1");
    if (q.fetch()) {
      picSetId = loadPicSetId;
      postId = q.getInt();
      postName = q.get();
      picture_set_timestamp = q.get();
      annotation = q.get();
      ready = q.getBoolean();
      flagged = q.getBoolean();
      refPicSetId = q.getInt();
    }

    if (postId==0) throw new Exception("picset does not exist");

    // load pics
    q = wu.q();
    q.append("SELECT orientation, picture_id FROM picture WHERE picture.picture_set_id=?").bind(picSetId);
    while (q.fetch()) {
      String o = q.get();
      int picId = q.getInt();
           if ( "N".equals(o)) picN  = picId;
      else if ("NE".equals(o)) picNE = picId;
      else if ( "E".equals(o)) picE  = picId;
      else if ("SE".equals(o)) picSE = picId;
      else if ( "S".equals(o)) picS  = picId;
      else if ("SW".equals(o)) picSW = picId;
      else if ( "W".equals(o)) picW  = picId;
      else if ("NW".equals(o)) picNW = picId;
      else if ("UP".equals(o)) picUP = picId;
    }

    // load pics in reference picset
    if (refPicSetId > 0) {
      q.bind(refPicSetId);
      while (q.fetch()) {
        String o = q.get();
        int picId = q.getInt();
             if ( "N".equals(o)) rpicN  = picId;
        else if ("NE".equals(o)) rpicNE = picId;
        else if ( "E".equals(o)) rpicE  = picId;
        else if ("SE".equals(o)) rpicSE = picId;
        else if ( "S".equals(o)) rpicS  = picId;
        else if ("SW".equals(o)) rpicSW = picId;
        else if ( "W".equals(o)) rpicW  = picId;
        else if ("NW".equals(o)) rpicNW = picId;
        else if ("UP".equals(o)) rpicUP = picId;
      }
    }
  }

  String getPicWidget(String orientation) {
    int picId = 0;
    int rpicId = 0;
    if ("N".equals(orientation)) {
      rpicId = rpicN;
      picId = picN;
    }
    else if ("NE".equals(orientation)) {
      rpicId = rpicNE;
      picId = picNE;
    }
    else if ("E".equals(orientation)) {
      rpicId = rpicE;
      picId = picE;
    }
    else if ("SE".equals(orientation)) {
      rpicId = rpicSE;
      picId = picSE;
    }
    else if ("S".equals(orientation)) {
      rpicId = rpicS;
      picId = picS;
    }
    else if ("SW".equals(orientation)) {
      rpicId = rpicSW;
      picId = picSW;
    }
    else if ("W".equals(orientation)) {
      rpicId = rpicS;
      picId = picS;
    }
    else if ("NW".equals(orientation)) {
      rpicId = rpicNW;
      picId = picNW;
    }
    else if ("UP".equals(orientation)) {
      rpicId = rpicUP;
      picId = picUP;
    }

    if (!(refPicSetId==0 || refPicSetId==picSetId || "1".equals(wu.param("makerefpicset")) || rpicId > 0 || picId > 0)) {
      return "";
    }
    StringBuilder sb = new StringBuilder();
  
    sb.append("<div class=picpanel data-orientation="+orientation+"><h2>"+WebUtil.esc(orientation)+"</h2><div class='pic picframe'>");
  
    if (picId > 0) {
      sb.append("<img src='/images/pictures/post_"+postId+"/picture_"+picId+"_medium.jpg' class=realphoto>");
    }
    else if (rpicId > 0) {
      sb.append("<img  src='/images/pictures/post_"+postId+"/picture_"+rpicId+"_medium.jpg'><small class=refphotoindicator>REFERENCE PHOTO</small>");
    }
    sb.append("</div>");
    sb.append("<div class=formfileuploadbut><button class='UploadPicBut btn btn-default' type=button>upload</button><input data-orientation="+orientation+" type=file name=fileupload accept='image/jpeg'></div><div class=uploadmsg></div>");
    sb.append("</div>");
    return sb.toString();
  }
}

PicSetPage p = null;
try {
  p = new PicSetPage(wu.param_int("id",0), wu);
} catch (Exception e) {
  wu.handleError(e);
}
if (p==null) return;
%>
<%@ include file="/includes/header.jsp" %>
<style>
.formfileuploadbut {
  position: absolute;
  bottom: 2em;
  width: 200px;
  left: 50%;
  margin-left: -100px;
}
.picpanel {
  position: relative;
}
.uploadmsg {
  display: none;
  background-color: #eee;
  border-radius: 10px;
  border: 1px solid #ccc;
  overflow: auto;
  padding: 10px;
  position: absolute;
  bottom: 1em;
  left: 50%;
  height: 100px;
  z-index: 999999;
  width: 300px;
  margin-left: -150px;
}
.pic {
  color: white;
  background-color: #ddd;
  width: 400px;
  min-height: 200px;
  position: relative;
  font-size: 30px;
  margin-top: 0 !important;
  max-width: 100%;
  overflow: hidden;
}
.pic.uploading p {
  position: relative;
  top: 45%;
  font-weight: bold;
  text-align: center;
}
.refphotoindicator {
  display: block;
  position: absolute;
  top: 40%;
  width: 100%;
  text-align: center;
  text-shadow: 2px 1px #000;
}
</style>
<div class=clearfix id=topbar>
  <button type=button id=UploadZipBut style='display:none;' class="btn btn-default pull-right"><span class="glyphicon glyphicon-cloud-upload" aria-hidden="true"></span> upload zip</button> 
  <a href="post.jsp?postId=<%=p.postId%>" class="btn btn-default pull-left"><span class="glyphicon glyphicon-menu-left" aria-hidden="true"></span>
 post</a>
  <h1>Upload picture set</h1>
</div>
<%=wu.popNotifications()%>

<h2 align=center><%= WebUtil.esc(p.postName) %></h2>


<% if (p.flagged) { %>
  <div class='alert alert-danger alert-dismissible' role='alert'><button type=button class=close data-dismiss=alert aria-label=Close><span aria-hidden=true>&times;</span></button><strong>This pictureset has been flagged and is currently hidden from the public. Please update the pictures or delete the record. If this pictureset was flagged by mistake, please uncheck the flagged checkbox below and click save.</strong></div>
<% } %>

<div align=center style='max-width:800px; margin: auto;'>

<%=p.getPicWidget("N")%>
<%=p.getPicWidget("NE")%>
<%=p.getPicWidget("E")%>
<%=p.getPicWidget("SE")%>
<%=p.getPicWidget("S")%>
<%=p.getPicWidget("SW")%>
<%=p.getPicWidget("W")%>
<%=p.getPicWidget("NW")%>
<%=p.getPicWidget("UP")%>

<form method=post style='margin-top:10px;'>
<input type=hidden name=id value='<%=WebUtil.esc(wu.param("id"))%>'>

<div class=form-group>
<label for=annotation>date taken
<br>
<input type=datetime-local class="form-control" name=picture_set_timestamp value="<%=WebUtil.esc(p.picture_set_timestamp)%>">
</label>
</div>

<div class=form-group>
<label for=annotation>photographer note</label>
<textarea class="form-control" id=annotation name=annotation style='width:98%; height: 6em;'><%=WebUtil.esc(p.annotation)%></textarea>
</label>
</div>

<% if (sessionuser.getAdmin() || sessionuser.getPersonId() == post_owner) {%>
<p>
  <% if (! p.flagged) { %>
  <label class="btn btn-default"><input type=checkbox name=makerefpicset value="1"<%=("1".equals(wu.param("makerefpicset"))?" checked":"")%>> make reference pictureset</label>
  <% } %>
  <% if (p.flagged) { %>
<label class="btn btn-default"><input type=checkbox name=flagged value="1"<%=(p.flagged?" checked":"")%>> flag</label>
  <% } %>
<% } %>

<div class=justify>
  <span><a href="post.jsp?postId=<%=p.postId%>" class="btn btn-default">cancel</a></span>
  <span><button class="btn btn-danger" type=submit name=act value=delete>delete</button></span>
  <span><button class="btn btn-primary" type=submit name=act value=save>save</button></span>
</div>

</form>
</div>

<script src=js/load-image.all.min.js></script>
<script>
var post_id = <%= p.postId %>;
var picset_id = <%= p.picSetId %>;

var MAX_WIDTH = 4096;
var MAX_WIDTH_SLOW_CONNECTION = 1024;
var uploadSpeedVerified = false;
var CHECK_UPLOAD_SPEED_MS = 5000;
var CHECK_UPLOAD_SPEED_PERCENT = 5;

$("input[type=file]").change(function(e){
  $("#UploadZipBut").hide();
  var $e = $(this);
  var file = e.target.files[0];
  var $but = $(this).prev();
  var $uploadmsg = $(this).closest('.picpanel').find('.uploadmsg');
  $uploadmsg.addClass("inprogressupload").text("uploading 0%").show();
  var orientation = $e.attr("data-orientation");

  loadImage.parseMetaData(file, function(data) {
    var opts = { maxWidth: MAX_WIDTH, canvas: true };
    var exif;
    var lastProgress = 0;
    if (data.exif) {
      exif = data.exif.getAll();

      // if pictureset timestamp is not yet assigned, assign it to date in picture metadata
      var dt = $("input[name=picture_set_timestamp]").val();
      if (dt == '' || /1970/.test(dt)) {
        dt = exif.DateTimeOriginal || exif.DateTime;
        if (/^(\d\d\d\d)\D(\d\d)\D(\d\d)\D(\d\d)\D(\d\d)/.test(dt)) {
          dt = RegExp.$1 + '-' + RegExp.$2 + '-' + RegExp.$3 + 'T' + RegExp.$4 + ':' + RegExp.$5; 
          $("input[name=picture_set_timestamp]").val(dt);
          $.ajax({ type: 'post', data: { act: 'setdt', picture_set_timestamp: dt }});
        }
      }

      opts.orientation = data.exif.get('Orientation');
    }
    loadImage(file, function(img) {
      if (img.type == "error") {
        alert("could not load img");
        return;
      }

      if (img.width < img.height) {
        var rv = confirm("Are you sure you want to upload in portrait format? We prefer landscape format (turn camera 90 degrees).");
        if (! rv) {
          $uploadmsg.empty().removeClass("inprogressupload").hide();
          return false;
        }
      }

      var $xhr = $.ajax({
        type: 'post',
        data: {
          act: "upload",
          picset: picset_id,
          photo: img.toDataURL("image/jpeg").replace(/^[^\,]*\,/,''),
          orientation: orientation,
          exif: JSON.stringify(exif),
          fn: $e.val()
        },
        xhr: function() {
          var xhr = $.ajaxSettings.xhr();
          xhr.upload.onprogress = function(e) {
            var p = (e.total > 0) ? Math.round(e.loaded/e.total*100) : 0;
            if (p == lastProgress) return;
            lastProgress = p;
            $uploadmsg.text('uploading ' + p + '%');
          };
          return xhr;
        },
        success: function(d) {
          //console.log(["upload complete", d]);
          if (/picture_id\=(\d+)/.test(d)) {
            var id = RegExp.$1; 
            $but.closest('.picpanel').find('.pic').html('<img src="/images/pictures/post_'+post_id+'/picture_'+id+'_medium.jpg" class=realphoto>');
            $uploadmsg.removeClass("inprogressupload").text('upload successful').fadeOut();
          } else {
            $uploadmsg.removeClass("inprogressupload").text('upload error').delay(5000).fadeOut();
          }
        },
        error: function() {
          $uploadmsg.removeClass("inprogressupload").text('upload error').delay(5000).fadeOut();
        }
      });

      // if upload speed is slow, downgrade image quality
      if (! uploadSpeedVerified) {
        uploadSpeedVerified = true;
        setTimeout(function(){
          if (lastProgress < CHECK_UPLOAD_SPEED_PERCENT) {
            $xhr.abort();
            MAX_WIDTH = MAX_WIDTH_SLOW_CONNECTION;
            $e.change();
          }
        }, CHECK_UPLOAD_SPEED_MS);
      }
    }, opts);
  });
});


$("button[value=save]").click(function(e){
  if ($(".refphotoindicator").length>0) {
    var rv = confirm("You have not uploaded all pictures. Are you sure you are done?");
    if (! rv) {
      e.preventDefault();
      return;
    }
  }
});

function enableNavAlert() {
  var msg = "Your picture set is not complete. Are you sure you want to leave?";
  $('body').on("click.navAlert", "a", function(e){
    if (confirm(msg)) {
      disableNavAlert();
    } else {
      e.preventDefault();
    }
  });
}
function disableNavAlert() {
  $('body').off("click.navAlert");
}

<% if (! p.ready) { %>
  enableNavAlert();
<% } %>


// if no photos have been uploaded, show upload zip button
if ($(".realphoto").length==0) {
  // when upload zip is clided, delete this pictureset and replace the current page eith batchUpload.jsp
  $("#UploadZipBut").show().click(function(){
    $.ajax({
      type:'post',
      data: {
        id: picset_id,
        act: 'delete'
      },
      success: function(){
        location.replace('batchUpload.jsp?postId='+post_id);
      }
    });
  });
}
</script>
<%@ include file="/includes/footer.jsp" %>
