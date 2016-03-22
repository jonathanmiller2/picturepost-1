<%@ include file="/includes/common.jsp" %>

<%
String[] orientations = {"N", "NE", "E", "SE", "S", "SW", "W", "NW", "UP" };
NumberFormat nf = NumberFormat.getInstance();
nf.setMinimumFractionDigits(6);
nf.setMaximumFractionDigits(6);

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
<link rel="stylesheet" type="text/css" href="USMscripts/src/plugins/dist/jquery.jqplot.css">
<link rel="stylesheet" type="text/css" href="USMscripts/src/stylesheets/PopupStyle.css">
<link rel="stylesheet" type="text/css" href="USMscripts/src/stylesheets/SelectionBox.css">
<link rel="stylesheet" type="text/css" href="USMscripts/src/stylesheets/Post.css">
<link rel="stylesheet" type="text/css" href="USMscripts/src/stylesheets/headerlinkstyle.css">
<link rel="stylesheet" type="text/css" href="USMscripts/src/stylesheets/Buttons.css">
<link rel="stylesheet" type="text/css" href="post.css">
<script>
var postId='<%=String.valueOf(post.getPostId())%>';
var postLat="<%=post.getLat()%>";
var postLon ="<%=post.getLon()%>";
var numPerPage=<%=numPerPage%>;
var curPage=<%=curPage%>;
var postDir="<%=post.getPostDir()%>";
var picDirUrl='<%=Config.get("PICTURE_DIR_URL")%>';
var algorithm="<%=algorithm%>";
var postName="<%=post.getName()%>";
var pictureSetIdString="<%=pictureSetIdString%>";
var curPictureId="<%=String.valueOf(curPictureId)%>";
</script>
<script src=post.js></script>
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
  
  <% if (pictureSetRecords.size() == 0) { %>
  No pictures are available for this post.
<% } else { %>

  <DIV ID="pagingDiv" style='margin-top:1em; text-align: left;'>
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
