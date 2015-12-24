$(document).on("click", ".SelectLocationWidget", function() {
  var $p = $(this).parent();
  var $lat = $p.find("[name=lat],.lat");
  var $lon = $p.find("[name=lon],.lon");
  var $modal = $("<div style='z-index:9999999;background-color:#eee;position:fixed;width:100%;height:100%;top:0;left:0;'><iframe src='/locpicker/widget.html#lat="+escape($lat.val())+"&lon="+escape($lon.val())+"' style='width:100%;height:100%;'></iframe><button style='position:absolute;top:6px;right:6px;' class=CloseBut>x</button></div>").appendTo(document.body);
  $modal.children('iframe')[0].setloc = function(lat,lon){
    $lat.val(lat);
    $lon.val(lon);
  };
  $modal.find('.CloseBut').click(function(){ $modal.remove(); });
});
