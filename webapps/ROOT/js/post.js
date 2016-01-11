(function(){
  
  var orientation = /orientation\=(\w+)/.test(location.hash) ? RegExp.$1 : 'N';
  var currentPostIdx = 0;
  var currentIdx = picsets.length - 1; // default to last picset
  var piclinks = [];

  var defaultPlaySpeed=2000;
  var playSpeed = defaultPlaySpeed;
  
  var picset_id_idx_map = {}; // picset_id: idx in picsets
  (function() {
    var picset_id = /picset\=(\d+)/.test(location.hash) ? RegExp.$1 : null;
    for (var idx=picsets.length - 1; idx>=0; --idx) {
      var id = picsets[idx][0].toString();
      picset_id_idx_map[id] = idx;
      
      // if picset_id on lochash matches, remember as currentIdx  
      if (picset_id == id) {
        currentIdx = idx;

        // make sure the selected orientation exists, otherwise choose a different one
        var x = picsetRec(picsets[idx]); 
        var os = ['N','NE','E','SE','S','SW','W','NW','UP'];
        for (var i=0, l=os.length; i<l; ++i) {
          var o = os[i]; 
          var picid = x[o];
          if (picid > 0) {
            orientation = o;
            break;
          }
        }
      }
    }
  })();

  
  // convert a picset array to object
  function picsetRec(x) {
    return {
      id:x[0], dt:x[1],
      N:x[2], NE:x[3], E:x[4], SE:x[5], S:x[6], SW:x[7], W:x[8], NW:x[9], UP:x[10],
      annotation: x[11],
      photographer: x[12]
    };
  }

  function lpad(val,num_digits,ch) {
    if (ch=='') ch = '0';
    val = ''+val;
    while (val.length < num_digits) {
      val = ch+val;
    }
    return val;
  }

  $('#picposttimeslider').click(function(e) {
    var $t = $(e.target);
    if ($t.is('a')) return;
    if (! $t.is('div')) $t=$t.closest('div');
    $t.find('a:first').click(); 
  });

  // when user clicks the orientation button, change the orientation
  $('#picpostdir a').click(function(e) {
    e.preventDefault();
    if (/ppdir(\w+)/.test(this.id)) {
      orientation = RegExp.$1;
      $(this).addClass('active').siblings('.active').removeClass('active');
      if (piclinks.length > 0) {
        piclinks[currentIdx].click();
      }
    }
  });
  
  // when user clicks a new picset to load, load picture, update lochash
  $(document).on("click", "a.piclink", function(e) {
    e.preventDefault();
    $("a.piclink.selected").removeClass("selected").closest('.timeslideryear').removeClass('selected');
    currentIdx = parseInt($(this).attr('data-idx'));
    piclinks[currentIdx].addClass("selected").closest('.timeslideryear').addClass('selected');
    $("#PrevBut").prop('disabled', currentIdx==0);
    $("#NextBut").prop('disabled', currentIdx==piclinks.length - 1);
    updateLocHash();
    updatePic();
  })

  var playTimeout;
  function playNext() {
    if (picsets.length == 0) return;
    var i = currentIdx + 1;
    if (i >= piclinks.length) i=0;
    piclinks[i].click();
    playTimeout = setTimeout(playNext, playSpeed);
  }
  function stopPlaying() {
    if (playTimeout) {
      $("#PlayBut").find('span').removeClass('glyphicon-pause').addClass('glyphicon-play');
      clearTimeout(playTimeout);
      playTimeout=null;
    }
  }

  $("#PlayButSpeedOpts").click(function(){
    stopPlaying();
  });

  $("#PlayBut").click(function(){
    if (playTimeout) {
      stopPlaying();
    } else {
      playNext();
      $("#PlayBut").find('span').removeClass('glyphicon-play').addClass('glyphicon-pause');
    }
  });

  $("#PlayButGrp a").click(function(e){
    e.preventDefault();
    playSpeed = $(this).attr('data-speed');
    if (! playTimeout) $("#PlayBut").click(); 
  });
  
  // when user clicks the next button
  $("#NextBut").click(function(e){
    stopPlaying();
    e.preventDefault();

    if (picsets.length == 0) return;
    var i = currentIdx + 1;
    if (i >= piclinks.length) i=0;
    piclinks[i].click();
  });

  // when user clicks the prev button
  $("#PrevBut").click(function(e){
    stopPlaying();
    e.preventDefault();

    if (picsets.length == 0) return;
    var i = currentIdx - 1;
    if (i < 0) i = piclinks.length - 1;
    piclinks[i].click();
  });

  $("#ppimg")
    .on("dragstart",  function(e) { e.preventDefault(); })
    .on("swipeleft",  function(e) { $("#NextBut").click(); })
    .on("swiperight", function(e) { $("#PrevBut").click(); })
    .on('touchstart', function(e) { e.preventDefault(); });

  $(document).keydown(function(e){
    if (! $(document.activeElement).is("input,textarea,select")) {
      if (e.which==37) {
        if (e.shiftKey) {
          var $e = $("#picpostdir a.active").prev();
          if ($e.length==0) $e=$("#picpostdir a:last-child");
          $e.click();
        } else {
          $("#PrevBut").click();
        }
      } else if (e.which==39) {
        if (e.shiftKey) {
          var $e = $("#picpostdir a.active").next();
          if ($e.length==0) $e=$("#picpostdir a:first-child");
          $e.click();
        } else {
          $("#NextBut").click();
        }
      }
    }
  });

  function parseDate(dtStr) {
    var dt = null;
    if (/(\d\d\d\d)\-(\d+)\-(\d+)\ (\d+)\:(\d+)/.test(dtStr)) {
      dt = new Date(parseInt(RegExp.$1,10), parseInt(RegExp.$2,10) - 1, parseInt(RegExp.$3,10), parseInt(RegExp.$4,10), parseInt(RegExp.$5,10)); 
    }
    return dt;
  }

  function formatDate(dt) {
    var monday = dt.toDateString().replace(/\ 0/,' ');
    var am = 'AM';
    var hour = dt.getHours();
    if (hour > 12) {
      hour -= 12;
      am = 'PM';
    }
    var min = dt.getMinutes().toString().replace(/^(\d)$/, '0' + RegExp.$1);
    return monday + ' ' + hour + ':' + min + am;
  }

  // show the pic for the currentIdx
  var currentPicId;
  function updatePic() {
    var src;
    var picset = picsetRec(picsets[currentIdx]);
    var pic_id = picset[orientation];
    currentPicId = pic_id;

    // hide show orientation buttons based on what pic is defined
    $.each(['N','NE','E','SE','S','SW','W','NW','UP'], function(){
      $("#ppdir" + this).css('visibility', (picset[this] > 0) ? "visible" : "hidden");
    });

    src = (pic_id) ? "/images/pictures/post_" + post_id + "/picture_" + pic_id + "_medium.jpg" : "/images/picture_missing_medium.jpg";

    var dt = parseDate(picset.dt);

    $("#picdt").text(dt.getFullYear());
    $("#picsetEditBut").attr('href', 'picset.jsp?id='+picset.id);

    $("#picsetcaptionhtml").html("<blockquote><div id=annotation>" +escape_html(picset.annotation)+"</div><footer>"+escape_html(picset.photographer)+" on "+escape_html(formatDate(dt))+"</footer></blockquote>");
    $("#ppimg").prop("src", src);
  }

  $("#picsetcaptionhtml").click(function(){
    $("#picsetcaption").toggleClass("expanded");
  });

  function updateLocHash() {
    var picset_id = picsets[currentIdx][0];
    var lochash = '#picset=' + picset_id + '&orientation=' + orientation;
    if (lochash != location.hash) {
      history.replaceState(null,null,lochash);
    }
  }

  $("#picsetFlagBut").click(function(){
    if (! confirm("Are you sure you want to report this picture set as containing offensive material?")) return;
    $.ajax({
      type: 'post',
      data: {
        act: 'flag',
        picset_id: picsets[currentIdx][0]
      },
      success: function(d) {
        if (/ok - picset flagged/.test(d)) {
          location.replace('post.jsp?postId=' + post_id);
        } else {
          alert("Could not flag this picture set.");
        } 
      },
      error: function() {
        alert("Could not flag this picture set.");
      }
    });
  });

  $(window).on('hashchange', function() {
    var h = location.hash;
    orientation = (/orientation=(\w+)/.test(h)) ? RegExp.$1 : orientation;
    var picset_id = (/picset=(\d+)/.test(h)) ? RegExp.$1 : picsets[0][0];
    currentIdx = picset_id_idx_map[picset_id];
    $("#ppdir"+orientation).click();

    // if picset was provided automatically scroll to pictureset viewer
    if (/picset\=\d+/.test(h)) {
      $('#picsetCtrl')[0].scrollIntoView(false);
    }
  });

  $(document).on("click",".TimeSliderPrevYearBut", function(e){
    e.preventDefault();
    $(this).closest(".timeslideryear").prev().find("a.piclink:first").click();
  });
  $(document).on("click",".TimeSliderNextYearBut", function(e){
    e.preventDefault();
    $(this).closest(".timeslideryear").next().find("a.piclink:first").click();
  });

  // generate picsets / timeline
  if (picsets.length > 0) (function(){
    var monNames = ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    var lastIdx = picsets.length - 1;
    var firstYear = (/^(....)/.test(picsets[0][1])) ? parseInt(RegExp.$1) : null;
    var lastYear = (/^(....)/.test(picsets[lastIdx][1])) ? parseInt(RegExp.$1) : null;
    var buf;
    for (var year=firstYear; year <= lastYear; ++year) {
      buf += "<div class='timeslideryear isEmpty' data-year="+year+"><button type=button class='btn btn-default TimeSliderPrevYearBut'";
      if (year==firstYear) buf += " disabled";
      buf += "><span class='glyphicon glyphicon-menu-left' aria-hidden='true'></span></button><h4>" + year + "</h4><button type=button class='btn btn-default TimeSliderNextYearBut'";
      if (year==lastYear) buf += " disabled";
      buf += "><span class='glyphicon glyphicon-menu-right' aria-hidden='true'></span></button><div class='clearfix'>";
      for (var mon=1; mon<=12; ++mon) {
        buf += "<div id=m"+year+""+lpad(mon, 2, '0')+" class='btn btn-default mon isEmpty'><h5>"+monNames[mon]+"</h5></div>";
      }
      buf += "</div></div>"
    }
    var $buf = $("<div />").html(buf);
    var idx = 0;
    for (var i=0, l=picsets.length; i<l; ++i) {
      var picset = picsetRec(picsets[i]);
      var month_container_id = (/^(....)-(..)/.test(picset.dt)) ? 'm'+RegExp.$1+RegExp.$2 : '';
      var $container = $buf.find("#"+month_container_id);
      var $a = $("<a class='piclink btn btn-default' data-idx="+i+" href='#'></a>");
      piclinks[i]=$a;
      $container.append($a);
      $container.removeClass('isEmpty').closest(".timeslideryear").removeClass('isEmpty'); 
    }
    $buf.find(".timeslideryear.isEmpty").remove();
    $("#picposttimeslider").append($buf.children())
  })();

  // load a picture
  if (orientation=='post') {
    $("#ShowPostBut").click();
  } else {
    $('#ppdir'+orientation).click();
  }

  // when user clicks comment photo, load photo in viewer
  $("#picpostcomments").on("click", ".comment a", function(){
    $('#ppimg')[0].scrollIntoView();
  });

  $("#IsFavoriteCheckbox").click(function(){
    setTimeout(function(){
      $.ajax({
        type:'post',
        data: {
          act: $("#IsFavoriteCheckbox").is(':checked') ? 'setfavorite' : 'unsetfavorite'
        },
        error: function(){
          alert('could not update favorite setting');
        }
      });
    },1);
  });


  // Facebook share
  $(".shareActivePicsetOnFacebook").click(function(e){
    e.preventDefault();
    var sharelink = location.href.replace(/\?.*/,'') + '?pic=' + currentPicId;

    // open facebook share dialog
    FB.ui({
      method: 'share_open_graph',
      action_type: 'og.likes',
      action_properties: JSON.stringify({
        object: sharelink
      })
    }, function(response){
      // Debug response (optional)
      //console.log(response);
    });
  });

  ///////////////////
  // Comment system
  ///////////////////
  $("#AddPostCommentBut").click(function(){
    var picset = picsetRec(picsets[currentIdx]);
    var pic_id = picset[orientation];
    var src = "/images/pictures/post_" + post_id + "/picture_" + pic_id + "_thumb.jpg";
    $("#PostCommentPic").prop('src', src);
    $("#DeletePostCommentBut").addClass('invisible');
    $('#newcomment').val('');
    $("#postcommentform")
      .data('rec', { pic_id: pic_id })
      .show();
  });

  $('#usercomments').on("click",".EditCommentBut",function(e) {
    e.preventDefault();
    var pic_id = $(this).attr('data-pic_id');
    var src = "/images/pictures/post_" + post_id + "/picture_" + pic_id + "_thumb.jpg";
    $("#PostCommentPic").prop('src', src);
    $("#DeletePostCommentBut").removeClass('invisible');
    $('#newcomment').val($(this).closest('.picusercomment').find('.commenttext').text());
    $("#postcommentform")
      .data('rec', { comment_id: $(this).attr('data-comment_id') })
      .show();
  });

  $("#CancelPostCommentBut").click(function(){
    $("#postcommentform").hide();
  });

  $("#SavePostCommentBut").click(function(){
    var rec = $("#postcommentform").data('rec');
    rec.act = 'savecomment';
    rec.text = $('#newcomment').val();
    $.ajax({
      type:'post',
      data: rec,
      success: function(d) {
        if (/^ok/.test(d)) {
          $("#postcommentform").hide();
          $('#usercomments').load('?postId='+post_id+' #usercomments');
        } else {
          alert('Could not save comment. Have you already commented on this picture? You can edit your existing comment.');
        }
      },
      error: function(){
        alert('could not save comment');
      }
    });
  });
  $("#DeletePostCommentBut").click(function(){
    $('#newcomment').val('');
    $("#SavePostCommentBut").click();
  });

})();

// present drop up arrow when date widget is open
$(document).on("click", '#picdtwidget > a', function(){
  var $e = $(this);
  if ($e.attr("aria-expanded") == "false") {
    $e.removeClass("dropup");
  } else {
    $e.addClass("dropup");
  }
});

$("#PrevPostPhoto,#NextPostPhoto").click(function(){
  var $img = $(this).parent().prev();
  var ids = JSON.parse($img.attr('data-pics'));
  var delta = (/Next/.test(this.id)) ? 1 : -1;
  var i = parseInt($img.attr('data-i')) + delta;
  if (i < 0) i = ids.length - 1;
  else if (i >= ids.length) i = 0;
  $img.attr('data-i', i);
  var src = $img.prop('src').replace(/picture_\d+/,'picture_'+ids[i]);
  $img.prop('src', src);
});


