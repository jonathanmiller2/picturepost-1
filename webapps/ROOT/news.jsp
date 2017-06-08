<%@ include file="/includes/common.jsp" %>
<%

int MAX_NUM_RESULTS_PER_PAGE = 10;

class NewsItem {
  String rectype;
  int author_id;
  String author;
  int id1;
  int id2;
  String dt;
  String title;
  String content1;
  String content2;
}

Q q = wu.q();
q.append("SELECT rectype,author_id,author,id1,id2,TO_CHAR(dt,'Mon fmDD, YYYY'),title,content1,content2 FROM news");

// add search term
String search = wu.param("q").replace("^\\s+","").replace("\\s+","").replaceAll("\\s+"," & ");
if (! search.equals("")) {
  q.where("txtsearch @@ TO_TSQUERY(?)").bind(search); 
}

// add pagination
int pageNum = wu.param_int("p", 1);
{ if (pageNum <= 1) pageNum = 1;
  int offset = (pageNum - 1) * MAX_NUM_RESULTS_PER_PAGE;
  q.append("ORDER BY dt DESC LIMIT ? OFFSET ?").bind(MAX_NUM_RESULTS_PER_PAGE + 1).bind(offset);
}

// load news
List<NewsItem> news = new ArrayList<NewsItem>();
boolean hasMorePages = false;
while (q.fetch()) {
  if (news.size() == MAX_NUM_RESULTS_PER_PAGE) {
    hasMorePages = true;
    break;
  }
  NewsItem ni = new NewsItem(); 
  ni.rectype = q.get();
  ni.author_id = q.getInt();
  ni.author = q.get();
  ni.id1 = q.getInt();
  ni.id2 = q.getInt();
  ni.dt  = q.get();
  ni.title  = q.get();
  ni.content1 = q.get();
  ni.content2 = q.get();
  news.add(ni); 
}

boolean showNews = true;
String searchTitle;
if (! wu.param("q").equals("")) {
  searchTitle = "<label for=SearchBox><strong>search:</strong> " + WebUtil.esc(wu.param("q")) + "</label>";
  showNews = false;
} else {
  searchTitle = "<label for=SearchBox><strong>showing:</strong> latest articles, new posts and picture sets</label>";
}
%> 
<%@ include file="/includes/header.jsp" %>

<style>
#picpostnews blockquote {
  padding: 0;
}
#picpostnews h2 {
  margin: 0;
}
#picpostnews blockquote > a {
  cursor: pointer;
  display: block;
  text-decoration: none !important;
  padding: 20px;
}
#picpostnews blockquote > a:hover {
  text-decoration: none; 
  background-color: #eee;
}
#picpostnews footer {
  margin-left: 10px;
}
#picpostnews footer a {
  margin: 10px;
}
.picsetannotation, .postcontent {
  font-size: .9em;
  margin-top: 10px;
}

#SearchDescr label {
  font-weight: normal;
}
#ViewMoreBut {
  display: block;
  max-width: 300px;
  margin: 30px auto;
  width: 90%;
}
</style>

<%=wu.popNotifications()%>

<div id=SearchDescr class=well><%= searchTitle %></div>


<% if (showNews == true) { 
  // LATEST NEWS HTML HERE %>
<div id=picpostnewscustom>
 <H3>603 Challenge - Your Gift up to $150 to DEW Picture Post starting June 3 may be doubled with matching funds.  <a href = "http://hosted.verticalresponse.com/1051743/f11d446eb8/519485881/e42887c9be/" target="_blank" title="603 challenge">Learn more here.</H3>
 <li><a href="gallery-newsletters.jsp" title="newsletters">Newsletters</a></li>
          <li><a href="http://panopicturepost.tumblr.com" target="_blank" title="tumblr blog of panoramas">Follow us on Tumblr</a></li>
          <br>
</div>
<%
  // END LATEST NEWS HERE
} %>


<div id=picpostnews>
  <%for (NewsItem ni : news) {%>

    <% if ("story".equals(ni.rectype)) { %>
      <blockquote class=newsstory>
        <h2><%=ni.title%></h2>
        <%=ni.content1%>
        <footer>
          <%=WebUtil.esc(ni.author)%> on <%=WebUtil.esc(ni.dt)%>
          <% if (sessionuser.getAdmin()) {%>
            <a href="story.jsp?id=<%=ni.id1%>">edit</a>
          <% } %>
        </footer>
      </blockquote>
    <% } else if ("picset".equals(ni.rectype)) {
      String preview;
      { StringBuilder buf = new StringBuilder();
        String[] pic_ids = ni.content2.split(",");
        int len = pic_ids.length;
        for (int i=0; i < len; ++i) {
          String pic_id = pic_ids[i];
          if (! "0".equals(pic_id)) {
            buf.append("<img alt='Preview Orientation' src='/images/pictures/post_"+ni.id1+"/picture_"+pic_id+"_thumb.jpg'>");
          }
        }
        preview = buf.toString();
      } %>
      <blockquote class=newspicset>
        <a href='post.jsp?postId=<%=ni.id1%>#picset=<%=ni.id2%>'>
        <h2>New Pictureset - <%=ni.title%></h2>
        <div class=picsetpreview><%=preview%></div>
        <div class=picsetannotation><%=WebUtil.esc(ni.content1)%></div>
        </a>
        <footer>
          <%=WebUtil.esc(ni.author)%> on <%=WebUtil.esc(ni.dt)%>
          <% if (sessionuser.getPersonId()==ni.author_id || sessionuser.getAdmin()) {%>
            <a href="picset.jsp?id=<%=ni.id2%>">edit</a>
          <% } %>
        </footer>
      </blockquote>
    <% } else if ("post".equals(ni.rectype)) { %>
      <blockquote class=newspost>
        <a href='post.jsp?postId=<%=ni.id1%>'>
          <% if (ni.id2 > 0) { %>
            <img class=pull-left style='margin: 0 10px;' alt="post picture" src="/images/pictures/post_<%=ni.id1%>/post_picture_<%=ni.id2%>_thumb.jpg">
          <% } %>
        <h2>New Post - <%=ni.title%></h2>
        <div class=postcontent><%=ni.content1%></div>
        </a>
        <footer>
          <%=WebUtil.esc(ni.author)%> on <%=WebUtil.esc(ni.dt)%>
          <% if (sessionuser.getPersonId()==ni.author_id || sessionuser.getAdmin()) {%>
            <a href="post.jsp?id=<%=ni.id1%>">edit</a>
          <% } %>
        </footer>
      </blockquote>
    <% } %>
  <%}%>
</div>


<% if (news.size() == 0) { %>
  <div class="alert alert-info">
    <strong>No results found</strong>
  </div>
<% } else { %>
<form>
<input type=hidden name=q value='<%= WebUtil.esc(wu.param("q")) %>'>
<% if (hasMorePages) { %>
  <button id=ViewMoreBut type=submit name=p class='btn btn-primary' value='<%= pageNum + 1 %>'>view more</button>
<% } %>
</form>
<% } %>
<%@ include file="/includes/footer.jsp" %>
