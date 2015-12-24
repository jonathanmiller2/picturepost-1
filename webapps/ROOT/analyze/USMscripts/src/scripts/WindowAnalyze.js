function GreennessAnalysis() {

	//Creates an array to store the picture IDs in
	var IDArray = new Array();
	var postID = gup("postID");
//	var orientations = ["N", "NE", "E", "SE", "S", "SW", "W", "NW", "UP" ];

	for(var i = 0; i < 8; i++) {
		// Creates 2D Array
		IDArray[i] = new Array();
		IDArray[i] = gup("id").split(",");		
	}

	//var loadedImageCount = 0;
	//var loadedDateCount = 0;
	//var curOrientationIndex = 0;
	//loadDates(IDArray, 1);

	

	// Sets up the canvas for loading the images		
	var canvas = document.getElementById('imagecanvas');
	window.imageDisplayCanvas = document.getElementById("imageDisplayCanvas");
	
	if (!canvas || !canvas.getContext) {
		return;
	}

	// Creates an Array for the URL of each picture
	var imageURLArray = new Array();
	//imageURLArray[0] = IDArray[0][0];
	for (var k = 0; k < IDArray.length - 1; k++) {
		
		imageURLArray[k] = "/images/pictures/post_" + postID + "/" + IDArray[0][k+1] + "_medium.jpg";
	} 

	var context = canvas.getContext("2d");
	var image = new Image;
	//image.src = imageURLArray[0];
	image.onload = function() {
		var width = image.naturalWidth;
		var height = image.naturalHeight;
		context.drawImage(image,0,0);
		var imgData = context.getImageData(0,0,width,height);
		document.getElementById("testButton").innerHTML = imgData.data[0];
	}
	image.src = imageURLArray[0];
	//document.getElementById("testButton").innerHTML = imageURLArray[0];
	
	// Loads the images and analyzes each one
	loadImages(canvas, imageURLArray, 1);

}

// Next need to do loadImages function, which loads the images from the URLArray and performs the greenness Analysis on them.
function loadImages(canvas, imageURLArray, currentIndex) {
	
	var c = document.getElementById('imagecanvas');
	var cntx = c.getContext('2d');
	var img = new Image();
 	img.src = imageURLArray[0];
	cntx.drawImage(img, 0,0);

	var tempindex = currentIndex - 1;
	var currentImage = new Image();
	
	//cntx.drawImage(currentImage, 0, 0);

	currentImage.onload = function (e) {
		document.getElementById("testButton").innerHTML = "image Loaded";
		$('#imagecanvas').attr("height", this.height);
		$('#imagecanvas').attr("width", this.width);

		var context = canvas.getContext('2d');

		// This checks if we can draw to the canvas. If not analysis is ended because
		// you cannot analyze an empty canvas
		if (!context || !context.putImageData) {
			document.getElementById("testButton").innerHTML = "kicked out";
			return;
		}
		
		// Clear canvas to prevent any issues with alpha channel images
		context.clearRect(0,0, canvas.width, canvas.height);
		context.drawImage(currentImage, 0, 0, canvas.width, canvas.height);

		// Displays a preview of the image being analyzed
		var previewImageContext = window.previewImageCanvas.getContext('2d');
		var imageToDraw = currentImage;
		imageToDraw.style.height = 300;
		imageToDraw.stle.width = 400;
		previewImageContext.drawImage(imageToDraw, 0, 0, 400, 300);

		// ROI data
		var imgd = false;
		var w = this.width * ROIArray[imageURLArray[0]].width;
		var h = this.height * ROIArray[imageURLArray[0]].height;
		var x = this.width * ROIArray[imageURLArray[0]].x;
		var y = this.height * ROIArray[imageURLArray[0]].y;

		if (context.getImageData) {
			imgd = context.getImageData(x, y, w, h);
		} else {
                console.log("Error: Image data not grabbed.");
                imgd = { 'x': x, 'y': y, 'width': w, 'height': h, 'data': new Array(w * h * 4) };
            	}
		
		var pixel = imgd.data;
		// Left off on putting the greenness analysis into my analysis code. Line 141
		window.lineArray[imageURLArray[0]][tempindex]=0;

		document.getElementById("testButton").innerHTML = "Entering Analysis";
		//Actual Greenness Analysys
		for (var i = 0; i < pixel.length; i +=4) { 

			var green = pixel[i + 1];
			var totalColor = pixel[i + 0] + pixel[i + 1] + pixel[i + 2];
			
			var greenness = 0;
			if (totalColor != 0) {
				greenness = green / totalcolor;
			}
			window.lineArray[imageURLArray[0]][tempindex] = window.lineArray[imageURLArray[0]][tempindex] + greenness;
			window.lineArray[imageURLArray[0]][tempindex] /= (pixel.length / 4);
			window.loadedImageCount++;
			document.getElementById("loadCounter").innerHTML = "Loading..." + calculateLoadPercent() + "%";

			if(loadImageCount == window.totalImages) {
				plotGreenness();
			} else {
				currentIndex ++;
				loadImages(canvas, imageURLArray, currentIndex);
			}
			document.getElementById("testButton").innerHTML = "Evaluating pixel " + i;
		}
		currentImage.src = imageURLArray[currentIndex];
		return;
	} 
}

function WindowAnalysis() {

	var URL = makeURLFromImages();
	window.open(URL);
	
}

function makeURLFromImages() {

	// Creates the orientations for the plotting function
	createWindowArrays();
	
	// Creates an Array to store the Image IDs in
	var IDArray = new Array();
	// Creates a base URL to send to the Window Analysis Page
	var URL = "/analyze.jsp?";
	
	// Initializes variables
	window.totalImages = 0;
	window.test = false;

	URL = URL + "postID=" + gup("postId");

	// Constructs a URL based on the images selected
	for(var i = 0; i < window.orientations.length; i++) {
		IDArray[i] = new Array();
		IDArray[i][0] = orientations[i];
			
		IDArray[i] = IDArray[i].concat(getAllSelectedPictures(window.orientations[i]));
	
		if (IDArray[i].length < 2) {
			IDArray[i] = [""];
			continue;
		} else {	
			URL = URL + "&id" + "=" + IDArray[i];
		
		}	
	}

	return URL;

}

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
