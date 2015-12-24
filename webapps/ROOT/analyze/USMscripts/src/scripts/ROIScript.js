//This function allows the user to select a region of interest of an image to analyze.
//It draws a selection box on a canvas placed over the image and sends the data for the box to the analyze function.
window.keepROI = false;

window.ROIwidth;
window.ROIheight;
//USMs objects and associative array for the region of interest

    window.selectionBoxN = { x: 0, y: 0, width: 1, height: 1 };
    window.selectionBoxNE = { x: 0, y: 0, width: 1, height: 1 };
    window.selectionBoxE = { x: 0, y: 0, width: 1, height: 1 };
    window.selectionBoxSE = { x: 0, y: 0, width: 1, height: 1 };
    window.selectionBoxS = { x: 0, y: 0, width: 1, height: 1 };
    window.selectionBoxSW = { x: 0, y: 0, width: 1, height: 1 };
    window.selectionBoxW = { x: 0, y: 0, width: 1, height: 1 };
    window.selectionBoxNW = { x: 0, y: 0, width: 1, height: 1 };
    window.selectionBoxUP = { x: 0, y: 0, width: 1, height: 1 };

    window.ROIArray = { N: selectionBoxN, NE: selectionBoxNE, E: selectionBoxE, SE: selectionBoxSE, S: selectionBoxS, SW: selectionBoxSW, W: selectionBoxW, NW: selectionBoxNW, UP: selectionBoxUP };

function ROIStart(){

    document.body.onmouseup = function (e) {
        if (window.keepROI) {
            window.keepROI = false;
        }
    }
    if (document.getElementById("pictureDiv").innerHTML.indexOf('pictureSelectionDiv') < 0) {
        document.getElementById("pictureDiv").innerHTML = document.getElementById("pictureDiv").innerHTML.concat("<div id ='pictureSelectionDiv' width = '400px' height = '300px'><canvas id='pictureSelectionCanvas' width='400px' height='300px'>Canvas Tag Not Supported!</canvas></div>");
    }

    //Getting the canvas and context using JQuery.
    window.ROIcanvas = $('#pictureSelectionCanvas');
    var ROIcontext = ROIcanvas[0].getContext("2d");
    
    //The object that temporarily stores the data for the selection box. 
    var selectionBox ={x:0, y:0, width:0, height:0};

    //The first click clears any old selection boxed from the canvas and stores the location of the first click.
    ROIcanvas.on('mousedown', function (e) {
        window.keepROI = true;
        ROIcontext.clearRect(0, 0, ROIcontext.canvas.width, ROIcontext.canvas.height);
        var initialPosition = getPos(e);
        selectionBox.x = initialPosition.x;
        selectionBox.y = initialPosition.y;
        selectionBox.width = 0;
        selectionBox.height = 0;

        //As the user drags the mouse, the function continuously grabs the cursor's position on the canvas
        //and calculates the width and height of the box based on the cursors current position and 
        //the initial position of the box.
        //For every pixel that the cursor moves, the old selection box is removed and a new one is drawn.
        ROIcanvas.on('mousemove', function (e) {
            if (keepROI) {
                ROIcontext.clearRect(0, 0, ROIcontext.canvas.width, ROIcontext.canvas.height);

                var movePosition = getPos(e);
                move_x = movePosition.x,
                move_y = movePosition.y,
                width = Math.abs(move_x - initialPosition.x),
                height = Math.abs(move_y - initialPosition.y),
                new_x = 0, new_y = 0;

                //These two if statements check to see if the endpoint of the box is to the left or above the start point.
                //If they are, the operators replace the top and left values accordingly. 
                if (move_x < initialPosition.x) {
                    new_x = initialPosition.x - width;
                } else {
                    new_x = initialPosition.x;
                }

                if (move_y < initialPosition.y) {
                    new_y = initialPosition.y - height;
                } else {
                    new_y = initialPosition.y;
                }

                //Writing the resulting data to the selection box object
                selectionBox.x = new_x;
                selectionBox.y = new_y;
                selectionBox.width = width;
                selectionBox.height = height;

                //Drawing the selection box and its border to the canvas
                ROIcontext.fillStyle = "rgba(128, 128, 128, 0.5)";
                ROIcontext.fillRect(selectionBox.x, selectionBox.y, selectionBox.width, selectionBox.height)
                ROIcontext.fillStyle = "#000";
                ROIcontext.lineWidth = 2;
                ROIcontext.strokeRect(selectionBox.x, selectionBox.y, selectionBox.width, selectionBox.height);

                //calculating the ROI as a ratio to the original image so that 
                //it may be redrawn on images of different sizes
                //and writing the ratio to the global associative array
                var img = document.getElementById("pictureSelectionDiv").parentNode.childNodes[0].childNodes[0];
                var height = img.height;
                var width = img.width;
                window.ROIArray[window.pictureOrientation].x = selectionBox.x / width;
                window.ROIArray[window.pictureOrientation].y = selectionBox.y / height;
                window.ROIArray[window.pictureOrientation].width = selectionBox.width / width;
                window.ROIArray[window.pictureOrientation].height = selectionBox.height / height;
            }
        });
    }); 

    //Stops drawing when the cursor leaves the canvas.
    ROIcanvas.on('mouseout', function (e) {
        if (!keepROI) {
            ROIcanvas.off('mousemove');
        }
    });

     //Stops drawing if the cursor leaves the canvas.
    ROIcanvas.on('mouseup', function (e) {
        window.keepROI = false;
        ROIcanvas.off('mousemove');
    });
}


//This function is used by the ROIStart function to find the cursors location on the canvas
//It requires the event used to call it as a parameter.  
//It returns the x and y coordinates of the cursor on the canvas as an object.
function getPos(e){
    var targ;
    if (!e){
        e = window.event;
    }
    
    if (e.target){
        targ = e.target;
    }else if(e.srcElement){
        targ = e.srcElement;
    }
    
    if(targ.nodeType == 3){
        targ = targ.parentNode;
    }

    var x = e.pageX - $(targ).offset().left;
    var y = e.pageY - $(targ).offset().top;

    return { "x": x, "y": y };
}

function drawExistingROIs() {
    var canvas = $('#pictureSelectionCanvas');
    var context = canvas[0].getContext("2d");
    context.clearRect(0, 0, context.canvas.width, context.canvas.height);
    if (window.ROIArray[window.pictureOrientation].x != 0 && window.ROIArray[window.pictureOrientation].y != 0 && window.ROIArray[window.pictureOrientation].width != 0 && window.ROIArray[window.pictureOrientation].height != 0) {
        context.fillStyle = "rgba(128, 128, 128, 0.5)";
        context.fillRect(window.ROIArray[window.pictureOrientation].x * width, window.ROIArray[window.pictureOrientation].y * height, window.ROIArray[window.pictureOrientation].width * width, window.ROIArray[window.pictureOrientation].height * height);
        context.fillStyle = "#000";
        context.lineWidth = 2;
        context.strokeRect(window.ROIArray[window.pictureOrientation].x * width, window.ROIArray[window.pictureOrientation].y * height, window.ROIArray[window.pictureOrientation].width * width, window.ROIArray[window.pictureOrientation].height * height);
    }
}

function ROIsetDims(width, height)
{
    window.width = width;
    window.height = height;
}
