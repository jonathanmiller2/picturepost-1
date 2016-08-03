<html>
<head>
<title>Greenness Analysis</title>
	<script type="text/javascript" src="USMscripts/src/scripts/windowGreennessAnalysis.js"></script>
	<script type="text/javascript" src="USMscripts/src/scripts/ROIScript.js"></script>
	<script type="text/javascript" src="USMscripts/src/scripts/FileSaver.js"></script>
	<script type="text/javascript" src="USMscripts/src/scripts/Blob.js"><script>

	<script type="text/javascript" src="USMscripts/src/plugins/dist/excanvas.min.js"></script>
        <script type="text/javascript" src="USMscripts/src/plugins/dist/jquery.min.js"></script>
        <script type="text/javascript" src="USMscripts/src/plugins/dist/jquery.jqplot.min.js"></script>

	<script type="text/javascript" src="USMscripts/src/plugins/dist/plugins/jqplot.canvasTextRenderer.min.js"></script>
        <script type="text/javascript" src="USMscripts/src/plugins/dist/plugins/jqplot.canvasAxisLabelRenderer.min.js"></script>
        <script type="text/javascript" src="USMscripts/src/plugins/dist/plugins/jqplot.highlighter.min.js"></script> 
        <script type="text/javascript" src="USMscripts/src/plugins/dist/plugins/jqplot.cursor.min.js"></script> 
        <script type="text/javascript" src="USMscripts/src/plugins/dist/plugins/jqplot.dateAxisRenderer.min.js"></script>
        <script type="text/javascript" src="USMscripts/src/plugins/dist/plugins/jqplot.canvasAxisTickRenderer.min.js"></script>
        <script type="text/javascript" src="USMscripts/src/plugins/dist/plugins/jqplot.enhancedLegendRenderer.min.js"></script>
        <script type="text/javascript" src="USMscripts/src/plugins/BrowserDetect.js"></script>
        <script type="text/javascript" src="USMscripts/src/plugins/jQueryRotate.2.2.js"></script>
        
        <script type="text/javascript" src="USMscripts/src/plugins/uiminified/jquery-ui.min.js"></script>
        <script type="text/javascript" src="USMscripts/src/plugins/uiminified/jquery.ui.selectable.min.js"></script>
	<script type="text/javascript">
	var xhr;

	if (window.XMLHttpRequest) {
	    xhr = new XMLHttpRequest();
	}
	else {
	    xhr = new ActiveXObject("Microsoft.XMLHTTP");
	}

	</script>

	<link rel='stylesheet' type='text/css' href='USMscripts/src/plugins/dist/jquery.jqplot.css'>
	<link rel='stylesheet' type='text/css' href='USMscripts/src/plugins/dist/jquery.jqplot.min.css'>
	<link rel='stylesheet' type='text/css' href='USMscripts/src/stylesheets/PopupStyle.css'>
	<style>
    body {
      font-family: sans-serif;
    }
	#headermenu a {
		color: #003366;
		text-decoration: none;
		margin: 6px;
	} 
	#header a:hover, #header a:active {
		color: #FFCC66;
	}

    #footlinks {
      color: #eee;
      margin-top: 2em;
      text-align: center;
    }
    #footlinks a {
      color: #666;
      font-size: 12px;
      text-decoration: none;
    }
    
	</style>

</head>

<body onload="GreennessAnalysis()">

<div class="imageCanvas">
  <canvas id="imagecanvas" width="400px" height="300px" style="position: relative; z-index: 0; left: 50%; padding-top: 25px;  margin-left: -200px; display: block;"></canvas>
</div>

<div id="loadingDiv"  style="padding-top: 20px;">
<img class="rotate" id="loadicon" src="USMscripts/src/SiteImages/PicturePostLoadAll.png" alt="Loading Icon" width="50px" height="50px" style="display: block; margin: 0 auto;" />
<p id="loadingText" style="text-align: center;"></p>
</div>

<div id="chartdiv" style="width:900px; display: none; margin-left: auto; margin-right: auto; margin-top:13em;">
  <div id="cd"></div>	
</div>

<H3 align="center" style="color:#003366">Click below to save the image or save the data.</H3>
<p align="center" style="color:#003366">Your download will begin immediately.</p>
<div id=footlinks>
<a id="generateGraphLink" title="Save Graph as an Image" href="#" onclick="getGraphAsImage();return false;">save image</a> |
<a id="generateCSVLink" title="Save Data as a CSV" href="#" onclick="getGraphAsCSV();return false">save data</a>
</div>

</body>
</html>
