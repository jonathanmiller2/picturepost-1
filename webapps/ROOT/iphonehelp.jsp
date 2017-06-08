<%@ include file="/includes/common.jsp" %>
<%@ include file="/includes/header.jsp" %>

<div align=center>
  <h1 >Instructions for Using the Mobile App</h1>
</div>

<%=wu.popNotifications()%>


<style>
#helppagecontent ul {
  padding: 0 0 0 20px;
}
#helppagecontent li + li {
  margin-top: 10px;
}
</style>


<div class=container>                        
 
 
     <div class="row">
           <div class="col-md-4">
       <h2>Main Screen</h2>

                <img src="images/main_screen.png" alt="Picture Post - Main Screen" width="240" align="center">
                <ol class="text-left">
                    <li ><b>Log In</b>
                        <ul  style="padding:0; margin:0">
                            <li>Tap this button to log in or register if needed. This button changes to "Log Out" after log in.</li>
                            <li>Registering and logging in is only required to upload pictures taken with this app.</li>
                            <li>Browsing online picture sets and taking pictures for your own use do not require registration.</li>
                        </ul>
                    </li>
                    <li><b>All Posts / Favorites</b> This button toggles between showing all Picture Posts on the map or only those set as a "Favorite" post. The button is disabled if there are no "Favorite" posts.</li>
                    <li><b>Position</b> Tap this button to zoom to your current position.</li>
                    <li><b>All Posts List</b> Tap this button to show the list of all posts.</li>
                    <li><b>Favorites List</b> Tap this button to show the list of posts set as a "Favorite".</li>
                </ol>

</div>

      <div class="col-md-4">
       <h2>Post Screen</h2>
 
                 <img src="images/post_screen.png" alt="Picture Post - Post Screen" width="240">
                <ol>
                    <li><b>Favorite Post</b> Toggle this switch to set the post as a "Favorite".</li>
                    <li><b>Take New Picture Set</b> Tap this button to start taking a picture set. <a href="#taking_pictures">More Information</a></li>
                    <li><i>Taken Picture Set</i>
                        <ul style="padding:0; margin:0">
                            <li>Tap on a started picture set to continue taking it.</li> 
                            <li>
                                Swipe to the left on a picture set and select "Delete" to delete a picture set. 
                                <img src="images/swipe_delete.png" class="inline-image"  alt="Picture Post - Swipe Delete"  width="200"><br> 
                                You may also tap the "Edit" button and then tap on red circle next to the picture set. Tap the "Done" button in the upper right corner when finished.<br>
                                <img src="images/edit_delete.png" class="inline-image" alt="Picture Post - Edit Delete"  width="200">
                            </li>
                            <li>Taken picture sets can be saved through iTunes. Picture sets that have been deleted cannot be saved. (See Saving Pictures below).</li>
                        </ul>
                    </li> 
                    <li><i>Picture Set</i> 
                        <ul style="padding:0; margin:0">
                            <li>Tap on a picture set to view it. They will be displayed vertically in a manner similar to when taking a new picture set.</li>
                            <li>Tap on a picture to view the full size version. Double tap or pinch to zoom in and out.</li>
                            <li>Note, some full size pictures are several megabytes in size and may take some time to download on slower networks.</li>
                        </ul>
                    </li>
                </ol>
       </div>
      <div class="col-md-4">
        <h2>Taking Picture Sets</h2>
                <img src="images/new_picture_set.png" alt="Picture Post - New Picture Set Screen" width="240">
                <ul>
                    <li>Tap on the photo placeholder to take a photo for that direction. The standard camera interface will be displayed.</li>
                    <li>Photos must be horizontal. However, only the device itself needs to be horizontal when taking photos. The app can be used in portrait mode
                        and simply turned 90 degrees when taking photos.</li>
                    <li>After a photo has been taken and the next photo in the sequence has not been taken, a prompt will appear asking if it should be.
                    <li>Once a photo has been taken, tapping on the photo again will retake it.</li>
                </ul>
                <h4>Tips for taking photos</h4>
                <ul>
                    <li>Hold the device against the octagon in order to keep it steady.</li> 
                    <li>Turn the device so that home button is on the right side. If the device is positioned so that the home button is on the left, a portion of the photo
                        will be obscured by the post base.</li>
                    <li>The volume up button on earbuds with volume controls e.g. Apple earbuds, can be used as a shutter button.</li> 
                </ul>
      </div>
    </div>
    
     <div class="row">
           <div class="col-md-4">
       <h2>Uploading New Picture Sets</h2>

                 <img src="images/uploading_new_picture_set.png" alt="Picture Post - Uploading Picture Sets" width="240">
                <ul>
                    <li>Tap this button to send unuploaded photos to the Picture Post website.</li>
                    <li>Incomplete picture sets can be uploaded.</li>
                    <li>Photos can be taken after some have been uploaded. Subsequent taps will only upload the new photos.</li>
                    <li>
                        When a photo is uploading, the direction label turns light blue and a progress bar appears.<br>
                        <img src="images/photo_uploading.png" alt="Picture Post - Photo Uploading" class="inline-image" width="240">
                    </li>
                    <li>
                        Once a photo has finished uploading, the direction label turns a light purple.<br>
                        <img src="images/photo_uploaded.png" alt="Picture Post - Photo Uploaded" class="inline-image" width="240">
                    </li>
                </ul>

</div>

      <div class="col-md-4">
       <h2>Saving Pictures</h2>
                <ol>
                    <li>Open iTunes.</li>
                    <li>Go to the device's section in iTunes.</li>
                    <li>Click on the "Apps" tab.</li>
                    <li>Towards the bottom of the page there will be a section titled "File Sharing" with a list of apps on the left. Select "Picture Post".</li>
                    <li>There will be a list of saved picture sets organized in folders on the right. Select the picture set to save and click "Save to..."</li> 
                    <li>You can also delete picture sets from your device in iTunes.</li>
                </ol>
        </div>
     </div>
    
</div container>


<%@ include file="/includes/footer.jsp" %>
