<%@ page import="edu.unh.sr.picturepost.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.io.*" %>
<%@ page import="org.json.*" %>
<%@ page import="java.util.regex.*" %>
<%
  WebUtil wu = new WebUtil(request, response);
  Person sessionuser = wu.getSessionPerson();
  String FACEBOOK_APP_ID = Config.get("FACEBOOK_APP_ID");

  // open graph vars
  String og_url;
  { StringBuffer x = request.getRequestURL();
    String y = request.getQueryString();
    if (y != null) x.append("?").append(y);
    og_url = x.toString();
  }

  String og_type = "article";
  String og_title = "picture post";
  String og_description = "Picturepost - share your landscape photos with the community and scientists";
  String og_image = Config.get("URL") + "/images/picturepostlogo_200.png";
%>
