<%@ page import="edu.unh.sr.picturepost.*" %>

<%@ include file="/includes/rememberMe.jsp" %>

<%@ include file="/includes/doctype.jsp" %>
<HTML>
<HEAD>
<TITLE>Picture Post: Help Video: Masking Pixels</TITLE>
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
                      
                      <p><span class="smallText">Title:</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Masking Pixels<br/>
                        <span class="smallText">Software:</span>  Analyzing Digital Images<br/><br/>
                      This video demonstrates  how to identify and isolate specific colors in digital images. The example shows how to use masks to isolate and calculate the area of a leaf that has a specific color characteristic.                      </p>
                     
                      <UL>       
                      <li><span class="smallText"> How can I use the image analysis software to isolate specific colors, and calculate the proportion of the selected colors in a digital image?</span></li>
             <LI><span class="smallText">How can I use the spectral information to measure features in my image?</span></LI>
                        
                      </UL> 
                       <STRONG>Suggestions</STRONG>:
                       <UL>
                         <li>Calculate the proportion of water in a scene.</li>
                         <li>Calculate  the proportion of forests and parks or of roads in a scene. </li>
                         <li>Calculate the amount of flowers on a flowering shrub.</li>
                      </UL>
                        </TD>
                    <TD valign="top"><H2 align="left"></H2>
                      <div id="media">
            <object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="600" height="463" id="csSWF" align="left" title="Masking Pixels in an Image Video">
                <param name="movie" value="resources/movie_MaskingPixels/MaskkingPixelsFinal.swf" />
                <param name="quality" value="best" />
                <param name="allowfullscreen" value="true" />
                <param name="scale" value="showall" />
                <param name="allowscriptaccess" value="always" />
                <param name="flashvars" value="autostart=false&thumb=FirstFrame.png&thumbscale=45&color=0x1A1A1A,0x1A1A1A" />
                <!--[if !IE]>-->
            <object type="application/x-shockwave-flash" data="resources/movie_MaskingPixels/MaskkingPixelsFinal.swf" width="600" height="463" align="left">
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
