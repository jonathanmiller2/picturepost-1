<%@ include file="/includes/common.jsp" %>
<%@ include file="/includes/header.jsp" %>
<style>
h3 {
  margin-bottom: 5px;
}

div#nearbypost {
  /* border-bottom: solid 1px black; */
}

div.postdesc {
  padding: 10px;
  margin-bottom: 5px;
  background-color: #eee;
  overflow: auto;
} 

img.post_picture {
  width: 100px; float: left;
  margin: 8px;
  margin: 0 8px 8px 0;
} 
hr.post_picture {
  clear: left;
}
</style>


<div id=topbar class=clearfix>
  <h1>Picture Posts Nearest to Me</h1>
</div>


<script type="text/javascript">
function outputLocation(lat, lon) {
  $.get("locations.jsp",
    {'lat':lat, 'lon':lon},
    function(data) {
      console.log(data);
      $("#posts").html(data);
    });

  console.log("(lat,lon) = ("+lat+","+lon+")");
  $("#location").html("("+Math.round(lat*1000)/1000+","+Math.round(lon*1000)/1000+")");
}

function getLocationSuccess(position) {
      outputLocation(position.coords.latitude, position.coords.longitude);
}
function getLocationError() {
  console.log("Unable to retrieve your location");
}

$("document").ready(  function() {
  if ("geolocation" in navigator) {
    /* geolocation is available */
    
    navigator.geolocation.getCurrentPosition(
      getLocationSuccess,
      getLocationError
    );
  } else {
    /* geolocation IS NOT available */
    alert('GeoLocation not supported in your browser');
  }


});
</script>

<div>Your latitude/longitude is: <span id='location'>Location</span></div>
<div id='posts'>Posts</div>
