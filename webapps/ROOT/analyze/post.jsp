<%@ include file="/includes/common.jsp" %>

<%
String newline = System.getProperty("line.separator");

String[] orientations = {"N", "NE", "E", "SE", "S", "SW", "W", "NW", "UP" };
NumberFormat nf = NumberFormat.getInstance();
nf.setMinimumFractionDigits(6);
nf.setMaximumFractionDigits(6);
%>

<%
// Make sure we have a valid postId.
int postId = 0;
try {
    postId = Integer.parseInt(Utils.cleanup(request.getParameter("postId")));
}
catch (Exception e) { }
if (!Post.dbIsValidPostId(postId)) {
    //Log.writeLog("ERROR, " + request.getRequestURI() + ": Invalid postId, " + String.valueOf(postId));
    response.sendRedirect("/index.jsp");
    return;
}
Post post = new Post(postId);
%>

<%
// Deal with paging.
int numPerPage = 50;
try {
    numPerPage = Integer.parseInt(Utils.cleanup(request.getParameter("numPerPage")));
}
catch (Exception e) { }

int curPage = 0;
try {
    curPage = Integer.parseInt(Utils.cleanup(request.getParameter("curPage")));
}
catch (Exception e) { }

int totalPictureSetRecords = post.dbGetNumViewablePictureSetRecords();
int numPages               = post.dbGetNumViewablePictureSetPages(numPerPage);

if (curPage >= numPages) {
    curPage = 0;
}
else if (curPage < 0) {
   curPage = 0;
}

// Get a vector of PictureSets for this Post for this page.
Vector<PictureSet> pictureSetRecords = post.dbGetViewablePictureSetRecords(numPerPage, curPage);

// Generate a string of pictureSetIds for auto scroll.
String pictureSetIdString = "";
if (!pictureSetRecords.isEmpty()) {
    pictureSetIdString = String.valueOf(pictureSetRecords.get(0).getPictureSetId());
    for (int i = 1; i < pictureSetRecords.size(); i++) {
        pictureSetIdString += "," + String.valueOf(pictureSetRecords.get(i).getPictureSetId());
    }
}
%>

<%
// Is there a specific pictureId we want to start with?
// If so, and it's on the curPage, use that.
// If not, then start with the first picture from the first pictureSet of the curPage.
int curPictureId = 0;
try {
    curPictureId = Integer.parseInt(Utils.cleanup(request.getParameter("curPictureId")));
}
catch (Exception e) { }

// OK, we have a curPictureId.  Make sure it's on this page.
if (curPictureId != 0) {
    if (!Picture.dbIsValidPictureId(curPictureId)) {
        curPictureId = 0;
        Log.writeLog("ERROR, " + request.getRequestURI() + ": Invalid curPictureId, " + String.valueOf(curPictureId));
    }
    else {
        if (!pictureSetRecords.contains(new PictureSet(new Picture(curPictureId).getPictureSetId()))) {
            curPictureId = 0;
        }
    }
}

// If we get to this point without a curPictureId, set it to the first picture on this page (if there are any pictures).
if (curPictureId == 0 && pictureSetRecords.size() > 0) {
    for (int x = 0; x < orientations.length; x++) {
        if (PictureSet.pictureRecordExists(pictureSetRecords.get(0), orientations[x])) {
            curPictureId = PictureSet.getPictureRecord(pictureSetRecords.get(0), orientations[x]).getPictureId();
            break;
        }
    }
}

// Which color algorithm is selected?
String algorithm = Utils.cleanup(request.getParameter("algorithm"));
if (algorithm.equals("")) {
    algorithm = "ORIGINAL";
}

// Which pictureOption is selected?
String pictureOptions = Utils.cleanup(request.getParameter("pictureOptions"));
if (!pictureOptions.equals("metadata") && !pictureOptions.equals("satelliteTrueColor")) {
    pictureOptions = "satelliteTrueColor";
}
%>
<%@ include file="/includes/header.jsp" %>
<script>
var xhr;

if (window.XMLHttpRequest) {
    xhr = new XMLHttpRequest();
}
else {
    xhr = new ActiveXObject("Microsoft.XMLHTTP");
}

USManalyze = false;
var postId = '<%=String.valueOf(post.getPostId())%>';
var orientationArray = [0, 0, 0, 0, 0, 0, 0, 0, 0];
var onlyOneOrientation = true;
var firstLoadOrientation = true;
var curPictureId = 0;
var pictureOrientation = "";
var pictureSetTimestamp = "";
var metadata  = "";
var centerLat = "<%=post.getLat()%>";
var centerLon = "<%=post.getLon()%>";
var postLat   = "<%=post.getLat()%>";
var postLon   = "<%=post.getLon()%>";
var zoom = "1";
var layerNamePrefix = "";
var pictureSetAnnotation = "";
var autoScrollPictureIndex = 0;

var oldPictureId = "";

function AutoScrollPicture(pictureId, pictureSetTimestamp, image) {
    this.pictureId = pictureId;
    this.pictureSetTimestamp = pictureSetTimestamp;
    this.image = image;
}
var autoScrollPictures = new Array();
var intervalId = 0;
var autoScrollDirection;

function htmlEscape(s) {
    s = s.replace(/&/g, "&amp;");
    s = s.replace(/</g, "&lt;");
    s = s.replace(/>/g, "&gt;");
    s = s.replace(/"/g, "&quot;");
    s = s.replace(/'/g, "&apos;");
    return s;
}

function selectPicture(pictureId)
{
	<%-- Need to include picture's column to ensure only one plot is plotted --%>
	$("#picture_" + pictureId).removeClass("thumbnail-default");
	$("#picture_" + pictureId).addClass("thumbnail-focus");

	if (document.getElementById("pictureOptionsAnalyze").checked) {
		addOrientation(pictureId);
	}
	if (firstLoadOrientation) {
		addOrientation(pictureId);
		firstLoadOrientation = false;
	}
}


function deselectPicture(pictureId)
{
	$("#picture_" + pictureId).removeClass("thumbnail-focus");
        $("#picture_" + pictureId).addClass("thumbnail-default");

	// If Analysis is running then need to remove a point for the pictures orientation - Ryan Turner - USM Campus Ventures
	if (document.getElementById("pictureOptionsAnalyze").checked) {
		removeOrientation(pictureId);
	}
}

/* Following functions for keeping 
 * track of columns that contain selected images
 *
 * Ryan Turner - USM Campus Ventures - Summer 2014
 */

// Adds to the amount of pictures selected in a particular column
function addOrientation(pictureId) {

	// Element of picture for checking its class values
	var pictureElement = $("#picture_" + pictureId);
	
	// Determines which orientation class the picture has
	// Couldn't do switch statement as each image has more than one class
	if(pictureElement.hasClass('orientation-N-')) {
		orientationArray[0]++;
	} else if (pictureElement.hasClass('orientation-NE-')) {
		orientationArray[1]++;
	} else if (pictureElement.hasClass('orientation-E-')) {
		orientationArray[2]++;
	} else if (pictureElement.hasClass('orientation-SE-')) {
		orientationArray[3]++;
	} else if (pictureElement.hasClass('orientation-S-')) {
		orientationArray[4]++;
	} else if (pictureElement.hasClass('orientation-SW-')) {
		orientationArray[5]++;
	} else if (pictureElement.hasClass('orientation-W-')) {
		orientationArray[6]++;
	} else if (pictureElement.hasClass('orientation-NW-')) {
		orientationArray[7]++;
	} else if (pictureElement.hasClass('orientation-UP-')) {
		orientationArray[8]++;
	}
}

// Removes from the amount of pictures selected in a particular column
function removeOrientation(pictureId) {
	var pictureElement = $("#picture_" + pictureId);
	
	if(pictureElement.hasClass('orientation-N-')) {
		orientationArray[0] = orientationArray[0] - 1;;
	} else if (pictureElement.hasClass('orientation-NE-')) {
		orientationArray[1] = orientationArray[1] - 1;
	} else if (pictureElement.hasClass('orientation-E-')) {
		orientationArray[2] = orientationArray[2] - 1;
	} else if (pictureElement.hasClass('orientation-SE-')) {
		orientationArray[3] = orientationArray[3] - 1;
	} else if (pictureElement.hasClass('orientation-S-')) {
		orientationArray[4] = orientationArray[4] - 1;
	} else if (pictureElement.hasClass('orientation-SW-')) {
		orientationArray[5] = orientationArray[5] - 1;
	} else if (pictureElement.hasClass('orientation-W-')) {
		orientationArray[6] = orientationArray[6] - 1;
	} else if (pictureElement.hasClass('orientation-NW-')) {
		orientationArray[7] = orientationArray[7] - 1;
	} else if (pictureElement.hasClass('orientation-UP-')) {
		orientationArray[8] = orientationArray[8] - 1;
	}
}

// Checks if a picture is selected in more than one column
function checkOrientations() {
	// Counter for keeping track of number of columns selected
	var counter = 0;

	for (var i = 0; i < orientationArray.length; i++) {
		if (orientationArray[i] > 0) {
			counter++;
		}
	}
	// If more than 1 column has a selected image set boolean and display an alert to user else set boolean and return to analysis
	if (counter > 1) {
		alert("Analysis can only be done on one orientation at a time. Please correct your image selection and try again.");
		onlyOneOrientation = false;
	} else {
		onlyOneOrientation = true;
	}
}

/*** END COLUMN TRACKING FUNCTIONS ***/

function viewPicture(pictureId) {
    // If in analysis mode then deselection of an image is handled differently - Ryan Turner - USM Campus Ventures - Summer 2014
    if (document.getElementById("pictureOptionsAnalyze").checked){
   	if($("#picture_" + pictureId).attr('class').indexOf("thumbnail-focus") >= 0)
   	{
		deselectPicture(pictureId);
		return;	
    	}
    
    } else {
	// If analysis mode is not selected keeps only one image selected at a time - Ryan Turner - USM Campus Ventures - Summer 2014
	if (curPictureId != 0) {
		deselectPicture(curPictureId);
	}
    }

    
    stopAutoScroll();
    
    xhr.open("GET", "/servlet/GetPictureInfo?pictureId=" + pictureId);
    xhr.onreadystatechange=processPictureInfo;
    xhr.send(null);
}

function viewPicturePreviousPictureSet() {
    stopAutoScroll();
    if (curPictureId != 0) {
        if(!$("#picture_" + curPictureId).hasClass("thumbnail-focus") || !USManalyze){
    	    deselectPicture(curPictureId);
        }
        $("#picture_" + curPictureId).removeClass("thumbnail-outof_focus");
    }
    xhr.open("GET", "/servlet/GetPictureInfo?pictureId=" + curPictureId + "&nav=previousPictureSet&numPerPage=<%=numPerPage%>&curPage=<%=curPage%>");
    xhr.onreadystatechange=processPictureInfo;
    xhr.send(null);
}

function viewPictureNextPictureSet() {
    stopAutoScroll();
    if (curPictureId != 0) {
    	if(!$("#picture_" + curPictureId).hasClass("thumbnail-focus") || !USManalyze){
    	    deselectPicture(curPictureId);
        }
        $("#picture_" + curPictureId).removeClass("thumbnail-outof_focus");
    }
    xhr.open("GET", "/servlet/GetPictureInfo?pictureId=" + curPictureId + "&nav=nextPictureSet&numPerPage=<%=numPerPage%>&curPage=<%=curPage%>");
    xhr.onreadystatechange=processPictureInfo;
    xhr.send(null);
}

function viewPicturePreviousOrientation() {
    stopAutoScroll();
    if (curPictureId != 0) {
        if(!$("#picture_" + curPictureId).hasClass("thumbnail-focus") || !USManalyze){
    	    deselectPicture(curPictureId);
        }
        $("#picture_" + curPictureId).removeClass("thumbnail-outof_focus");
    }
    xhr.open("GET", "/servlet/GetPictureInfo?pictureId=" + curPictureId + "&nav=previousOrientation");
    xhr.onreadystatechange=processPictureInfo;
    xhr.send(null);
}

function viewPictureNextOrientation() {
    stopAutoScroll();
    if (curPictureId != 0) {
    	if(!$("#picture_" + curPictureId).hasClass("thumbnail-focus") || !USManalyze){
    	    deselectPicture(curPictureId);
        }
        $("#picture_" + curPictureId).removeClass("thumbnail-outof_focus");
    }
    xhr.open("GET", "/servlet/GetPictureInfo?pictureId=" + curPictureId + "&nav=nextOrientation");
    xhr.onreadystatechange=processPictureInfo;
    xhr.send(null);
}

function processPictureInfo() {
    if (xhr.readyState == 4) {
        if (xhr.status == 200) {
            var xmlDoc = xhr.responseXML;
            var rootElement = xmlDoc.documentElement;

            // Get the new pictureId.
            if (rootElement.getElementsByTagName('pictureId')[0] && rootElement.getElementsByTagName('pictureId')[0].childNodes[0]) {
                curPictureId = rootElement.getElementsByTagName('pictureId')[0].childNodes[0].nodeValue;
                document.getElementById("curPictureId").value = curPictureId;
            }

            // Outline the new picture thumbnail in red.
            selectPicture(curPictureId);

            // Get the image files.
            var imageFile = "";
            var imageFileMedium = "";
            if (rootElement.getElementsByTagName('imageFile')[0] && rootElement.getElementsByTagName('imageFile')[0].childNodes[0]) {
                imageFile = rootElement.getElementsByTagName('imageFile')[0].childNodes[0].nodeValue;
            }
            if (rootElement.getElementsByTagName('imageFileMedium')[0] && rootElement.getElementsByTagName('imageFileMedium')[0].childNodes[0]) {
                imageFileMedium = rootElement.getElementsByTagName('imageFileMedium')[0].childNodes[0].nodeValue;
            }

            // Get the pictureSetAnnotation.
            pictureSetAnnotation = "";
            if (rootElement.getElementsByTagName('pictureSetAnnotation')[0] && rootElement.getElementsByTagName('pictureSetAnnotation')[0].childNodes[0]) {
                pictureSetAnnotation = rootElement.getElementsByTagName('pictureSetAnnotation')[0].childNodes[0].nodeValue;
            }

            // Get the pictureSetTimestamp.
            pictureSetTimestamp = "";
            if (rootElement.getElementsByTagName('pictureSetTimestamp')[0] && rootElement.getElementsByTagName('pictureSetTimestamp')[0].childNodes[0]) {
                pictureSetTimestamp = rootElement.getElementsByTagName('pictureSetTimestamp')[0].childNodes[0].nodeValue;
            }

            // Get the picture orientation.
            pictureOrientation = "";
            if (rootElement.getElementsByTagName('pictureOrientation')[0] && rootElement.getElementsByTagName('pictureOrientation')[0].childNodes[0]) {
                pictureOrientation = rootElement.getElementsByTagName('pictureOrientation')[0].childNodes[0].nodeValue;
            }
	    
            document.getElementById("pictureDiv").innerHTML = "<A HREF=/images/pictures/<%=post.getPostDir()%>/" + imageFile + " TARGET=_blank><IMG SRC=\"/cgi-bin/colorMod.pl?image=<%=post.getPostDir()%>/" + imageFileMedium + "&algorithm=<%=algorithm%>\" ALT=\"<%=Utils.htmlEscape(post.getName())%>, " + pictureSetTimestamp + ", " + pictureOrientation + "\" STYLE=\"border: 2px solid black;\"></A>";

            // Build the metadata table.
            if (rootElement.getElementsByTagName("metadata")[0]) {
                var tagElements = rootElement.getElementsByTagName("metadata")[0].getElementsByTagName("tag");
                if (tagElements) {
                    metadata = "<TABLE BORDER=0>";
                    for (var i = 0; i < tagElements.length; i++) {
                        var directory = "<BR>";
                        var tagId     = "<BR>";
                        var tagName   = "<BR>";
                        var tagValue  = "<BR>";
                        if (tagElements[i].getElementsByTagName('directory')[0].childNodes[0]) { directory = htmlEscape(tagElements[i].getElementsByTagName('directory')[0].childNodes[0].nodeValue); }
                        if (tagElements[i].getElementsByTagName('tagId')[0].childNodes[0])     { tagId     = htmlEscape(tagElements[i].getElementsByTagName('tagId')[0].childNodes[0].nodeValue); }
                        if (tagElements[i].getElementsByTagName('tagName')[0].childNodes[0])   { tagName   = htmlEscape(tagElements[i].getElementsByTagName('tagName')[0].childNodes[0].nodeValue); }
                        if (tagElements[i].getElementsByTagName('tagValue')[0].childNodes[0])  { tagValue  = htmlEscape(tagElements[i].getElementsByTagName('tagValue')[0].childNodes[0].nodeValue); }

                        metadata += "<TR>";
                        metadata += "<TD NOWRAP><SPAN CLASS=smallText>" + directory + "</SPAN></TD>";
                        metadata += "<TD NOWRAP><SPAN CLASS=smallText>" + tagId + "</SPAN></TD>";
                        metadata += "<TD NOWRAP><SPAN CLASS=smallText>" + tagName + "</SPAN></TD>";
                        metadata += "<TD NOWRAP><SPAN CLASS=smallText>" + tagValue + "</SPAN></TD>";
                        metadata += "</TR>";
                    }
                    metadata += "</TABLE>";
                }
            }

            // Build the satellite openlayers thing.
            if (rootElement.getElementsByTagName("satellite")[0]) {
                if (rootElement.getElementsByTagName("satellite")[0].getElementsByTagName("layerNamePrefix")[0] && rootElement.getElementsByTagName("satellite")[0].getElementsByTagName("layerNamePrefix")[0].childNodes[0]) { layerNamePrefix = rootElement.getElementsByTagName("satellite")[0].getElementsByTagName("layerNamePrefix")[0].childNodes[0].nodeValue; }
            }

            updatePictureInfo();
        }
    }
}

function updatePictureInfo() {
    document.getElementById("pictureOrientationDiv").innerHTML = "<SPAN STYLE=\"font-weight: bold;\">" + pictureOrientation + "</SPAN>";
    document.getElementById("pictureSetTimestampDiv").innerHTML = "<SPAN STYLE=\"font-weight: bold;\">" + pictureSetTimestamp + "</SPAN>";
    
     /*
      *	If the USM analyze button is not selected we need to remove the transparent selection div that is placed on top of the medium sized
      *	image. 'USManalyze' is set to true whenever the 'Analyze' radio button is selected.
      *
      *	Collin Sage, USM. June 24th, 2013.
      */
	$("#pictureSelectionDiv").remove();
    if(window.USManalyze && !document.getElementById("pictureOptionsAnalyze").checked){
        window.USManalyze = false;
        window.selectAllCheck = 1;
        $("#pictureSelectionDiv").remove();
        $("#selectAllButton").remove();
        //document.getElementById("picture_" + curPictureId).style.border = "2px solid red";
        document.getElementById("header1").innerHTML = ("N");
        document.getElementById("header2").innerHTML = ("NE");
        document.getElementById("header3").innerHTML = ("E");
        document.getElementById("header4").innerHTML = ("SE");
        document.getElementById("header5").innerHTML = ("S");
        document.getElementById("header6").innerHTML = ("SW");
        document.getElementById("header7").innerHTML = ("W");
        document.getElementById("header8").innerHTML = ("NW");
        document.getElementById("header9").innerHTML = ("UP");
        deselectPicturesFromAnalysis();
        $(".thumbnail-outof_focus").each(
		function(index){
            $(this).removeClass("thumbnail-outof_focus");
            $(this).addClass("thumbnail-focus");
        });          
        $("body").removeClass("untouchable");
    }

    if (document.getElementById("pictureOptionsMetadata").checked) {
        document.getElementById("pictureInfoDiv").innerHTML = "<div>" + metadata + "</div>";
    }
    else if (document.getElementById("pictureOptionsSatelliteTrueColor").checked) {
      if (/^(\d\d\d\d)\-(\d+)\-(\d+)/.test(pictureSetTimestamp)) {
        var ymd = RegExp.$1 + '-' + RegExp.$2 + '-' + RegExp.$3;
        var dt = new Date(parseInt(RegExp.$1,10), parseInt(RegExp.$2,10) - 1, parseInt(RegExp.$3,10)); 
        var lon0 = parseFloat(postLon) - 2;
        var lon1 = parseFloat(postLon) + 2;
        var lat0 = parseFloat(postLat) - 1.3;
        var lat1 = parseFloat(postLat) + 1.3;
        var extent = lon0+','+lat0+','+lon1+','+lat1;
        var mapurl = "https://earthdata.nasa.gov/labs/worldview/?t=" + ymd + "&v=" + extent;
        var imgsrc = "http://map2.vis.earthdata.nasa.gov/image-download?TIME="+ymd+"&extent="+extent+"&epsg=4326&layers=MODIS_Terra_CorrectedReflectance_TrueColor,Coastlines&opacities=1,1&worldfile=false&format=image/jpeg&width=430&height=300"; 
        $("#pictureInfoDiv").html("<a target=_blank href='"+mapurl+"' title='click to open interactive map'><img src='"+imgsrc+"'></a>");
      } else {
        $("#pictureInfoDiv").html("");
      }
    }
    else if(document.getElementById("pictureOptionsAnalyze").checked){
       
       /* 	
        *	Change the focus so that the user isn't confused at what thumbnails are part of the analysis and what ones aren't. At the moment this is the only
        *	place where this happens and so it was not moved to a seperate function.
        *
        *	Collin Sage, USM. June 27, 2013.
        */
       $("#picture_" + curPictureId).addClass("thumbnail-outof_focus");

       document.getElementById("header1").innerHTML = ("<a id='headerLink1' class='headerLinks' href='JavaScript:void(0)' onclick='selectPicturesByColumn(this)'>N</a>");
       document.getElementById("header2").innerHTML = ("<a id='headerLink2' class='headerLinks' href='JavaScript:void(0)' onclick='selectPicturesByColumn(this)'>NE</a>");
       document.getElementById("header3").innerHTML = ("<a id='headerLink3' class='headerLinks' href='JavaScript:void(0)' onclick='selectPicturesByColumn(this)'>E</a>");
       document.getElementById("header4").innerHTML = ("<a id='headerLink4' class='headerLinks' href='JavaScript:void(0)' onclick='selectPicturesByColumn(this)'>SE</a>");
       document.getElementById("header5").innerHTML = ("<a id='headerLink5' class='headerLinks' href='JavaScript:void(0)' onclick='selectPicturesByColumn(this)'>S</a>");
       document.getElementById("header6").innerHTML = ("<a id='headerLink6' class='headerLinks' href='JavaScript:void(0)' onclick='selectPicturesByColumn(this)'>SW</a>");
       document.getElementById("header7").innerHTML = ("<a id='headerLink7' class='headerLinks' href='JavaScript:void(0)' onclick='selectPicturesByColumn(this)'>W</a>");
       document.getElementById("header8").innerHTML = ("<a id='headerLink8' class='headerLinks' href='JavaScript:void(0)' onclick='selectPicturesByColumn(this)'>NW</a>");
       document.getElementById("header9").innerHTML = ("<a id='headerLink9' class='headerLinks' href='JavaScript:void(0)' onclick='selectPicturesByColumn(this)'>UP</a>");
    
       var analyzeButton = document.createElement("input");
       analyzeButton.setAttribute("type", "button");
       analyzeButton.setAttribute("name", "button");
       analyzeButton.setAttribute("value", "Greenness");
       analyzeButton.setAttribute("id", "analyzeButton");
       analyzeButton.onclick = showPopUpAndBeginAnalysis;
		
       var selectAllButton = document.createElement("input");
       selectAllButton.setAttribute("type", "button");
       selectAllButton.setAttribute("name", "button");
       selectAllButton.setAttribute("value", "Deselect All Images");
       selectAllButton.setAttribute("id", "selectAllButton");
       selectAllButton.onclick = selectAllImages;
       var $div = $("<div style='font-size:12px;'>Greenup in spring and development of color in autumn are ways that plants respond to their environment. Changes in the timing of these events are important indicators of climate change. Pictures capture the &quot;greenness&quot; in vegetation that can be used to create a greenness index over time.<BR><a href='/adopt_cci.jsp' title='background'>Learn more.</a></p><ul><li>Click to select a column of images below, such as the &quot;N&quot; column.</li><li>Draw a box by clicking and dragging on the large picture on the left.</li><li> Click on the greenness button when you are ready to analyze the area you selected.</li></ul></div>");
       $div.append(analyzeButton);
       $("#pictureInfoDiv").empty().append($div);
       if (!window.USManalyze){
           $("#selectAllTable").append(selectAllButton);
           document.getElementById("pictureDiv").innerHTML=document.getElementById("pictureDiv").innerHTML.concat("<div id ='pictureSelectionDiv' width = '400px' height = '300px'><canvas id='pictureSelectionCanvas' width='400px' height='300px'>Canvas Tag Not Supported!</canvas></div>");
       }
       ROIStart();
       var img = $('#pictureSelectionDiv').parent().children().children();
       img.load(function(){
           var height = this.height;
           var width = this.width;
           ROIsetDims(width, height);
           $('#pictureSelectionDiv').attr("height", height);
           $('#pictureSelectionCanvas').attr("height", height);
           var newTop = $('#pictureSelectionDiv').css("top");
	       newTop = newTop.replace("px", "");
           newTop = parseInt(newTop) + (300-height);
           $('#pictureSelectionDiv').css("top", newTop); 
           $('#pictureSelectionDiv').attr("width", width);
           $('#pictureSelectionCanvas').attr("width", width);

           drawExistingROIs();
       });

       
       window.USManalyze = true;
      
       $("body").addClass("untouchable");
    }

    document.getElementById("pictureSetAnnotationDiv").style.display = "none";
    if (pictureSetAnnotation != "") {
        document.getElementById("pictureSetAnnotationDiv").innerHTML = "<B>Photographer's note:</B> " + pictureSetAnnotation;
        document.getElementById("pictureSetAnnotationDiv").style.display = "block";
    }
}

function previousPage() {
    document.getElementById("curPage").value = <%=curPage%> - 1;
    document.getElementById("mainForm").submit();
}

function nextPage() {
    document.getElementById("curPage").value = <%=curPage%> + 1;
    document.getElementById("mainForm").submit();
}

function newNumPerPage() {
    document.getElementById("curPage").value = 0;
    document.getElementById("mainForm").submit();
}

function autoScrollPictureSet(direction) {
    stopAutoScroll();

    if (curPictureId != 0 && pictureOrientation != "") {

        if (direction != "previous") direction = "next";
        autoScrollDirection = direction;

        // Disable pictureInfo options (metadata, satellite)
        document.getElementById("pictureOptionsMetadata").disabled = true;
        document.getElementById("pictureOptionsSatelliteTrueColor").disabled = true;

        // Clear pictureInfoDiv.
        document.getElementById("pictureInfoDiv").innerHTML = "";

        // Display spinning gif in pictureDiv.
        document.getElementById("pictureDiv").innerHTML = "<IMG ID=\"autoScrollImage\" SRC=\"images/processing.gif\" STYLE=\"margin-left: auto; margin-right: auto; display: block;\">";

        // Replace the auto scroll arrow with a stop icon.
        if (autoScrollDirection == "previous") {
            document.getElementById("autoScrollPictureSetArrowUpDiv").innerHTML = "<A HREF=\"javascript:stopAutoScroll();\"><IMG SRC=\"images/stop.png\" ALT=\"stop auto scroll picture set\" border=0></A>";
        }
        else {
            document.getElementById("autoScrollPictureSetArrowDownDiv").innerHTML = "<A HREF=\"javascript:stopAutoScroll();\"><IMG SRC=\"images/stop.png\" ALT=\"stop auto scroll picture set\" border=0></A>";
        }

        // Clear the autoScrollPictures array.
        autoScrollPictures.length = 0;

        // Now use AJAX to get a list of all pictures for this post/orientation.
        xhr.open("GET", "/servlet/GetAutoScrollPictures?orientation= " + pictureOrientation + "&pictureSetIdString=<%=pictureSetIdString%>");
        xhr.onreadystatechange=processAutoScrollPictures;
        xhr.send(null);
    }
}

function processAutoScrollPictures() {
    if (xhr.readyState == 4) {
        if (xhr.status == 200) {
            var xmlDoc = xhr.responseXML;
            var rootElement = xmlDoc.documentElement;

            // Get the list of pictures.
            var pictureElements = rootElement.getElementsByTagName("picture");
            if (pictureElements) {
                for (var i = 0; i < pictureElements.length; i++) {
                    if (pictureElements[i].getElementsByTagName("pictureId")[0].childNodes[0] &&
                        pictureElements[i].getElementsByTagName("pictureSetTimestamp")[0].childNodes[0] &&
                        pictureElements[i].getElementsByTagName("imageFileMedium")[0].childNodes[0]) {
                        autoScrollPictures[i] = new AutoScrollPicture(pictureElements[i].getElementsByTagName("pictureId")[0].childNodes[0].nodeValue,
                                                            pictureElements[i].getElementsByTagName("pictureSetTimestamp")[0].childNodes[0].nodeValue,
                                                            new Image());
                        autoScrollPictures[i].image.src = "<%=Config.get("PICTURE_DIR_URL") + File.separator + post.getPostDir() + File.separator%>" + pictureElements[i].getElementsByTagName("imageFileMedium")[0].childNodes[0].nodeValue;
                    }
                }
            }

            if (autoScrollDirection == "previous") {
                autoScrollPictures.reverse();
            }

            // Set the autoScrollPictures starting point.
            for (var i = 0; i < autoScrollPictures.length; i++) {
                if (autoScrollPictures[i].pictureId == curPictureId) {
                    autoScrollPictureIndex = i;
                    break;
                }
            }

            // Get the pictureDiv ready.
            document.getElementById("pictureDiv").innerHTML = "<IMG ID=\"autoScrollImage\" STYLE=\"border: 2px solid black;\">";

            // Iterate through the list of pictures, displaying each for a short time.
            intervalId = setInterval("showAutoScrollPicture()", 500);
        }
    }
}

function showAutoScrollPicture() {
    // Outline the old picture thumbnail in black.
    if (curPictureId != 0) {
      deselectPicture(curPictureId);
    }

    // Set the new curPictureId.
    curPictureId = autoScrollPictures[autoScrollPictureIndex].pictureId;

    // Outline the new picture thumbnail in red.
    selectPicture(curPictureId);

    // Update the timestamp.
    document.getElementById("pictureSetTimestampDiv").innerHTML = "<SPAN STYLE=\"font-weight: bold;\">" + autoScrollPictures[autoScrollPictureIndex].pictureSetTimestamp + "</SPAN>";

    // Update the src to the new picture.
    document.getElementById("autoScrollImage").src = autoScrollPictures[autoScrollPictureIndex].image.src;

    // Get autoScrollPictureId ready for the next one.
    autoScrollPictureIndex++;
    if (autoScrollPictureIndex >= autoScrollPictures.length) {
        autoScrollPictureIndex = 0;
    }
}

function stopAutoScroll() {
    clearInterval(intervalId);
    intervalId = 0;

    // Enable pictureInfo options (metadata, satellite)
    document.getElementById("pictureOptionsMetadata").disabled = false;
    document.getElementById("pictureOptionsSatelliteTrueColor").disabled = false;

    // Clear the stop sign.
    document.getElementById("autoScrollPictureSetArrowUpDiv").innerHTML = "<A HREF=\"javascript:autoScrollPictureSet('previous');\"><IMG SRC=\"images/arrows-up.png\" ALT=\"auto scroll picture set\" border=0></A>";
    document.getElementById("autoScrollPictureSetArrowDownDiv").innerHTML = "<A HREF=\"javascript:autoScrollPictureSet('next');\"><IMG SRC=\"images/arrows-down.png\" ALT=\"auto scroll picture set\" border=0></A>";
}

//-->
</SCRIPT>

<link rel="stylesheet" type="text/css" href="USMscripts/src/plugins/dist/jquery.jqplot.css">
<link rel="stylesheet" type="text/css" href="USMscripts/src/stylesheets/PopupStyle.css">
<link rel="stylesheet" type="text/css" href="USMscripts/src/stylesheets/SelectionBox.css">
<link rel="stylesheet" type="text/css" href="USMscripts/src/stylesheets/Post.css">
<link rel="stylesheet" type="text/css" href="USMscripts/src/stylesheets/headerlinkstyle.css">
<link rel="stylesheet" type="text/css" href="USMscripts/src/stylesheets/Buttons.css">
<script src="USMscripts/src/scripts/GreennessAnalysis.js"></script>
<script src="USMscripts/src/scripts/PlottingFunction.js"></script>
<script src="USMscripts/src/scripts/PopupScript.js"></script>
<script src="USMscripts/src/scripts/SelectionScript.js"></script>
<script src="USMscripts/src/scripts/ColumnSelecting.js"></script>
<script src="USMscripts/src/scripts/windowGreennessAnalysis.js"></script>
<script src="USMscripts/src/plugins/dist/excanvas.min.js"></script>
<script src="USMscripts/src/plugins/dist/jquery.min.js"></script>
<script src="USMscripts/src/plugins/dist/jquery.jqplot.min.js"></script>
<script src="USMscripts/src/scripts/ROIScript.js"></script>
<script src="USMscripts/src/plugins/dist/plugins/jqplot.canvasTextRenderer.min.js"></script>
<script src="USMscripts/src/plugins/dist/plugins/jqplot.canvasAxisLabelRenderer.min.js"></script>
<script src="USMscripts/src/plugins/dist/plugins/jqplot.highlighter.min.js"></script> 
<script src="USMscripts/src/plugins/dist/plugins/jqplot.cursor.min.js"></script> 
<script src="USMscripts/src/plugins/dist/plugins/jqplot.dateAxisRenderer.min.js"></script>
<script src="USMscripts/src/plugins/dist/plugins/jqplot.canvasAxisTickRenderer.min.js"></script>
<script src="USMscripts/src/plugins/dist/plugins/jqplot.enhancedLegendRenderer.min.js"></script>
<script src="USMscripts/src/plugins/BrowserDetect.js"></script>
<script src="USMscripts/src/plugins/jQueryRotate.2.2.js"></script>
<script src="USMscripts/src/plugins/uiminified/jquery-ui.min.js"></script>
<script src="USMscripts/src/plugins/uiminified/jquery.ui.selectable.min.js"></script>

<script>
$(window).load(function () {
    var selectedObjs;
    var selectedImgs;
	var draggableOptions = {
		start: function(event, ui) {
			if (ui.helper.hasClass('drag') && ui.helper.hasClass('popup')) {
				selectedObjs = $('div.drag');
				selectedImgs = $('img.drag');
			}
			else {
    			selectedObjs = $(ui.helper);
    			selectedImgs = $(ui.helper);
			}
		},
		drag: function(event, ui) {
			var currentLoc = $(this).position();
			var prevLoc = $(this).data('prevLoc');
			if (!prevLoc) {
    			prevLoc = ui.originalPosition;
			}
			
			var offsetLeft = currentLoc.left-prevLoc.left;
			var offsetTop = currentLoc.top-prevLoc.top;
			
			moveSelected(offsetLeft, offsetTop);
			$(this).data('prevLoc', currentLoc);
		}
	};
	
	$('.popup').draggable(draggableOptions);

	function moveSelected(ol, ot){
		selectedObjs.each(function(){
			$this =$(this);
			var p = $this.position();
    		var l = p.left;
    		var t = p.top;
			
			$this.css('left', l+ol);
			$this.css('top', t+ot);
		})
		selectedImgs.each(function(){
			$this =$(this);
			var p = $this.position();
    		var l = p.left;
    		var t = p.top;
			
			$this.css('left', l+ol);
			$this.css('top', t+ot);
		})
	}
});

function showPopUpAndBeginAnalysis() {               
  checkOrientations();
  if (onlyOneOrientation) {
	WindowAnalysis();
  }
}

BrowserDetect.init();

$(function(){
  viewPicture(<%=String.valueOf(curPictureId)%>);
});
</script>

<div id=topbar class=clearfix>
  <a href="../post.jsp?postId=<%=post.getPostId()%>" class="btn btn-default pull-left"><span class="glyphicon glyphicon-menu-left" aria-hidden="true"></span> back</a>
  <h1><%= WebUtil.esc(post.getName()) %></h1>
</div>

<%=wu.popNotifications()%>

<FORM ID="mainForm">
  <INPUT TYPE="hidden" ID="curPictureId"   NAME="curPictureId">
  <INPUT TYPE="hidden" ID="curPage"        NAME="curPage" VALUE="<%=curPage%>">
  <INPUT TYPE="hidden" ID="postId"         NAME="postId" VALUE="<%=post.getPostId()%>">


  <DIV STYLE="height: 0px; clear: both;"></DIV>

  <DIV ID="pictureDiv" STYLE="width: 404px; height: 300px; float: left; margin-top: 35px;">
  	<TABLE BORDER="0" WIDTH="100%" HEIGHT="100%">
  		<TR>
  			<TD ALIGN="center" VALIGN="middle">please wait...</TD>
  		</TR>
  	</TABLE>	
  </DIV>

  <DIV STYLE="width: 90px; margin: 80px 5px 0px 5px; float: left;">
    <DIV STYLE="height: 25px;" title="Scroll around the panorama">
      <DIV ALIGN="right" STYLE="width: 28px; float: left;"><A HREF="javascript:viewPicturePreviousOrientation();"><IMG SRC="images/arrow-left.png" ALT="previous orientation" border=0></A></DIV>
      <DIV ID="pictureOrientationDiv" ALIGN="center" STYLE="width: 34px; float: left;"></DIV>
      <DIV ALIGN="left" STYLE="width: 28px; float: right;"><A HREF="javascript:viewPictureNextOrientation();"><IMG SRC="images/arrow-right.png" ALT="next orientation" border=0></A></DIV>
    </DIV>

    <DIV ID="autoScrollPictureSetArrowUpDiv" ALIGN="center" STYLE="height: 25px; margin-top: 1em;" title="auto scroll picture set in reverse"><A HREF="javascript:autoScrollPictureSet('previous');"><IMG SRC="images/arrows-up.png" ALT="auto scroll picture set" border=0></A></DIV>

    <DIV ALIGN="center" STYLE="height: 25px;" title="show previous picture set"><A HREF="javascript:viewPicturePreviousPictureSet();"><IMG SRC="images/arrow-up.png" ALT="previous picture set" border=0></A></DIV>

    <DIV ID="pictureSetTimestampDiv" ALIGN="center" STYLE="height: 40px;" title="date of picture set"></DIV>

    <DIV ALIGN="center" STYLE="height: 25px;" title="show next picture set"><A HREF="javascript:viewPictureNextPictureSet();"><IMG SRC="images/arrow-down.png" ALT="next picture set" border=0></A></DIV>

    <DIV ID="autoScrollPictureSetArrowDownDiv" title="auto scroll picture sets" ALIGN="center" STYLE="height: 25px;"><A HREF="javascript:autoScrollPictureSet('next');"><IMG SRC="images/arrows-down.png" ALT="auto scroll picture set" border=0></A></DIV>
  </DIV>

<style>
  #pictureInfoDiv > div {
    position: absolute;
    top: 6px;
    left: 6px;
    right: 6px;
    bottom: 6px;
    overflow: auto;
  }

  #analyzeButton {
    margin-left: 50px;
  }
  #pictureOptionsDiv {
    text-align: center;
  }
  #pictureOptionsDiv * {
    vertical-align: middle;
  }
  #pictureOptionsDiv label {
    font-weight: normal;
  }
  #pictureOptionsDiv label + label {
    margin-left: 14px;
  }
  #pictureOptionsDiv input {
   margin: 0;
  }
</style>
  <div style='float:left; margin-top: 10px;'>
    <div ID="pictureOptionsDiv">
      <label><INPUT TYPE="radio" NAME="pictureOptions" VALUE="satelliteTrueColor" ID="pictureOptionsSatelliteTrueColor" <%=(pictureOptions.equals("satelliteTrueColor")) ? "CHECKED" : ""%> onClick="updatePictureInfo()"> satellite</label>

      <label><INPUT TYPE="radio" name="pictureOptions" value="analysis" id="pictureOptionsAnalyze" <%=(pictureOptions.equals("analysis")) ? "CHECKED" : ""%> onClick="updatePictureInfo()"> greenness index</label>

      <label><INPUT TYPE="radio" NAME="pictureOptions" VALUE="metadata" ID="pictureOptionsMetadata" <%=(pictureOptions.equals("metadata")) ? "CHECKED" : ""%> onClick="updatePictureInfo()"> exif data</label>
    </div>
    <DIV ID="pictureInfoDiv" STYLE="position: relative; width:430px; height: 300px; border: 2px solid #000; overflow:hidden;" ALIGN="justify"></DIV>
  </div>

  <DIV STYLE="clear: both;"></DIV>
  <DIV ID="pictureSetAnnotationDiv" STYLE="display: none; margin: 12px;"></DIV>


<style>
#pictureSet {
  border-collapse:collapse;
  margin-top: 20px;
}
#pictureSet td {
  padding: 0;
  margin: 0;
}
#pictureSet td.info {
  font-size: .9em;
  text-align: center;
  padding-left: 6px;
}
#pictureSet th {
  text-align: center;
  color: #222;
}
</style>

    <TABLE ID="pictureSet">
      <TR>
        <TH ID="header1">N</TH>
        <TH ID="header2">NE</TH>
        <TH ID="header3">E</TH>
        <TH ID="header4">SE</TH>
        <TH ID="header5">S</TH>
        <TH ID="header6">SW</TH>
        <TH ID="header7">W</TH>
        <TH ID="header8">NW</TH>
        <TH ID="header9">UP</TH>
      </TR>

<%
for (int ps = 0; ps < pictureSetRecords.size(); ps++) {
    Vector<Picture> pictureRecords = pictureSetRecords.get(ps).dbGetPictureRecords();
%>

      <TR>

<%
    for (int i = 0; i < orientations.length; i++) {
        if (PictureSet.pictureRecordExists(pictureRecords, orientations[i])) {
            int pictureId = PictureSet.getPictureRecord(pictureRecords, orientations[i]).getPictureId();
%>

        <TD WIDTH="80"><IMG ID="picture_<%=String.valueOf(pictureId)%>" SRC="/cgi-bin/colorMod.pl?image=<%=post.getPostDir()+ "/" + PictureSet.getPictureRecord(pictureRecords, orientations[i]).getImageFileThumb()%>&algorithm=<%=algorithm%>" ALT="<%=Utils.htmlEscape(post.getName())%>, <%=pictureSetRecords.get(ps).getPictureSetTimestamp()%>, <%=orientations[i]%>" CLASS="thumbnail-default orientation-<%=orientations[i]%>-" onClick="viewPicture(<%=String.valueOf(pictureId)%>)"></TD>

<%
        }
        else {
%>

        <TD><BR></TD>

<%
        }
    }
%>

        <TD class=info>
          <%=pictureSetRecords.get(ps).getPictureSetTimestamp().toString().substring(0, 16)%>
          <% if (pictureSetRecords.get(ps).getPersonId() == Person.getInstance(session).getPersonId() || post.getPersonId() == Person.getInstance(session).getPersonId() || Person.getInstance(session).getAdmin() == true) { %>
            <br>
            <a href="/picset.jsp?id=<%=pictureSetRecords.get(ps).getPictureSetId()%>">manage</a>
          <% } %>
        </TD>
      </TR>
<% } %>

    </TABLE>

<% if (pictureSetRecords.size() == 0) { %>
  No pictures are available for this post.
<% } else { %>

  <DIV ID="pagingDiv" style='margin-top:1em; text-align: center;'>
    <% if (numPerPage > 0 && curPage > 0) { %>
      <a class="btn btn-default" href="javascript:previousPage();">&lt;&lt;</a>
    <% } %>
      <SELECT ID=numPerPage NAME=numPerPage SIZE=1 onChange="newNumPerPage();">
        <OPTION VALUE=10 <%=(numPerPage == 10)   ? " SELECTED" : ""%>>view 10 per page
        <OPTION VALUE=20 <%=(numPerPage == 20)   ? " SELECTED" : ""%>>view 20 per page
        <OPTION VALUE=50 <%=(numPerPage == 50)   ? " SELECTED" : ""%>>view 50 per page
        <OPTION VALUE=100 <%=(numPerPage == 100) ? " SELECTED" : ""%>>view 100 per page
        <OPTION VALUE=0 <%=(numPerPage == 0)     ? " SELECTED" : ""%>>view All
      </SELECT>
    <% if (numPerPage > 0 && post.dbGetNumViewablePictureSetPages(numPerPage) > curPage + 1) { %>
      <a class="btn btn-default" href="javascript:nextPage();">&gt;&gt;</a>
    <% } %>
  </DIV>
<% } %>

</FORM>

<div id="popup" class="popup drag">
  <div id="uldiv" class="popupmenu drag">
    <ul id="popupmenu" class="popupmenu drag">
      <li class="popupmenu drag"><a id="menu1" class="popupmenu" href="JavaScript:void(0)" onClick="getGraphAsImage()">Generate Graph as Image</a></li>
      <li class="popupmenu drag"><a id="menu2" class="popupmenu" href="JavaScript:void(0)" onClick="getGraphAsCSV()">Show Data as CSV</a></li>
    </ul>
  </div>
  <img id="logo" class="drag" src="USMscripts/src/SiteImages/picturepostlogo_150.png" alt="Picture Post Logo" width="130px" height="36px">
  <img id="loadicon" class="drag" src="USMscripts/src/SiteImages/PicturePostLoadAll.png" alt="Loading Icon" width="50px" height="50px">
  <div class="graphcanvas drag">
    <canvas id="imagecanvas" class="drag" width="900px" height="450px" style = "display: none"></canvas>
    <div id="chart2" style="width:900px; height:450px; visibility: hidden"></div>
  </div>
  <div id="CSVDiv" class="drag" style="width:900px; height:450px; visibility: hidden"><p id="CSVparagraph"></p></div>
  <div id="imageDisplayDiv" width="400px" height="300px">
    <canvas id="imageDisplayCanvas" width="400px" height="300px"></canvas>
  </div>
  <div id="loadCounter" class="loadCounter drag"></div>
</div>
        
<div id="blanket" class="blanket" onClick="HidePopup()"></div>

<%@ include file="/includes/footer.jsp" %>
