function escape_html(x) {
  if (x==undefined||x==null) x='';
  return x.toString()
    .replace(/&/g,'&amp;')
    .replace(/>/g,'&gt;')
    .replace(/</g,'&lt;')
    .replace(/"/g,'&quot;');
}


function hasNativeAppSupport() {
  return /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;
}

if (window.FACEBOOK_APP_ID) {
  if ($('#facebook-jssdk').length==0) {
    $.getScript('//connect.facebook.net/en_US/sdk.js', function(){
      FB.init({ appId: FACEBOOK_APP_ID, xfbml:true, version:'v2.4' });
      $(document).trigger({ type: 'facebookinit' });
    });
  }
}

$(function(){
  $("#SearchBox,#SearchBoxMobile").change(function(){
    location='/news.jsp?q='+escape(this.value); 
    this.value='';
  });

  var v = $.trim($("input[name=q]").val());
  if (v != '') {
    $("#SearBox,#SearchBoxMobile").val(v).focus();
  }
});

(function(){
  var lpad = function(val,len,ch) {
    val=String(val);
    ch=String(ch);
    while (val.length < len) {
      val=ch+val;
    }
    return val;
  }
  var normalizeDate = function(v) {
    v = $.trim(v);
    if (v=='') return v;

    var mon, day, year;
    if (/^(20\d+)[\-\/](\d\d?)[\-\/](\d\d?)$/.test(v)) {
      year = parseInt(RegExp.$1,10);
      mon = parseInt(RegExp.$2,10);
      day = parseInt(RegExp.$3,10);
    } else if (/^(\d\d?)[\-\/](\d\d?)[\-\/](\d\d\d\d)$/.test(v)) {
      year = parseInt(RegExp.$3,10);
      mon = parseInt(RegExp.$1,10);
      day = parseInt(RegExp.$2,10);
    } else if (/^(\d\d?)[\-\/](\d\d?)[\-\/](\d\d?)$/.test(v)) {
      year = parseInt('20'+RegExp.$3,10);
      mon = parseInt(RegExp.$1,10);
      day = parseInt(RegExp.$2,10);
    } else {
      throw "invalid date";
    }

    var daysInMon;
    switch(mon) {
      case 2: daysInMon=((year%4==0 && year%100) || year%400==0)?29:28; break;
      case 9: case 4: case 6: case 11: daysInMon=30; break;
      default: daysInMon=31;
    }
    if (mon > 12 || day > daysInMon) throw("invalid date");
    return lpad(year,4,0)+'-'+lpad(mon,2,0)+'-'+lpad(day,2,0);
  }
  var normalizeTime = function(v) {
    v = $.trim(v);
    var h, mi;
   if (/^(\d\d?)\:(\d\d?)/i.test(v)) {
     h = parseInt(RegExp.$1,10); 
     mi = parseInt(RegExp.$2,10); 
   } else {
     throw "invalid time";
   }
   if (/p/i.test(v)) h+=12; 
   if (h > 23 || mi > 59) throw("invalid time");
   return lpad(h,2,0) + ':' + lpad(mi,2,0);
  }
  var normalizeDateTimeLocal = function(v) {
    v = $.trim(v);
    if (v=='') return v;
    v=v.split(/[\ T]+/);
    if (v.length==1) v[1]='00:00';
    v[0]=normalizeDate(v[0]);
    v[1]=normalizeTime(v[1]);
    return v[0]+'T'+v[1];
  }
  $(document).on("change", "input[type=date]", function(){
    try {
      this.value=normalizeDate(this.value);
    } catch(e) {
      alert("enter date in format yyyy-mm-dd");
    }
  });
  $(document).on("change", "input[type=datetime-local]", function(){
    try {
      this.value=normalizeDateTimeLocal(this.value);
    } catch(e) {
      alert("enter date-time in format yyyy-mm-ddT23:59");
    }
  });
})();
