<%@ include file="/includes/common.jsp" %>
<%@ include file="/includes/header.jsp" %>

<div align=center>
  <h1 style='display:inline-block;'>Adopt a Canopy</h1>
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
  <div class="row">
<div><h4>Created by John Pickle, DEW Educator, Arlington, MA </h4></div>

  <p class=clearfix>Every spring and summer, deciduous trees develop and expand new leaves. In the fall, the leaves change color and fall to the ground, starting the cycle again. Taking photographs weekly or monthly and over the years can reveal much about the timing, known as the phenology, of these events as well as the health and fullness of the forest canopy.</P>
  
<H3>Tips</STRONG>:</H3>
     <UL>
         <LI>Locate your Picture Post to get a good view of a single tree or a group of trees of interest.
         <LI>When you take pictures, the date of each picture is stored in the camera and uploaded to the Picture Post database when you upload your photographs. 
         <LI>Try to take pictures during the same time of day to keep the light angle as constant as possible.
         <LI>Place an object of known size in the picture to use as a scale.                        
         <LI>Use the DEW software to measure  percent leaf cover 
                      and monitor the health of the canopy.
        </UL>
</div>        


  
    <H4>The three pictures here show the change in canopy cover of a maple tree over two weeks in spring.</h4> 
                      
 <div class="row">
  <div class="col-md-4">
      <img class='shadow pull-left' src="images/maple040505-400.jpg" style='margin:0 16px 16px 0;'  alt="maple tree before greenup">
  </div>    
   <div class="col-md-4">
      <img class='shadow pull-left' src="images/maple040511-400.jpg"  style='margin:0 16px 16px 0;'  alt="maple tree during greenup">
  </div>
    <div class="col-md-4">
      <img class='shadow pull-left' src="images/maple040518-400.jpg"  style='margin:0 16px 16px 0;'  alt="maple in full leaf canopy">
  </div>  
</DIV> <!-- end container -->

<%@ include file="/includes/footer.jsp" %>
</BODY>
</HTML>
