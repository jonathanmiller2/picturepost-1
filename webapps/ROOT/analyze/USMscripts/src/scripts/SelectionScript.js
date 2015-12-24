//This function selects all pictures
function selectPicturesForAnalysis() {
    $(".thumbnail-default").each(
		function () {
		    var ID = $(this).attr('id');
		    ID = ID.replace('picture_', '');
		    selectPicture(ID);
		}
	);
}

//This function deselects all pictures
function deselectPicturesFromAnalysis() {
    $(".thumbnail-focus").each(
		function () {
		    var ID = $(this).attr('id');
		    ID = ID.replace('picture_', '');

		    	$("#picture_" + ID).removeClass("thumbnail-focus");
		        $("#picture_" + ID).addClass("thumbnail-default");
			
			for (var i = 0; i < orientationArray.length; i++) {
				orientationArray[i] = 0;
			}
		    //deselectPicture(ID);
		    //removeOrientation(ID);
		}
	);
}

function checkForMultipleColumns() {
   var table = document.getElementById("pictureSet");
   var columnChecker = [0, 0, 0, 0, 0, 0, 0, 0];

   for (var i = 1; i < table.rows.length; i++) {   //i=1 To skip the header row
       var row = table.rows[i]
       for (var j = 0; j < row.cells.length - 1; j++) {
           var cell = row.cells[j];
           var temp = cell.childNodes[0].className;

           if (temp.indexOf("thumbnail-focus") >= 0) {
               columnChecker[j] = 1;
           }
       }
   }
   for(var a = 0; a < columnChecker.length; a++) {
       var count = 0;
       if (columnChecker[a] == 1) {
           count++;
       }
       if (count > 1) {
           deselectPicturesFromAnalysis();
           break;
       }
   }
}

//This function processes all selected images in an orientation and returns an array of all of their IDs.
function getAllSelectedPictures(orientation) {
    window.selectionindex = 0;
    IDarray = new Array();
    $(".orientation-" + orientation + "-").each(
		function (index) {
		    if ($(this).hasClass("thumbnail-focus")) {
		        window.totalImages++;
		        IDarray[window.selectionindex] = $(this).attr('id');
		        window.selectionindex++;
		    }
		}
	);
    return IDarray;
}

//This function parses the url of the webpage to retrieve the post ID and returns it.
function parseURLforPostID() {
    var URL = window.location.href;
    var postID = URL.substr(URL.indexOf('postId=') + 7);
    return postID;
}


