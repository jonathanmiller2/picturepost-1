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
