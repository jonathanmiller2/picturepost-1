<%@ include file="/includes/common.jsp" %>
<%
String sql = "SELECT post_id, ST_Y(location) lat, ST_X(location), name lon FROM post WHERE ready=true";
PreparedStatement stmt = wu.dbh().prepareStatement(sql);
ResultSet rs = stmt.executeQuery();
String postsJSON = WebUtil.dbJsonArray(rs).toString();

String GMAPS_API_KEY = Config.get("GOOGLE_MAPS_KEY");
%>
<%@ include file="/includes/header.jsp" %>

<script async defer src="https://maps.googleapis.com/maps/api/js?key=<%=GMAPS_API_KEY%>&callback=initMap" type="text/javascript"></script>
<script src=js/markercluster.js></script>
<script>
function initMap() {
var posts = <%=postsJSON%>;

$(window).resize(function(){
  $("#mapCanvas").css({ height: $(window).height() - 50, width: $(window).width() });
});

$(function(){
  $(window).resize();

  var lat=43.3, lng=-100.5, zoom=3;
  if (/\#([\d\.\-]+),([\d\.\-]+),(\d+)/.test(location.hash)) {
    lat = parseFloat(RegExp.$1);
    lng = parseFloat(RegExp.$2);
    zoom = parseInt(RegExp.$3,10);
  }

  var map = new google.maps.Map(document.getElementById('mapCanvas'), {
    zoom: zoom,
    center: new google.maps.LatLng(lat, lng),
    mapTypeId: google.maps.MapTypeId.ROADMAP
  });

  google.maps.event.addListener(map, 'center_changed', function(){
    var c = map.getCenter();
    var h = '#'+c.lat()+','+c.lng()+','+map.getZoom();
    history.replaceState(null,null,h);
  });
    
  var infowindow = new google.maps.InfoWindow();

  var markers = posts.map(function(post) {
    var post_id = post[0];
    var lat = post[1];
    var lon = post[2];
    var name = post[3];
    var marker = new google.maps.Marker({
      position: new google.maps.LatLng(lat, lon),
      title: name
    });
    google.maps.event.addListener(marker, 'click', function() {
      infowindow.setContent("<strong>view post:</strong> <a href=/post.jsp?postId="+post_id+">" + escape_html(name) + "</a>");
      infowindow.open(map, marker);
    });
    return marker; 
  });

  var markerCluster = new MarkerClusterer(map, markers);
});
}
</script>
<style>
body {
  margin: 0;
  height: 100%;
  font-family: sans-serif;
}
#mapContainer {
  position: fixed;
  top: 50px;
  bottom: 0;
  left: 0;
  right: 0;
}
</style>
<div id=mapContainer>
  <div id="mapCanvas"></div>
</div>
<%@ include file="/includes/footer.jsp" %>
