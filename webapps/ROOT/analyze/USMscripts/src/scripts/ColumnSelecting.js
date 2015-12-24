//A test variable to see if all images in the table are selected or not
window.selectAllCheck = 1;

//adds or removes a class for selection and orientation to the images in the table by column based on which column header you click
//Probably going to have to change some of the node directories because PicturePost formatting is different than my test formatting
function selectPicturesByColumn(clickedLink){

	//In order to only select one column at a time I first deselect all pictures then do typical selection
	deselectPicturesFromAnalysis();


    var selectedHeaderName = "orientation-" + clickedLink.innerHTML + "-";

    var table = document.getElementById("pictureSet");
    for (var i = 1; i < table.rows.length; i++) {   //i=1 To skip the header row
        var row = table.rows[i]
        for (var j = 0; j < row.cells.length - 1; j++) {
            var cell = row.cells[j];
            
            var temp = cell.childNodes[0].className;
            
		if (temp.indexOf(selectedHeaderName) >= 0) 
		{
		        //tests the current table cell column # against the column # of the selected header
		
		        var id = cell.childNodes[0].id;
		        id = id.replace("picture_", '');
		        if(clickedLink.className.indexOf("column-selected") < 0)
		        {
		        	selectPicture(id);
				// If on first image set this image to the preview picture
				if (i == 1) {
					xhr.open("GET", "/servlet/GetPictureInfo?pictureId=" + id);
					xhr.onreadystatechange=processPictureInfo;
					xhr.send(null);
				}
		        } else
		        {
		        	deselectPicture(id);
		        }
		}
            
        }
    }
    /*
     * The following code makes it possible to select and deselect multiple columns
     * It changes the class name of the link so that you can tell if it was already
     * selected or not. Since Annette wants only one column to be selected at a time
     * I am commenting it out.
     * Ryan Turner - Campus Ventures - June 2014
     
    if(clickedLink.className.indexOf("column-selected") < 0)
    {
    	clickedLink.className = clickedLink.className + 'column-selected';
    } else
    {
    	clickedLink.className = clickedLink.className.replace('column-selected','');
    }*/

}

//This function selects or deselects all images based on the value of the current test
//and changes the text on the button to reflect the current selection status.
function selectAllImages(){
/*
 *	Collin's Select/Deselect All Code
 *	If code is going to be used, be sure to change the text on the button back as well.
 *	Located in post.jsp in /ROOT
 *	Ryan Turner - Campus Ventures - June 2014
 
    if (window.selectAllCheck == 1){
        selectPicturesForAnalysis();
        window.selectAllCheck = 0;
        document.getElementById("selectAllButton").setAttribute("value", "Deselect All Images");
    } else if(window.selectAllCheck == 0){
        deselectPicturesFromAnalysis();
        window.selectAllCheck = 1;
        document.getElementById("selectAllButton").setAttribute("value", "Select All Images");
    }
*/
	
	/* Button now acts as a "deselectAllImages" function but keeping name as "selectAllImages"
	 * to prevent any broken links that I do not know about
	 * Ryan Turner - Campus Ventures - June 2014
	 */ 
	deselectPicturesFromAnalysis();

}
