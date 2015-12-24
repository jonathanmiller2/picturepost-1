<%@ page import="edu.unh.sr.picturepost.*" %>

<%@ include file="/includes/rememberMe.jsp" %>

<%@ include file="/includes/doctype.jsp" %>
<HTML>
<HEAD>
<TITLE>Picture Post: Help Video: Set Image Scale (Calibrate Image)</TITLE>
<LINK REL="stylesheet" TYPE="text/css" HREF="/css/picturepost.css">
<script type="text/javascript" src="swfobject.js"></script>
<script type="text/javascript">
    swfobject.registerObject("csSWF", "9.0.115", "expressInstall.swf");
</script>
</HEAD>

<BODY>
<%@ include file="/includes/header.jsp" %>

<DIV ID="container" style="padding-left:10px; padding-right:5px; font-weight: bold; font-size: 90%;"> <!-- start container -->

 <TABLE width="100%"  border="0" cellspacing="0" cellpadding="3">
                  <TR>
                    <TD valign="top" width="36%" ><H2 align="left">Help Video<span class="smallerText">*</span>
                       
                  </H2>
                      
                      <p><span class="smallText">Title:</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Trimming Images<br/>
                        <span class="smallText">Software:</span>  Analyzing Digital Images<br/><br/>
                      This video demonstrates  how to quickly reduce the size of an image and focus on the area of most interest.                      </p>
                      <UL>
                      <span class="smallText">
             <LI>How can you reduce the size of a digital image to cut down the amount of time needed for processing?</LI>
             <LI>Can I trim my image without losing information?</LI>
                         </span>
                      </UL> 
                       <STRONG>Suggestions</STRONG>:
                       <UL>
                         <LI>If you are interested in a tree in the middle of your image, you can process that area quickly.
                         <LI>You can always go back and process other areas of an image or process the entire image.                   
                   </UL>
                        </TD>
                    <TD valign="top"><H2 align="left"></H2>
                      <div id="media">
            <object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="600" height="463" id="csSWF" align="left" title="Trimming Images Video">
                <param name="movie" value="resources/movie_TrimmingImages/TrimmingImages.swf" />
                <param name="quality" value="best" />
                <param name="allowfullscreen" value="true" />
                <param name="scale" value="showall" />
                <param name="allowscriptaccess" value="always" />
                <param name="flashvars" value="autostart=false&thumb=FirstFrame.png&thumbscale=45&color=0x1A1A1A,0x1A1A1A" />
                <!--[if !IE]>-->
            <object type="application/x-shockwave-flash" data="resources/movie_TrimmingImages/TrimmingImages.swf" width="600" height="463" align="left">
                    <param name="quality" value="best" />
                    <param name="allowfullscreen" value="true" />
                    <param name="scale" value="showall" />
                    <param name="allowscriptaccess" value="always" />
                    <param name="flashvars" value="autostart=false&thumb=FirstFrame.png&thumbscale=45&color=0x1A1A1A,0x1A1A1A" />
                <!--<![endif]-->
               <div id="noUpdate">
                        <p>The Camtasia Studio video content presented here requires a more recent version of the Adobe Flash Player. If you are you using a browser with JavaScript disabled please enable it now. Otherwise, please update your version of the free Flash Player by <a href="http://www.adobe.com/go/getflashplayer">downloading here</a>.</p>
                    </div>      
                <!--[if !IE]>-->
                </object>
                <!--<![endif]-->
            </object>
             
       
        </div>
                   
                    <P>&nbsp;</P></TD>
                  </TR>
                  <tr>
                  <td>&nbsp;</td>
                  <td>
                  <DIV align="left"> <SPAN class="smallerText"><STRONG>*</STRONG>You need JavaScript to be enabled and the latest version of the Macromedia Flash Player to view the videos. If you are you using a browser with JavaScript disabled please enable it now. Otherwise, please update your version of the free Flash Player by downloading <A href="http://get.adobe.com/flashplayer/" title="Download flash player" target="_blank">here</A></SPAN> </DIV> 
                  </td>
                  </tr>
                  
  </TABLE>

</DIV> <!-- end container -->

<%@ include file="/includes/footer.jsp" %>
</BODY>
</HTML>
