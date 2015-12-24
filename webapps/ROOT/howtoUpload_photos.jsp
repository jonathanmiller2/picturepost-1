<%@ page import="edu.unh.sr.picturepost.*" %>

<%@ include file="/includes/rememberMe.jsp" %>

<%@ include file="/includes/doctype.jsp" %>

<script language="javascript"> 
function toggle(showHideDiv, switchTextDiv) {
	var ele = document.getElementById(showHideDiv);
	var text = document.getElementById(switchTextDiv);
	if(ele.style.display == "block") {
    		ele.style.display = "none";
		text.innerHTML = "show";
  	}
	else {
		ele.style.display = "block";
		text.innerHTML = "hide";
	}
} 

function toggle2(showHideDiv, switchTextDiv) {
	var ele = document.getElementById(showHideDiv);
	var text = document.getElementById(switchTextDiv);
	if(ele.style.display == "block") {
    		ele.style.display = "none";
		text.innerHTML = "Show Me";
  	}
	else {
		ele.style.display = "block";
		text.innerHTML = "Close";
	}
}
</script>



<HTML>
<HEAD>
<TITLE>Picture Post: Upload and Share Photographs</TITLE>
<LINK REL="stylesheet" TYPE="text/css" HREF="/css/picturepost.css">
</HEAD>

<BODY>
<%@ include file="/includes/header.jsp" %>

<DIV ID="container" style="padding-left:10px; padding-right:5px; font-weight: bold; font-size: 90%;"> <!-- start container -->

 <TABLE  border="0" cellspacing="0" cellpadding="3">
                  <TR>
                    <TD valign="top" ><H2 align="left"><SPAN class="h3blue">Upload and Share Photographs</SPAN>
                      </H2>
                     <P>Each time you take photographs at a Picture Post, you will want to transfer the photographs to the website to be shared as soon as you can!  (If for some reason you don't get all 9 photos, you can still upload as many as you have on the website).</P>
                       <P>&nbsp;</P>
                      
  
   <div id="headerDiv0">
     <div id="titleText0"><H3><strong>How do I Find the Upload Page? - 3 ways.</STRONG></H3></div>
     <a id="myHeader0" href="javascript:toggle2('myContent0','myHeader0');" >Show Me</a>
     
    </div>
<div style="clear:both;"></div>
<div id="contentDiv0">
     
<div id="myContent0" style="display: none;">&nbsp;
  
                      
                      
                    <table width="100%" border="1" cellspacing="0" cellpadding="10">
                    <tr>
                    <TD valign="top" style="padding-left:10px">
                     
                      <P>&nbsp;</P><P align="right"><SPAN class="smallTextBold">On the map.</SPAN></P>
                      <P><IMG src="/images/upload_homepage.jpg" width="300" height="200" alt="screen shot of the map showing a post information bubble and the upload pictures link"></P></TD>
                      <td>
                      <P align="right"><SPAN class="smallTextBold">On My Page.</SPAN></P>
                      <P><IMG src="/images/upload_mypage.jpg" width="300" height="200" alt="screen shot showing the link to your favorite posts on My page"></P>
                      </td>
                      <td>
                      <P>&nbsp;</P><P align="right"><SPAN class="smallTextBold">On the Post Page.</SPAN></P>
                      <P><IMG src="/images/upload_postpage.jpg" width="300" height="200" alt="screen shot showing upload pictures link on the post page"></P>
                      <P align="right">&nbsp;</P>
                      <P>&nbsp;</P><P></P></TD>
                     
                  
                      </tr>
                      </table>
                      
                                                                 
                      <p>&nbsp;</p>           
</div>

</div>                    
                      
                      
                      
                      <P>&nbsp;</P>
                      <H3 align="left"><SPAN class="h3blue">How do I Upload Pictures? - 2 ways: choose the way that fits you best today!</Span></H3>
                      <P>&nbsp;</P>
                      
                      <blockquote>
                      
                      
                       <div id="headerDiv">
                        <div id="titleText"><strong>1. Select and Upload Individual Pictures</strong>. Choose this for a single set of pictures.</div><a id="myHeader" href="javascript:toggle2('myContent','myHeader');" >Show Me</a>
     <p>&nbsp;</p>
    </div>
    
    </blockquote>
    
<div style="clear:both;"></div>
<div id="contentDiv">
     
<div id="myContent" style="display: none;">&nbsp;

  <P><STRONG>Help Video:</STRONG> <A href="http://media.usm.maine.edu/~jbeaudry/Upload1.mp4" title="Help video on uploading pictures." target="_blank">Uploading Pictures.</A>
<P>&nbsp;</P>
<P><strong>A sample upload session (click on images to enlarge).</strong></P>
 <table width="100%" border="1" cellspacing="0" cellpadding="10">
 <TR>
    <TD><strong>1. </strong>Choose 9 pictures to upload</TD>
    <TD><strong>2. </strong>Files have uploaded but don't match the reference set.</TD>
    <TD><strong>3. </strong>Deleting an incorrect photo</TD>
    
  </TR> 
  <TR>
    <TD><A href="/images/upload_1.tiff"><IMG src="images/upload_1.jpg" width="300" height="200" alt="screen shot showing upload pictures sequence with 9 pictures selected"></A></TD>
    <TD><A href="/images/upload_2.tiff"><IMG src="images/upload_2.jpg" width="300" height="200" alt="screen shot showing upload pictures sequence with 9 pictures in the browse boxes"></A></TD>
    <TD><A href="/images/upload_3.tiff"><IMG src="images/upload_3.jpg" width="300" height="200" alt="screen shot showing upload pictures sequence with 1 picture ready to delete"></A></TD>
    
  </TR>
  <TR>
    <TD><strong>4. </strong>Uploading a replacement photo</TD>
    <TD><strong>5. </strong>Rearranging the photos into the correct order</TD>
    <TD><strong>6. </strong>Check the time and date, and click submit!</TD>
    
  </TR> <TR>
    <TD><A href="/images/upload_4.tiff"><IMG src="images/upload_4.jpg" width="300" height="200" alt="screen shot showing upload pictures sequence with 1 picture replaced"></A></TD>
    <TD><A href="/images/upload_6.tiff"><IMG src="images/upload_6.jpg" width="300" height="200" alt="screen shot showing upload pictures sequence with 2 pictures swapped"></A></TD>
    <TD><A href="/images/upload_7.tiff"><IMG src="images/upload_7.jpg" width="300" height="200" alt="screen shot showing upload pictures sequence with 9 pictures ready to submit"></A></TD>
    
  </TR>
  </table>

  
  
  
                      
                        
                      <p>&nbsp;</p>           
</div>

</div>

<blockquote>
                  
 <div id="headerDiv2">
     <div id="titleText2"><strong>2. Select and Upload Multiple picture sets as Zip Files</strong>. Choose this when you have a lot of pictures to upload! You can also upload single picture sets in a zip file, too.</div>
     <a id="myHeader2" href="javascript:toggle2('myContent2','myHeader2');" >Show Me</a>
     
    </div>
<div style="clear:both;"></div>

</blockquote>

<div id="contentDiv2">
     
<div id="myContent2" style="display: none;">&nbsp;

 <P><strong>A sample upload session (click on images to enlarge).</strong></P>
 <table width="100%" border="1" cellspacing="0" cellpadding="10">
 <TR>
    <TD><strong>1. </strong>Choose 9 (or fewer) pictures to zip up.<br> If not done by the camera, name the images sequentially in the order you want them uploaded.
    <Br> Order should be N, NE, E, SE, S, SW, W, NW, Up </TD>
    <TD><strong>2a. </strong>Select the folder containing the pictures and compress the folder into a zip archive. Right click on the mouse to bring up the menu.
    <BR><strong> OR: 2b. </strong>Select pictures and compress the pictures into a zip archive. Right click on the mouse to bring up the menu.</TD>
    <TD><strong>3. </strong>Once created, you may rename the Zip file and move it to your desktop or other folder that you can easily find.</TD>
    
  </TR> 
  <TR>
    <TD valign="top"><A href="/images/uploadm_1.png"><IMG src="/images/uploadm_1.png" width="300"  alt="screen shot showing upload pictures sequence with 9 pictures selected"></A></TD>
    <TD><p class="smallTextBold">a.</p><A href="/images/uploadm_2a.png"><IMG src="/images/uploadm_2a.png" width="300" alt="screen shot showing upload pictures sequence with 9 pictures in the browse boxes"></A>
    <BR><HR><p class="smallTextBold">b.</p>
    <A href="/images/uploadm_2b.png"><IMG src="/images/uploadm_2b.png" width="300"  alt="screen shot showing upload pictures sequence with 9 pictures in the browse boxes"></A></TD>
    <TD valign="top"><p class="smallTextBold">a.</p><A href="/images/uploadm_3a.png"><IMG src="/images/uploadm_3a.png" width="300"  alt="screen shot showing upload pictures sequence with 1 picture ready to delete"></A>
    <BR><HR><p class="smallTextBold">b.</p>
    <A href="/images/uploadm_3b.png"><IMG src="/images/uploadm_3b.png" width="300"  alt="screen shot showing upload pictures sequence with 1 picture ready to delete"></A>
    </TD>
    
  </TR>
  
  <TR>
    <TD><strong>4. </strong>Add the zip file to the list of files you want to upload.<br>Repeat these steps to upload up to 10 picture sets.</TD>
    <TD><strong>5. </strong>When you are ready, click "Upload" to start the upload process.
    <BR>This could take some time. You can do other things, but do not close the window!</TD>
    <TD><strong>6. </strong>When complete, a link will appear for each picture set that was successfully uploaded. <BR>Click on the link to review and submit your pictures.</TD>
    
  </TR> <TR>
    <TD><A href="/images/uploadm_4.png"><IMG src="images/uploadm_4.png" width="300"  alt="screen shot showing upload pictures sequence with 1 picture replaced"></A>
    <TD><A href="/images/uploadm_5.png"><IMG src="images/uploadm_5.png" width="300"  alt="screen shot showing upload pictures sequence with 2 pictures swapped"></A></TD>
    <TD><A href="/images/uploadm_6.png"><IMG src="images/uploadm_6.png" width="300" alt="screen shot showing upload pictures sequence with 9 pictures ready to submit"></A></TD>
    
  </TR>
  </table>
  
</div>

</div>

                       <P>&nbsp;</P>
                       
                       
                     
                      </TD>
                 </TR>
  
  
  <TR> 
  <TD>                   
                      
        <P><Strong>Tips:</Strong></P>
                      <UL>
                        <LI>Once on the Upload page, follow the instructions to upload and arrange your photos. Make sure you check that the time and date of your photos is correct; you can change it when you upload, or later, if you find a mistake.                        
                        <LI>Use the reference set of pictures to help you place yours in the correct order. If you make a mistake, you can rearrange the order, or you can delete photos and upload the correct ones.
                        
                        <LI>Keep your pictures in a separate folder  for each date and post so that you can easily select the photos to upload 
                        each time you take pictures at your post.                        
                        <LI>Once you are happy with your picture set, click on the Submit button and now you can view your photos along with all of the others taken at your post.
                        </UL>
                      

                    <P>Check out the <A href="stuffYouCanDo.jsp">Stuff You Can Do</A> section of our website for other  tips and  to view our other help videos.</P>
</TD>
</TR>
</TABLE>                  
                   

</DIV> <!-- end container -->

<%@ include file="/includes/footer.jsp" %>
</BODY>
</HTML>
