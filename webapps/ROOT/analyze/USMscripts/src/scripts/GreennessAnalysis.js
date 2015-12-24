/*
 *	The analysis feature uses two window variables for ease of access.
 *	
 *	@greennessindex: The average greenness value of all the pixels in an image is stored in a cell of this array. Greenness values are stored 
 *	base on the order that images are sent to the analysis.
 *	@loadedImageCount: Images in JavaScript are not immediately loaded so we need some way to measure how many images are fully done loading before we continue.
 *	
 *	Collin Sage, USM. June 17th, 2013.
 */
function greennessAnalysis(IDarray) {
    /*
    *	The canvas object is a necessity for this analysis because it relies on the ability to dump the image data from each picture onto to the canvas
    *	in order to extract the data from it later. As far as I know there is no direct way to access image data and so a workaround is necessary. If we
    *	can't get a canvas then we return and fail nicely rather than return false data.
    *	
    *	Collin Sage, USM. June 17th, 2013.
    */
    var canvas = document.getElementById('imagecanvas');
    window.imageDisplayCanvas = document.getElementById("imageDisplayCanvas");
    if (!canvas || !canvas.getContext) {
        return;
    }

    /*
    *   Builds an array of image URLs using string concatination with the post ID and appropriate ID from the IDarray.
    *
    *   Nick Hamel, USM.  August 13th, 2013.
    */
    var imageURLarray = new Array();
    imageURLarray[0] = IDarray[0];
    var postID = parseURLforPostID();
    for (var i = 1; i < IDarray.length; i++) {
        var ID = IDarray[i];
            imageURLarray[i] = "/images/pictures/post_" + postID + "/" + ID + "_medium.jpg";
    }

    /*
    *	Now that the canvas and the context have been checked we can assume it is safe to load the images for the analysis. The actual
    *	analysis will happen inside the image's 'onLoad()' function, this is because we need the image to be completely loaded before 
    *	we run the analysis. If all of the images are loaded then we don't perform the analysis again, instead we just show the plots
    *	and get rid of the loading icon.
    *
    *	Collin Sage, USM. June 17th, 2013.
    */
    loadImages(canvas, imageURLarray, 1);
}

	/*
	 *	Although it is slightly misleading this is the function that actually performs the analysis. However, this method should not be called
	 *	directly because it does not guarantee that the canvas or the context are valid objects and could easily fail on its own.
	 *	
	 *	Collin Sage, USM. June 17th, 2013.
	 */
function loadImages(canvas, imageURLarray, currentIndex) {

    /*
    * 	We end the recursion when either there are no URLs for images or when we've gone through all of them. We return all the way through
    * 	the stack and wait for the images to load before plotting the data.
    *
    *	Collin Sage, USM. June 17th, 2013.
    */
    if (imageURLarray.length == 1 || imageURLarray.length == currentIndex) {
        return false;
    }

    /*
    *	If for some reason the 'greennessAnalysis()' function is called without specifying an index we catch it and supplement a 1.
    *
    *	Collin Sage, USM. June 17th, 2013.
    */
    if (typeof currentIndex == 'undefined') {
        currentIndex = 1;
    }
    
    /*
    *	The currentindex changes with each loop through the recursion and so a temporary index has to be made or else the greenness value will be
    *	stored in the wrong position within the 'greennessindex' array. The 'onLoad()' function contains the actual analysis.
    *
    *	Collin Sage, USM. June 17th, 2013.
    */
    var tempindex = currentIndex - 1;

    if (document.getElementById("popup").style.visibility == "visible") {
        /*
        *	Creates a new image, whose source will be set to the image being analyzed, telling the browser to begin loading it.
        *
        *	Collin Sage, USM. June 17th, 2013.
        */
        var currentimage = new Image();


        currentimage.onload = function (e) {
            $('#imagecanvas').attr("height", this.height);
            $('#imagecanvas').attr("width", this.width);

            /*
            *	If we can't draw to the canvas then we can't get the image data. Rather than return bad data we return and quit the analysis.
            *
            *	Collin Sage, USM. June 17th, 2013.
            */
            var context = canvas.getContext('2d');
            if (!context || !context.putImageData) {
                return;
            }
            /*
            *	Clearing the canvas before drawing the next image is a precaution we take to avoid any issues with images with alpha channels less than 1. 
            *	
            *	Collin Sage, USM. June 17th, 2013.
            */
            context.clearRect(0, 0, canvas.width, canvas.height);
            context.drawImage(currentimage, 0, 0, canvas.width, canvas.height);

            //Displays a medium version of the picture currentlly being analyzed on the pop-up screen
            var imageDisplayContext = window.imageDisplayCanvas.getContext("2d");
            var imageToDraw = currentimage;
            imageToDraw.style.height = 300;
            imageToDraw.style.width = 400;
            imageDisplayContext.drawImage(imageToDraw, 0, 0, 400, 300);


            /*
            *	@imgd: This variable holds the data for the picture, including the pixel data that we are after.
            *	@w: The width of the ROI.
            *	@h: The height of the ROI.
            *	@x: The x position of the left side of the ROI.
            *	@y: The y position of the top side of the ROI.
            */
            var imgd = false;
            var w = this.width * ROIArray[imageURLarray[0]].width;
            var h = this.height * ROIArray[imageURLarray[0]].height;
            var x = this.width * ROIArray[imageURLarray[0]].x;
            var y = this.height * ROIArray[imageURLarray[0]].y;

            if (context.getImageData) {
                imgd = context.getImageData(x, y, w, h);
            } else {
                console.log("Error: Image data not grabbed.");
                imgd = { 'x': x, 'y': y, 'width': w, 'height': h, 'data': new Array(w * h * 4) };
            }

            var pixel = imgd.data;

            /*
            *	In order for the analysis to work the array must have a value of 0 first or else it will return bad results from 
            *	trying to do 'undefined += number'.
            *
            *	Collin Sage, USM. June 17th, 2013.
            */
            window.lineArray[imageURLarray[0]][tempindex] = 0;

            /*
            *	Each pixel is looped over and measured for how 'green' it is. Greenness is measured by green / (red + green + blue). 
            *	This gives a normalized percentage of green for each pixel. This also lowers the effect that nighttime pictures will 
            *	have on the greenness value.
            *
            *	Collin Sage, USM. June 17th, 2013.
            */
            for (var i = 0, n = pixel.length; i < n; i += 4) {
                var green = pixel[i + 1];
                var totalcolor = pixel[i + 0] + pixel[i + 1] + pixel[i + 2];

                var greenness = 0;
                if (totalcolor != 0) {
                    greenness = green / totalcolor;
                }
                window.lineArray[imageURLarray[0]][tempindex] = window.lineArray[imageURLarray[0]][tempindex] + greenness;
            }

            /*
            *	After each pixel has been looped over and the total greenness is stored in the 'greennessindex' the average is 
            *	taken to give more meaningful data. The array 'pixel' stores each channel in a separate index and so it is 4 
            *	times (r, g, b, a) larger than the amount of pixels in the image. Dividing by one fourth the length gives the 
            *	numerical mean of the greenness in the image.
            *
            *	Collin Sage, USM. June 17th, 2013.
            */
            window.lineArray[imageURLarray[0]][tempindex] /= (pixel.length / 4);
            window.loadedImageCount++;
            document.getElementById("loadCounter").innerHTML = "Loading..." + calculateLoadPercent() + "%";

            /*
            *	Once all of the images are loaded the plot is created and shown at the same time that the loading icon is hidden. 
            *	Providing for a smooth transition between the loading screen and the plot.
            *
            *	Collin Sage, USM. June 17th, 2013.	
            */
            if (loadedImageCount == window.totalImages) {
                plotGreenness();

                //A fade-out animation using jQuery to fade out the images being displayed on the pop-up 
                //when all images are finished loading.
                $("#imageDisplayDiv").fadeOut(1000, function () {
                    document.getElementById("imageDisplayDiv").style.visibility = "hidden";
                    imageDisplayContext.clearRect(0, 0, 400, 300);
                });
            } else {
                /*
                *	Increment the current index and continue the recursion using the same parameters as were started with.
                *
                *	Collin Sage, USM. June 17th, 2013.
                */
                currentIndex++;
                loadImages(canvas, imageURLarray, currentIndex);
            }
        }

        //Sets the source of the new image.
        currentimage.src = imageURLarray[currentIndex];

        return;
    } else {
        imageDisplayContext.clearRect(0, 0, 400, 300);
        return;
    }
}

//This function uses AJAX to load the dates of all of the images being analyzed.
//It requires an array of image IDs and an integer to be used as the current index.
function loadDates(IDarray, currentIndex){
    if (document.getElementById("popup").style.visibility == "visible") {
        //Ends the recursion if the IDarray passed in had no data in it or all data has been analyzed
        if (IDarray.length == 0) {
            return false;
        }

        if (window.loadedDateCount == window.totalImages) {
            plotGreenness();
            return false;
        }

        //Setting a temporary version of currentIndex, because the actual currenrIndex changes with each recursion.
        var tempIndex = currentIndex - 1;

        //Tests to see if there are any more IDs in the current array and moves to the next one if there aren't
        if (currentIndex == IDarray[window.curOrientationIndex].length) {
            currentIndex = 1;
            window.curOrientationIndex++;
            loadDates(IDarray, currentIndex);
            return;
        }

        //Getting the ID of the current image whose date we are grabbing and removing the "picture_"
        var currentID = IDarray[window.curOrientationIndex][currentIndex];
        currentID = currentID.replace("picture_", "");

        //The AJAX call to the server to get the XML document containing the current image's information
        window.xhr.open("GET", "/servlet/GetPictureInfo?pictureId=" + currentID, true);
        window.xhr.send(null);

        //Getting the date from the XML document
        window.xhr.onreadystatechange = function () {
            if (window.xhr.readyState == 4 && xhr.status == 200) {
                var xmlDoc = window.xhr.responseXML;
                var rootElement = xmlDoc.documentElement;
                if (rootElement.getElementsByTagName('pictureSetTimestamp')[0] && rootElement.getElementsByTagName('pictureSetTimestamp')[0].childNodes[0]) {
                    window.dateArray[window.orientations[window.curOrientationIndex]][tempIndex] = rootElement.getElementsByTagName('pictureSetTimestamp')[0].childNodes[0].nodeValue;
                    window.loadedDateCount++;
                    document.getElementById("loadCounter").innerHTML = "Loading..." + calculateLoadPercent() + "%";
                    currentIndex++;

                    //Recurses until all dates are grabbed
                    loadDates(IDarray, currentIndex);
                    return;
                }
            }
        };
    }else{
        return;
    }
}

//This function calculates the percentage of all items necssary for the analysis that are loaded.
function calculateLoadPercent(){
    var percentage = ((window.loadedDateCount + window.loadedImageCount) / (window.totalImages * 2)) * 100;
    percentage = (Math.round(percentage * 10)) / 10;
    return percentage;
}

            
