var xhr;

if (window.XMLHttpRequest) {
    xhr = new XMLHttpRequest();
}
else {
    xhr = new ActiveXObject("Microsoft.XMLHTTP");
}

USManalyze = false;
var orientationArray = [0, 0, 0, 0, 0, 0, 0, 0, 0];
var onlyOneOrientation = true;
var firstLoadOrientation = true;
var pictureOrientation = "";
var pictureSetTimestamp = "";
var metadata  = "";
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
	// Need to include picture's column to ensure only one plot is plotted
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
    xhr.open("GET", "/servlet/GetPictureInfo?pictureId="+curPictureId+"&nav=previousPictureSet&numPerPage="+numPerPage+"&curPage="+curPage);
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
    xhr.open("GET", "/servlet/GetPictureInfo?pictureId="+curPictureId+"&nav=nextPictureSet&numPerPage="+numPerPage+"&curPage="+curPage);
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
	    
            document.getElementById("pictureDiv").innerHTML = "<a href='/images/pictures/"+postDir+"/"+imageFile+"' target=_blank><img src='/cgi-bin/colorMod.pl?image="+escape(postDir+"/"+imageFileMedium)+"&algorithm="+escape(algorithm)+"' alt='"+escape_html(postName+', '+pictureSetTimestamp+', '+pictureOrientation)+"' style='border: 2px solid black;'></a>";

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
        $("#pictureInfoDiv").html("<a target=_blank id=SatImg href='"+mapurl+"' title='click to open interactive map courtesy of NASA Worldview'><img onload='handleSatImgLoad();' onerror='handleSatImgError();' src='"+imgsrc+"'></a><div id=SatImgMsg>Loading satellite imagery ...</div>");
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
    document.getElementById("curPage").value = curPage - 1;
    document.getElementById("mainForm").submit();
}

function nextPage() {
    document.getElementById("curPage").value = curPage + 1;
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
        xhr.open("GET", "/servlet/GetAutoScrollPictures?orientation="+pictureOrientation+"&pictureSetIdString="+pictureSetIdString);
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
                        autoScrollPictures[i].image.src = picDirUrl+"/"+postDir+"/"+pictureElements[i].getElementsByTagName("imageFileMedium")[0].childNodes[0].nodeValue;
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

function showPopUpAndBeginAnalysis() {               
  checkOrientations();
  if (onlyOneOrientation) {
	WindowAnalysis();
  }
}

function handleSatImgLoad() {
  $("#SatImgMsg").remove();
}

function handleSatImgError() {
  $("#pictureInfoDiv").html("<div id=SatImgMsg>No satellite imagery available for this date.</div>");
}


$(function() {
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

    BrowserDetect.init();
    viewPicture(curPictureId);
});
