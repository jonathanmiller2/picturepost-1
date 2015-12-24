var IDArray = new Array();
var imageURLs = new Array();
var imageGreennessValues = new Array();
var postID = "";
var canvas;
var tempIndex = 0;
var dates = new Array();
var ROIData = new Array();
var orientation = "";
var data = new Array();
var plotLoaded = false;

function GreennessAnalysis() {

	// Sets up picture ID array, gets post ID, and ROI data
	IDArray = gup("id").split(",");
	postID = gup("postID");
	ROIData = gup("ROI").split(",");
	orientation = gup("ORI");

	// Sets up the canvas for loading images
	canvas = document.getElementById('imagecanvas');
	window.imageDisplayCanvas = document.getElementById("imageDisplayCanvas");

	// To prevent getting to a null canvas
	if(!canvas || !canvas.getContext) {
		return;
	}

	// Method to analyze an image's greenness
	analyzeImage(tempIndex);
}

function analyzeImage(index) {
	// Checks if the index has gone through all of the images
	if (index < IDArray.length) {
		// Creates and adds each image's URL to the array
		imageURLs.push("/images/pictures/post_" + postID + "/" + IDArray[index] + "_medium.jpg");
		
		// Sets up the image and context
		var context = canvas.getContext('2d');
		var image = new Image();
		
		// Performs the Greenness Analysis on the image when it is loaded
		image.onload = function() {
			// Update Loading Text
			$('p#loadingText').text("Loading Image " + (index + 1) + "/" + IDArray.length);
			
			// Determines the coordinates of image that was selected by the ROI 
			var wROI = (this.width * ROIData[0]).toFixed(3);
			var hROI = (this.height * ROIData[1]).toFixed(3);
			var xROI = (this.width * ROIData[2]).toFixed(3);
			var yROI = (this.height * ROIData[3]).toFixed(3);
			
			// Once image is loaded it is drawn to the canvas
			context.drawImage(image, 0, 0);
			
			// Sets up the image's data to send to the method that determines its greenness value
			var imageData = context.getImageData(xROI, yROI, wROI, hROI);
			imageGreennessValues.push(determineGreennessValue(imageData));

			// Once image is drawn and data collected, draw the ROI rectangle in the PicturePost Orange color
			context.rect(xROI, yROI, wROI, hROI);
			context.strokeStyle = "#e88b44";
			context.stroke();

			// Increases temp index and recursively runs through method for next image
			tempIndex++;
			analyzeImage(tempIndex);
		};
		// Sets the image's source according to the index
		image.src = imageURLs[tempIndex];
	} else {
		// Once all images are done being analyzed goes to the loadDate method
		// Hides the preview image and shows the loading (spinning) picturepost icon
		loadDates(IDArray, 0);
		$('.imageCanvas').hide();
		$('#loadingDiv').css('padding-top', '150px');
	//	$('#loadingDiv').show();
	}
}

// Function that puts all of the data together and sends to the JQPlot function
function concatData(dateArray, greennessValues, imageURLs, orientation) {
	// Array made for determining the position in the hover table
	var posIndex = [];
	// Puts the greenness index appropriate date together in the data array in for of [[date1, gi1], [date2, gi2], ... , [dateN, giN]]
	for (var a = 0; a < greennessValues.length; a++) {
		data.push([dateArray[a], greennessValues[a]]);
		posIndex.push(a);
	}

	// Because of way the table is laid out on main page the dates were in reverse order according to chart
	// Had to reverse the data array and the imageURL array so that way it matched the x-axis of the plot
	data = data.reverse();
	imageURLs = imageURLs.reverse();

	// Sends the data to the plot
	plotGreenness(data, posIndex, imageURLs, orientation);
}

function determineGreennessValue(imageData) {
	// Determines the amount of red, green, and blue in image
	var red = imageData.data[0];
	var green = imageData.data[1];
	var blue = imageData.data[2];

	// Returns the greenness value, which is the percentage of green in the image
	return (green / (red + green + blue)).toFixed(3);
}

// Plotting function
function plotGreenness(data, posIndex, imageURLs) {
$(function(){
	$('#chartdiv').show();
	$('#saveImgNote').show();
	$('.imageCanvas').hide();
	$('#loadingDiv').hide();

	$.jqplot.config.enablePlugins = true;
	$.jqplot('cd', [data], {
	// Title of the plot
	title: ('Greenness Index: Post ' + gup("postID")),
	titleOptions: {
			fontFamily: 'Sans-Serif',
			fontSize: '12pt'
		},
	axesDefaults: {
		labelRenderer: $.jqplot.CanvasAxisLabelRenderer
		
	},
	legend:{
           renderer: $.jqplot.EnhancedLegendRenderer,
           show:true
        },
	series: [{label: orientation}],
	seriesDefaults:{
		shadow: false
	},
	grid: {
		shadow: false
	},
	// Axes object which holds both axi
	axes: {
		// Options for x-axis
		xaxis: {
			renderer: $.jqplot.DateAxisRenderer,
			rendererOptions: {
				tickRenderer: $.jqplot.CanvasAxisTickRenderer
			},
			labelOptions: {
				fontFamily: 'Sans-Serif',
				fontSize: '12pt'
			},
			tickOptions: {
				formatString: '%b %#d %Y',
				angle: -30
			},
			label: "Date",
			pad: 0
		},
		// Options for y-axis
		yaxis: {
			label: "Greenness Index",
			
			labelRenderer: $.jqplot.CanvasAxisLabelRenderer,
			tickRenderer: $.jqplot.CanvasAxisTickRenderer,
			
			labelOptions: {
				fontFamily: 'Sans-Serif',
				fontSize: '12pt'
			},
			tickOptions: {
				angle: -30,
				formatString: '%1.2f'
			},
			min: 0,
			max: 0.75,
			pad: .05
		}
	},
	// Highlighter is the table popup when hovering over a point on the plot. Try to put image here, might have to make an image array and send to this function
	highlighter: {
		show: true,
		sizeAdjust: 7.5,
		bringSeriesToFront: true,
		showTooltip: true,

		// Following function allows each point to be unique and display related data
		// Each highlighter will show the correct image and related date and greenness values 
		tooltipContentEditor: function(str, seriesIndex, pointIndex, jqPlot) {
                
		// Gets the position of the point as well as the x and y data for the plot
                var xPos = posIndex[pointIndex];
		var xData = data[pointIndex][0];
		var yData = data[pointIndex][1];

		// Table for popup image
		// The width and height of the hover image are set here and used to draw the ROI box on the hover image
		// Have to subtract 2 pixels from width and height so border stays inside of frame
		return  '<table class="jqplot-highlighter">' + '<tr><td>Date:</td><td>' + xData + '</td></tr>' + '<tr><td>Greenness Index:</td><td>' + yData + '</td></tr>' 
			+ '<tr style="position: relative"><img src="' + imageURLs[xPos] + '" width="220" height="165" style="margin-left: auto; margin-right: auto;">'
			+ '<div class="box" style="position: absolute; top: ' + (ROIData[3] * 165) + 'px; left: ' + (ROIData[2] * 220) + 'px; width: ' 
			+ ((ROIData[0] * 220)-2) + 'px; height:' + ((ROIData[1] * 165)-2) +  'px; border: 2px solid #e88b44; background-color:transparent;"></div></tr>';
		
            }
	},
	// Cursor for navigating across plot
	cursor: {
		show: true,
		showTooltip: false
	//	tooltipLocation: 'nw'
	}

})});

plotLoaded = true;
}

function WindowAnalysis() {
	// Boolean for determining if images are selected
	var picturesSelected = false;

	// Creates the orientations array for plotting
	createWindowArrays();

	//Creates the URL variable for storing the images in the URL
	var URL = "/analyze/windowGreennessAnalysis.jsp?";

	// Gets postID from URL
	URL = URL + "postID=" + gup("postId") + "&id=";

	// Creates the IDArray for getting picture IDs for URL
	var IDArray = new Array();

	// Gets all selected pictures from each orientation
	// Should only be one orientation due to limiting selection
	// but still need to check all to find the orientation that has images
	for (var i = 0; i < window.orientations.length; i++) {
		// Creates a 2D Array to store all selected images for each orientation
		IDArray[i] = new Array();
		IDArray[i][0] = orientations[i];
		// Puts all of the selected pictures' ids into this array
		IDArray[i]= IDArray[i].concat(getAllSelectedPictures(window.orientations[i]));

		// If the sub array only holds the orientation move on
		if (IDArray[i].length < 2) {
			IDArray[i] = [""];
			continue;
		// If the sub array contains a picture ID add the picture ID to the URL
		} else {
			// If length is >= 2 then an image is selected so set boolean
			picturesSelected = true;

			// Gets the ROI variables
			var w = ROIArray[orientations[i]].width.toFixed(3);
			var h = ROIArray[orientations[i]].height.toFixed(3);
			var x = ROIArray[orientations[i]].x.toFixed(3);
			var y = ROIArray[orientations[i]].y.toFixed(3);

			// Limits number of images to 500 to prevent server error
			if (IDArray[i].length > 500) {
				alert("Due to analysis limitations the amount of photos is restricted to 500. Since you selected more than 500 photos the analysis will only run on the first 500. Sorry for the inconvenience.");
				IDArray[i] = IDArray[i].slice(0,501);
				console.log(IDArray[i].length);
			}

			// Creates the url with image IDs
			for (var k = 1; k < IDArray[i].length; k++) {
				if (k == IDArray[i].length - 1) {
					URL = URL + IDArray[i][k];
				} else {
					URL = URL + IDArray[i][k] + ",";
				}
			}

			// Adds the ROI data to the url
			URL = URL + "&ROI=" + w + "," + h + "," + x + "," + y;
			// Adds the orientation to the URL
			URL = URL + "&ORI=" + IDArray[i][0];
		}
	}
	if (picturesSelected) {
		window.open(URL);
		GreennessAnalysis();
	} else {
		alert("No images are selected, please select an image and try again.");
	}
}

// Function used to parse information from the URL
function gup(name) {
	name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
	var regexS = "[\\?&]" + name + "=([^&#]*)";
	var regex = new RegExp(regexS);
	var results = regex.exec(window.location.href);
	if (results == null)
		return "";
	else
		return results[1];
}

// Function for turning the plot into an image (Doesn't work for IE because IE doesn't work with dataURLs)
function getGraphAsImage() {
	if (plotLoaded) {
		var graphSrc = $('#cd').jqplotToImageStr({});
		var aTag = document.createElement('a');
		aTag.setAttribute('href', graphSrc);
		aTag.setAttribute('download', "Post" + postID + "Plot.png");
		aTag.click();
	}else {
		alert("Plot not loaded yet, please try again after the plot has finished loading.");           
	}
}

// Turns the data into a CSV to be copy and pasted into a text document then imported into a spreadsheet program such as excel
function getGraphAsCSV(){
	if (plotLoaded) {
		var csvData = "";

		for (var i = 0; i < data.length; i++) {
			if (i == 0) {
				csvData = csvData + orientation + ",\n";
				csvData = csvData + "Date,Greenness Value,\n";
			} else if (i > 0 && i < data.length - 1) {
				csvData = csvData + data[i] + ",\n";
			} else {
				csvData = csvData + data[i];
			}
		}
		// Need to replace in order to make the file recognize the new lines
		csvData = csvData.replace(/\n/g, "\r\n");
		var blob = new Blob([csvData], {type: "text/plain;charset=utf-8"});
		//Saves file in downloads as Post<ID>Data.txt, ie Post8Data.txt
		//File can then be imported into excel
		saveAs(blob, "Post" + postID + "Data.txt");
	} else {
		alert("Plot not loaded yet, please try again after the plot has finished loading.");
	}
}

// Function for loading the dates for each image
function loadDates(IDArray, currentIndex) {

	//Update Loading Text
	$('p#loadingText').text('Analyzing Image ' + (currentIndex + 1) + "/" + IDArray.length);

	// If all images' dates have been gathered send to the function that combines all the data for the plot
	if (currentIndex == IDArray.length) {
		concatData(dates, imageGreennessValues, imageURLs, orientation);
	} else {
	// Gets the numerical portion of the picture ID
	var pictureID = IDArray[currentIndex].replace("picture_", "");
	var pictureDate;
	var xmlhttp;
	// Code for IE7+, Firefox, Chrome, Opera, Safari
	if (window.XMLHttpRequest) {
		xmlhttp = new XMLHttpRequest();
	} else {
	// Code for IE6, IE5
		xmlhttp = ActiveXObject("Microsoft.XMLHTTP");
	}
	
	xmlhttp.onreadystatechange = function() {
		// If the server has sent data back
		if(xmlhttp.readyState == 4 && xmlhttp.status == 200) {
			// Navigates through returned xml to get to date
			var xmlDoc = xmlhttp.responseXML;
			var rootElement = xmlDoc.documentElement;
			if (rootElement.getElementsByTagName('pictureSetTimestamp')[0] && rootElement.getElementsByTagName('pictureSetTimestamp')[0].childNodes[0]) {
				pictureDate = rootElement.getElementsByTagName('pictureSetTimestamp')[0].childNodes[0].nodeValue;
			}
			// Splits the date as it returns Year-Month-Date Hour:Minute and only want date
			pictureDate = pictureDate.split(" ");
			// Selects the date from the split array
			dates.push(pictureDate[0]);
			// Recursively goes through all images
			loadDates(IDArray, currentIndex + 1);
		}
		
	}
	// AJAX calls to server to get picture data
	xmlhttp.open("GET", "/servlet/GetPictureInfo?pictureId=" + pictureID, true);
	xmlhttp.send(null);
	}	
}
