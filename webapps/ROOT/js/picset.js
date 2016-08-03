
// monkey patch for issue: https://github.com/blueimp/JavaScript-Load-Image/pull/81
loadImage.ExifMap.prototype.getText = function (id) {
  var value = this.get(id)
  if (value==undefined) return "";

  switch (id) {
    case 'LightSource':
    case 'Flash':
    case 'MeteringMode':
    case 'ExposureProgram':
    case 'SensingMethod':
    case 'SceneCaptureType':
    case 'SceneType':
    case 'CustomRendered':
    case 'WhiteBalance':
    case 'GainControl':
    case 'Contrast':
    case 'Saturation':
    case 'Sharpness':
    case 'SubjectDistanceRange':
    case 'FileSource':
    case 'Orientation':
      return this.stringValues[id][value]
    case 'ExifVersion':
    case 'FlashpixVersion':
      return String.fromCharCode(value[0], value[1], value[2], value[3])
    case 'ComponentsConfiguration':
      return this.stringValues[id][value[0]] +
      this.stringValues[id][value[1]] +
      this.stringValues[id][value[2]] +
      this.stringValues[id][value[3]]
    case 'GPSVersionID':
      return value[0] + '.' + value[1] + '.' + value[2] + '.' + value[3]
  }
  return String(value)
};



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
          $.ajax({ type: 'post', data: { id: picset_id, act: 'setdt', picture_set_timestamp: dt }});
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
        complete: function(xhr, txtstatus) {
          var msg;
          if (txtstatus == 'success' && /picture_id\=(\d+)/.test(xhr.responseText)) {
            var id = RegExp.$1; 
            $but.closest('.picpanel').find('.pic').html('<img src="/images/pictures/post_'+post_id+'/picture_'+id+'_medium.jpg" class=realphoto>');
            msg = 'upload successful';
          } else {
            msg = 'upload errror: ' + txtstatus + '; ' + xhr.responseText;
          }
          $uploadmsg.removeClass("inprogressupload").text(msg).delay(5000).fadeOut();
          $e.val(''); // clear filename
        },
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

$("input[name=picture_set_timestamp]").change(function(){
  $("#verifydatetaken").prop('checked',true);
});

// if picset not ready, install some alerts
if ($("form").attr("data-ready") == "false") {
  var msg = "Your picture set is not complete. Are you sure you want to leave?";
  $('body').on("click.navAlert", "a", function(e){
    if (confirm(msg)) {
      $('body').off("click.navAlert");
    } else {
      e.preventDefault();
    }
  });

  $("button[value=save]").click(function(e){
    if ($("#verifydatetaken:checked").length==0) {
      alert("Please verify the date taken field.");
      e.preventDefault();
      $("#verifydatetaken").focus();
      return;
    }
  });
}

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
