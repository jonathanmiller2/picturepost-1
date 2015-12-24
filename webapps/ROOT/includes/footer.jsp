</div><!--#maincontent-->

<!-- start footer -->
<div id="footer">
<hr>
 
  <div id=footerattribution>
    Picture Post &copy;
    <%= new java.text.SimpleDateFormat("yyyy").format(new java.util.Date()) %>
      University of New Hampshire, Durham, NH 03824
  </div>
 
  <div id=footerlinks>
    <a href="/about.jsp">About</a> |
    <a href="/termsofservice.jsp">Terms of Service</a> |
    <a target='_new' href="http://www.unh.edu/about/ada.html" target="blank">ADA Disclaimer</a> |
    <a target='_new' href="http://www.usnh.edu/legal/privacy.shtml">Privacy Policy</a> |
    <a href="/contact.jsp">Contact</a>
  </div>

  <div id=footersupport>
    Picture Post is supported by NASA
    <img src="/images/nasalogosm.png" alt="NASA logo" width="40" height="40" />
  </div>
</div>

<% if (! "".equals(Config.get("GOOGLE_ANALYTICS_KEY"))) { %>
<script>
  var url = /^https/.test(location) ? "https://ssl.": "http://www.";
  url += "google-analytics.com/ga.js";
  $.getScript(url, function() {
    var pageTracker = _gat._getTracker('<%= Config.get("GOOGLE_ANALYTICS_KEY") %>');
    pageTracker._trackPageview();
  });
</script>
<% } %>

</body>
</html>
