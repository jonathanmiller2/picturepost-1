<%
  response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1.
  response.setHeader("Pragma", "no-cache"); // HTTP 1.0.
  response.setHeader("Expires", "0"); // Proxies.
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0">
<meta name="description" content="<%= WebUtil.esc(og_description) %>">
<meta name="author" content="Philip.Collins@unh.edu">
<meta property="og:url" content="<%= WebUtil.esc(og_url) %>" />
<meta property="og:type" content="<%= WebUtil.esc(og_type) %>" />
<meta property="og:title" content="<%= WebUtil.esc(og_title) %>" />
<meta property="og:description" content="<%= WebUtil.esc(og_description) %>" />
<meta property="og:image" content="<%= WebUtil.esc(og_image) %>" />
<link rel="icon" href="/favicon.ico">
<link rel="mask-icon" href="pictureposticon.svg" color="#9999CC">
<title>Picture Post</title>
<link href=/css/bootstrap.min.css rel=stylesheet>
<link href=/css/main.css?1 rel=stylesheet>
<script src=/js/jquery.js></script>
<script src=/js/bootstrap.min.js></script>
<script>
  var FACEBOOK_APP_ID="<%=FACEBOOK_APP_ID%>";
</script>
<script src=/js/system.js></script>

<link rel="stylesheet" type="text/css" media="all" href="ou-global-header.css" />
</head>
<body>

<nav class="navbar navbar-default navbar-fixed-top">
  <div class="globalheader">
   <div class="globalheader-wrapper">
      <ul>
          <li><a class="tip home" href="http://www.ou.edu/web.html" alt="OU Home link"><span>OU Homepage</span></a></li>
          <li><a class="tip search" href="http://www.ou.edu/content/ousearch.html" alt="OU Search link"><span>Search OU</span></a></li>
          <li><a class="tip social" href="http://www.ou.edu/web/socialmediadirectory.html" alt="OU Social Media link"><span>OU Social Media</span></a></li>
          <li class="wordmark">The University of Oklahoma</li>
      </ul>
      <div style="clear:both;"></div>
   </div>
  </div>

  <div class="ou-header">
    <a href='/'>
      <img id="logo" src=/includes/ou-emof-logo.png alt="OU EMOF Logo">
    </a>
  </div>

  <div class="container">

    <div class="navbar-header">
      <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
        <span class="sr-only">Toggle navigation</span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
      </button>

      <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#searchbar" aria-expanded="false" aria-controls="navbar" style="padding: 6px 12px;">
        <span class="glyphicon glyphicon-search"  style="padding: 0"></span>
      </button>

      <a href="/" style='text-decoration:none;color:#555;font-size:24px;margin: 6px 6px;display:inline-block;'><img src=/images/logo.png alt="picturepost logo"> picture post</a>
    </div>

    <div class="visible-xs"> <!-- a wrapper div to avoid conflicts with toggle feature -->
    <div id="searchbar" class="navbar-collapse collapse ">
      <div class="input-group" style="padding: 8px;" title="Search news, post names, location, photographer, keywords, ..">
        <input type="text" id=SearchBoxMobile class="form-control" placeholder="Search news, post names, location, photographer, keywords, .." aria-label="...">
        <div class="input-group-btn">
          <button type="button" class="btn btn-default" onclick='$("#SearchBoxMobile").change();'><span class="glyphicon glyphicon-search"></span></button>
        </div>
      </div>
    </div><!--#searchbar-->
    </div> <!-- wrapper -->

    <div id="navbar" class="navbar-collapse collapse">
      <ul class="nav navbar-nav">
        <li><a href="/news.jsp">News</a>
        <li><a href="/map.jsp" title='find a post on a map'>Map</a>
        <li class="dropdown">
          <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">Resources<span class="caret"></span></a>
          <ul class="dropdown-menu">
            <li><a href="/help_addpost.jsp">Add a Picture Post</a>
            <li><a href="/stuffYouCanDo.jsp">Stuff You Can Do</a>
            <li><a href="/buy.jsp">Buy</a>
            <li><a href="/build.jsp">Build</a>
            <li><a href="/community.jsp">Community</a>
            <li><a href="/help.jsp">Help!</a></li>
        </ul>
       <!--<li><a href="/community-donate.jsp" style="color:#D76229" title='Give'>Give</a></li>-->
      </ul>

      <ul class="nav navbar-nav navbar-right">
        <li class="dropdown">

        <% if (sessionuser.isLoggedIn()) { %>
          <a href="/myaccount.jsp" style='padding: 5px 5px 5px 15px;' role="button">My Account:<br><small><%=WebUtil.esc(sessionuser.getPublicName())%></small></a>
        <% } else { %>
          <a href="/login.jsp" style='padding: 15px;'>Login</a>
        <% } %>
        </li>
      </ul>

      <div class="input-group hidden-xs" style="padding: 8px;" title="search news, post names, location, photographer, keywords, ..">
        <input type="text" id=SearchBox class="form-control" placeholder="search news, post names, location, photographer, keywords, .." aria-label="...">
        <div class="input-group-btn">
          <button type="button" class="btn btn-default" onclick='$("#SearchBox").change();'><span class="glyphicon glyphicon-search"></span></button>
        </div>
      </div>


    </div><!--#navbar-->

  </div>
</nav>

<div id=maincontent class="container" role="main">
