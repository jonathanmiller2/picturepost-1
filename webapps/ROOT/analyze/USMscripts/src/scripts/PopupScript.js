//Displays analysis popup window w/animation and blanket.
//Adds event listeners to check for animation completion
//Triggers showContent() upon animation completion.
function ShowPopup(){
    document.getElementById("loadCounter").innerHTML = "Querying Images...";
    document.getElementById("popup").style.visibility = "visible";
    document.getElementById("blanket").style.visibility = "visible";
    if (BrowserDetect.browser != "Explorer") {       //Don't display animations in Interner explorer
        $("#popup").addClass("animate");
        document.getElementById("popup").addEventListener("webkitAnimationEnd", showContent, false);
        document.getElementById("popup").addEventListener("animationend", showContent, false);
    } else{
        showContent();
    }
}

//Displays logo, progress indicator, and loading animation.
//Removes animationend eveny listeners to prevent the events from triggering multiple times
//Processes all selectd images into an array of IDs for use in the analysis.
//Calls greennessAnalysis() and laodDates() when processing is complete.
function showContent(){
    if (BrowserDetect.browser != "Explorer") {
        document.getElementById("popup").removeEventListener("animationend", arguments.callee, false);
        document.getElementById("popup").removeEventListener("webkitAnimationEnd", arguments.callee, false);
        $("#logo").addClass("show");
        $("#loadCounter").addClass("show");
        $("#loadicon").addClass("show");
        $("#loadicon").addClass("rotate");
    }else{                             //Alternate loading animation for IE using jQuery and the JQuery rotate plugin.
        var angle = 0;
        setInterval(function(){
             angle+=10;
             $("#loadicon").rotate(angle);
           },30);
    }
    document.getElementById("logo").style.visibility = "visible";
    document.getElementById("loadicon").style.visibility = "visible";
    document.getElementById("loadCounter").style.visibility = "visible";
    document.getElementById("imageDisplayDiv").style.visibility = "visible"; 
    document.getElementById("imageDisplayDiv").style.display = "block";
    
    createWindowArrays();
    
    var IDArray = new Array();
    
    window.totalImages = 0;
    window.test = false;

    //Process all selected images and organizes them into a multidimensional array of image IDs
    for(var j = 0; j < window.orientations.length; j++){
    	    IDArray[j] = new Array();
    	    IDArray[j][0] = window.orientations[j];
    	    IDArray[j] = IDArray[j].concat(getAllSelectedPictures(window.orientations[j]));
    }

    window.loadedImageCount = 0;
    window.loadedDateCount = 0;
    window.curOrientationIndex = 0;
    loadDates(IDArray, 1);

    for(var i = 0; i < IDArray.length; i++)
    {
    	greennessAnalysis(IDArray[i]);
    }
}

//Hides all elements of the popup window.
function HidePopup(){
    showDataAsGraph();
    document.getElementById("chart2").style.visibility = "hidden";
    document.getElementById("popup").style.visibility = "hidden";
    document.getElementById("blanket").style.visibility = "hidden";
    $("#popup").removeClass("animate");
    $("#logo").removeClass("show");
    $("#loadCounter").removeClass("show");
    $("#chart2").removeClass("show");
    $("#uldiv").removeClass("show");
    document.getElementById("logo").style.visibility = "hidden";
    document.getElementById("loadicon").style.visibility = "hidden";
    document.getElementById("loadCounter").style.visibility = "hidden";
    document.getElementById("uldiv").style.visibility = "hidden";

    //Clears the imageDisplayCanvas when the window closes
    var imageDisplayCanvas = document.getElementById("imageDisplayCanvas");
    var imageDisplayContext = window.imageDisplayCanvas.getContext("2d");
    imageDisplayContext.clearRect(0, 0, 400, 300);
    document.getElementById("imageDisplayDiv").style.visibility = "hidden"; 
   
    //Stops any requests to the server when the window closes.
    xhr.abort();
    window.stop();
}

//Generates a src for an image of the plotted graph and opens a new browser window at that location.  
//Displays an alert if the browser doesn't support this funcion.
function getGraphAsImage(){
    if (BrowserDetect.browser == "Explorer" || BrowserDetect.browser == "An unknown browser"){       
        alert("The image cannot be generated due to limitations of your browser.");
    }else{
        var graphSrc = $('#chart2').jqplotToImageStr({});
        window.open(graphSrc, "_blank");
    }
}

//Displays the data on the graph as CSV data by concatinating the contents
//of window.lineArray into a string that is then displayed.
function getGraphAsCSV(){
    document.getElementById("CSVparagraph").innerHTML = "";
    var data = "";
    for (var j = 0; j < window.orientations.length; j++) {
        var orientation = window.orientations[j];
        if (window.lineArray[orientation][0][0] === null) {

        } else {
            data += orientation + ",<br>,";
            for (var i = 0; i < window.lineArray[orientation].length; i++) {
                data += window.lineArray[orientation][i] + ",<br>,";
            }
        }
    }
    document.getElementById("CSVparagraph").innerHTML = data;

    //Hides the graph and displays the CSV data.
    document.getElementById("chart2").style.visibility = "hidden";
    document.getElementById("CSVDiv").style.visibility = "visible";
    document.getElementById("CSVDiv").style.overflow = "auto";
    document.getElementById("menu2").innerHTML = "Show Data as Graph";
    document.getElementById("menu2").onclick = showDataAsGraph;
}

//Shows the data as a graph by hiding the CSV data and making the graph visible
function showDataAsGraph(){
    document.getElementById("chart2").style.visibility = "visible";
    document.getElementById("CSVDiv").style.visibility = "hidden";
    document.getElementById("CSVDiv").style.overflow = "hidden";
    document.getElementById("menu2").innerHTML = "Show Data as CSV";
    document.getElementById("menu2").onclick = getGraphAsCSV;
}

//Shows the last analysis completed without the need to re-analyze the same images.
function showLastAnalysis(){
    document.getElementById("popup").style.visibility = "visible";
    document.getElementById("blanket").style.visibility = "visible";
    if (BrowserDetect.browser != "Explorer") {       //Don't display animations in Interner explorer
        $("#popup").addClass("animate");
        document.getElementById("popup").addEventListener("webkitAnimationEnd", function(){
            $("#chart2").addClass("show");
            $("#uldiv").addClass("show");
            document.getElementById("chart2").style.visibility = "visible";
            document.getElementById("uldiv").style.visibility = "visible";
            document.getElementById("popup").removeEventListener("webkitAnimationEnd", arguments.callee, false);
        }, false);
        document.getElementById("popup").addEventListener("animationend", function(){
            $("#chart2").addClass("show");
            $("#uldiv").addClass("show");
            document.getElementById("chart2").style.visibility = "visible";
            document.getElementById("uldiv").style.visibility = "visible";
            document.getElementById("popup").removeEventListener("animationend", arguments.callee, false);
        }, false);    
    }else{
        document.getElementById("chart2").style.visibility = "visible";
        document.getElementById("uldiv").style.visibility = "visible";  
    }
}
