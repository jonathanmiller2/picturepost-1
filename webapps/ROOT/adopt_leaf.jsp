<%@ include file="/includes/common.jsp" %>
<%@ include file="/includes/header.jsp" %>

<script src="http://www.apple.com/library/quicktime/scripts/ac_quicktime.js" language="JavaScript" type="text/javascript"></script>
<script src="http://www.apple.com/library/quicktime/scripts/qtp_library.js" language="JavaScript" type="text/javascript"></script>
<link href="http://www.apple.com/library/quicktime/stylesheets/qtp_library.css" rel="StyleSheet" type="text/css" />


<div align=center>
  <h1 style='display:inline-block;'>Adopt a Leaf, a Bud, or a Branch</h1>
</div>

<%=wu.popNotifications()%>

<style>
#helppagecontent ul {
  padding: 0 0 0 20px;
}
#helppagecontent li + li {
  margin-top: 10px;
}
#helppagecontent img {
  max-width: 100%;
}
</style>

                     
<div class="container" id=helppagecontent>
<div>by Elizabeth Wylde, <A href="http://friendsoffreshpond.org/" target="_blank">Friends of the Fresh Pond Reservation</A>, Cambridge, MA </div>

<div class=well>
Leaves and flowers have a dynamic life &ndash; if you have time to watch. Taking photographs over a period of time and making a movie is one way to begin to appreciate the stages leaves and flowers pass through. </BR>This movie was made using QuickTime Pro, which is the $30 extended version of the freely available Applie QuickTime. New software products are being developed all of the time, and a quick web search will show what is available!</div> 

  <div class="row">
      <H2>Tips</H2>
        <UL>
          <LI>Put a blank, possibly white or light gray piece of cardboard, behind the leaf to make it easier to see the leaf.
          <LI>Consider writing the date on the cardboard or adding the date to each picture using image processing software. 
          <LI>Set up a Picture Post in your garden where you can get a good view of a flower or branch.
          <LI>Try to take pictures during the same time of day to keep the light angle as constant as possible.
          <LI>Mark your leaf or branch with a color piece of string gently wrapped around the stem. 
          <LI>Place an object of known size in the picture to use as a scale.
         </UL>

</div> 

<!--    <script type="text/javascript"><!--
    QT_WritePoster_XHTML('images/SilverMapleMoviestart.jpg',
               '216', '200', '',
        'controller', 'true',
        'autoplay', 'true',
        'bgcolor', 'black',
        'scale', 'aspect');

</script>
<noscript>

                      
                      <object classid="clsid:02BF25D5-8C17-4B23-BC80-D3488ABDDC6B" codebase="http://www.apple.com/qtactivex/qtplugin.cab" name="Movie of budburst on a branch" width="216" height="200" align="right">        
                     <param name="src" value="images/SilverMapleMoviestart.jpg" />        
                     <param name="target" value="myself" />
                     <param name="qtsrc" value="rtsp://realmedia.uic.edu/itl/ecampb5/demo_broad.mov" />        
                     <param name="autoplay" value="true" />        
                     <param name="scale" value="aspect" />
                     <param name="loop" value="true" />        
                     <param name="controller" value="true" />
                     <embed src="images/SilverMapleBudBurst.mov" width="216" height="200" loop="True" align="right" pluginspage="http://www.apple.com/quicktime/download/" controller="true" autoplay="true" name="budburst" target="myself" scale="aspect" type="video/quicktime"></embed>   </object>
      </noscript>

//-->

<script language="javascript">
    QT_WriteOBJECT('images/SilverMapleBudBurst.mov' , '216', '200' , '');
</script>

 <H2>What else can I view?</h2>
                    <UL>
                        <LI>Forsythia
                        <LI>Rose bushes 
                        <LI>Hostas
                        <LI>Vegetables
                        <LI>You choose!
                    </UL>

</DIV> <!-- end container -->

<%@ include file="/includes/footer.jsp" %>
</BODY>
</HTML>
