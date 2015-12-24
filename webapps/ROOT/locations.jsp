<%@ include file="/includes/common.jsp" %>
<%
String lat = request.getParameter("lat");
String lon = request.getParameter("lon");

Q q = wu.q();
String sql = "";


sql = "SELECT post.post_id, post.person_id, name, description, TO_CHAR(install_date,'Mon fmDD, YYYY'), postpic.post_picture_id, ST_Distance(post.location, ST_GeogFromText(?))/1609.34 AS distance, ST_AsText(location), ST_X(location), ST_Y(location), first_name, last_name  FROM post  JOIN person on (post.person_id=person.person_id)   JOIN ( SELECT DISTINCT post_id, FIRST_VALUE(post_picture_id) OVER w AS post_picture_id FROM post_picture WHERE active=true WINDOW w as (PARTITION BY post_id ORDER BY seq_nbr)) postpic on (post.post_id=postpic.post_id)  WHERE post.ready=true    ORDER BY 7 asc LIMIT 50";
String point = "SRID=4326;Point("+WebUtil.esc(lon)+" "+WebUtil.esc(lat)+")";
q.append(sql).bind(point);

//out.println(point);


int i = 0;
int post_id = 0;
int person_id = 0;
int post_picture_id = 0;
String name = "";
String description = "";
String install_date = "";
String first_name = "";
String last_name = "";
//String distance = "";
double distance = 0;
String location = "";
double longitude = 0;
double latitude = 0;

while (q.fetch()) {
//post
  post_id = q.getInt();
  person_id = q.getInt();
  name = q.get();
  description = q.get();
  install_date = q.get();
//post_pic
  post_picture_id = q.getInt();
//custom fields
  distance = Double.parseDouble(q.get());
  location = q.get();
  longitude = Double.parseDouble(q.get());
  latitude = Double.parseDouble(q.get());
//person
  first_name = q.get();
  last_name = q.get();

%>
<div id='nearbypost'>
<h3><a href="/post.jsp?postId=<%=post_id%>"><%=name%></a></h3>
<%
if(!description.equals("")) {
%><a href="/post.jsp?postId=<%=post_id%>">
<img class='post_picture' src="/images/pictures/post_<%=post_id%>/post_picture_<%=post_picture_id%>_medium.jpg"></img>
</a>
<div class='postdesc'> <%=WebUtil.esc(description)%> </div>
<%
}
%>
Installed by <%=WebUtil.esc(first_name)%> <%=WebUtil.esc(last_name)%> on <%=WebUtil.esc(install_date)%>.<br>
<%=Math.round(distance*1000.0)/1000.0%> miles, located at lat/lon: (<%=Math.round(latitude*1000.0)/1000.0%>, <%=Math.round(longitude*1000.0)/1000.0%>)
</div>
<hr class='post_picture'>
<%
  i++;
}
%>
