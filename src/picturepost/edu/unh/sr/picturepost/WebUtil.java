package edu.unh.sr.picturepost;

import java.util.*;
import java.util.regex.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.sql.ResultSet;

import org.json.JSONArray;
import org.json.JSONObject;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.ResultSetMetaData;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.*;

import javax.servlet.http.Cookie;


public class WebUtil {
	private String errorRedirectUrl = "/notify.jsp";
	private HttpServletRequest req;
	private HttpServletResponse resp;
    public boolean outputSent = false;
    public boolean pagestate = false;

    private Map<String, String[]> params = new HashMap<String, String[]>();

	public void handleError(Exception e) {
		StringWriter sw = new StringWriter();
		PrintWriter pw = new PrintWriter(sw);
		e.printStackTrace(pw);
		String st = sw.toString();
		Log.writeLog(st);
        addNotificationError(e.getMessage());
        redirect(errorRedirectUrl);
	}
	
	public Connection dbh() {
      return DBPool.getInstance().getConnection();
	}
	public Q q() {
      Q b = new Q(DBPool.getInstance().getConnection());
      return b;
	}
	
	public void cleanup() {
	}

    public static String fix_filename(String fn) {
      Pattern p = Pattern.compile("[\\/\\\\]([^\\/\\\\]+)$");
      Matcher m = p.matcher(fn);
      if (m.find()) fn = m.group(0);
      return fn;
    }

    public void redirect(String url) {
      try {
        outputSent=true;
        resp.sendRedirect(url);
      }
      catch (IOException e) {}
    }

    public void reload(String msg) {
      String url = req.getRequestURL().toString();

      // preserve page state into session
      if ("POST".equals(req.getMethod())) {
        Map<String, Object> p = new HashMap<String, Object>();
        p.putAll(req.getParameterMap());
        p.putAll(params);
        p.remove("act");
        p.remove("pass");
        p.remove("password");
        String k = "postparams_" + url;
	    req.getSession().setAttribute(k, p);
      }
      if (msg != null && msg != "") {
        addNotificationError(msg);
      }

      try {
        outputSent=true;
        resp.sendRedirect(url);
      }
      catch (IOException e) {}
    }

	@SuppressWarnings("unchecked")
	public WebUtil(HttpServletRequest req, HttpServletResponse resp) {
		this.req = req;
		this.resp = resp;
        //this.req.setAttribute("WebUtil", this);

        // restore page state if exists
        String k = "postparams_"+req.getRequestURL().toString();
		Object savedParamsObj = req.getSession().getAttribute(k);
		if (savedParamsObj instanceof Map<?, ?>) {
			params.putAll((Map<String, String[]>) savedParamsObj);
			req.getSession().removeAttribute(k);
            pagestate = true;
		}
    }

    public void addNotificationError(String msg) {
      addNotification("<div class='alert alert-danger alert-dismissible' role='alert'><button type=button class=close data-dismiss=alert aria-label=Close><span aria-hidden=true>&times;</span></button>"+esc(msg)+"</div>");
    }
    public void addNotificationSuccess(String msg) {
      addNotification("<div class='alert alert-success alert-dismissible' role='alert'><button type=button class=close data-dismiss=alert aria-label=Close><span aria-hidden=true>&times;</span></button>"+esc(msg)+"</div>");
    }
	public void addNotification(String html) {
		if (html == null) return;
		Object notifyObj = req.getSession().getAttribute("notifyHtml");
		String notifyHtml = (notifyObj == null) ? html : (String) notifyObj + html;
		req.getSession().setAttribute("notifyHtml", notifyHtml);
	}
	
	public String popNotifications() {
		Object notifyObj = req.getSession().getAttribute("notifyHtml");
		if (notifyObj == null) return "";
		String notifyHtml = (String) notifyObj;
		req.getSession().removeAttribute("notifyHtml");
		return notifyHtml;
	}
    
    public void sendLogin() {
      StringBuffer loginUrl = req.getRequestURL();
      String queryString = req.getQueryString();
      if (queryString != null) {
        loginUrl.append("?").append(queryString);
      }
      req.getSession().setAttribute("loginUrl", loginUrl.toString());
      addNotification("<div class='alert alert-info alert-dismissible' role='alert'><button type=button class=close data-dismiss=alert aria-label=Close><span aria-hidden=true>&times;</span></button><strong>Please login to continue.</strong></div>");
      outputSent=true;
      try { resp.sendRedirect("login.jsp"); }
      catch (IOException e) {}
    }

	public void forgetMe() {
        Cookie rememberMeCookie = new Cookie("rememberMe", "");
        rememberMeCookie.setMaxAge(0); // now
        resp.addCookie(rememberMeCookie);
	}

	private final static Pattern REMEMBERME_V1_PATTERN = Pattern.compile("^1:(\\d+):(.+)$"); 
	public Person getSessionPerson() {
		HttpSession session = req.getSession();
		Person sessionuser = Person.getInstance(session);
		
		// if session user is not logged in, attempt to auto log them in from rememberMe cookie
		if (! sessionuser.isLoggedIn()) {
			Cookie[] cookies = req.getCookies();
			if (cookies != null) {
				for (Cookie c : req.getCookies()) {
					if ("rememberMe".equals(c.getName())) {
						Matcher m = REMEMBERME_V1_PATTERN.matcher(c.getValue());
						if (m.matches()) {
							int userId = Integer.parseInt(m.group(1));
							String cksum1 = m.group(2);
							Person p = new Person(userId);
							String cksum2 = Utils.digest("1:" + userId, p.getPasswordSalt() + Config.get("SECRET"));
							if (cksum1.equals(cksum2)) {
								sessionuser.login(userId);
								break;
							}
						}
					}
				}
			}
		}
		return sessionuser;
	}

    public void redirectPostLogin() {
    
      // set remember me cookie
      HttpSession session = req.getSession();
      Person sessionuser = Person.getInstance(session);
      if (sessionuser.isLoggedIn()) {
        String val = "1:" + sessionuser.getPersonId();
        String cksum = Utils.digest(val, sessionuser.getPasswordSalt() + Config.get("SECRET"));
        String cookieVal = val + ":" + cksum;
        Cookie rememberMeCookie = new Cookie("rememberMe", cookieVal);
        rememberMeCookie.setMaxAge(60 * 60 * 24 * 365); // one year
        resp.addCookie(rememberMeCookie);
      }
      
      String returnPage = "";
      Object loginUrl = req.getSession().getAttribute("loginUrl");
      if (loginUrl != null) {
        returnPage = (String) loginUrl;
        req.getSession().removeAttribute("loginUrl");
      }
      if (! "".equals(param("returnPage"))) {
        returnPage = param("returnPage");
      }
      if ("".equals(returnPage)) {
        returnPage = "/myaccount.jsp";
      }
 
      redirect(returnPage);
    }

    public void uploadbase64photo(String base64, File dir, String name) throws Exception {
      if (! dir.exists()) dir.mkdirs();
      File base64File = new File(dir, name + ".jpgbase64");
      
      FileWriter fw = new FileWriter(base64File);
      BufferedWriter bw = new BufferedWriter(fw);
      bw.write(base64);
      bw.close();
      if (base64File.length() == 0) {
        throw new Exception("invalid file upload");
      }

      // decode base64
      File fullFile = new File(dir, name + ".jpg");
      ProcessBuilder builder = new ProcessBuilder("/usr/bin/base64", "--decode", base64File.toString());
      builder.redirectOutput(fullFile);
      Process p1 = builder.start();
      p1.waitFor();
      if (fullFile.length() == 0) {
        throw new Exception("could not decode base64");
      }

      // create thumbnail
      File thumbFile = new File(dir, name + "_thumb.jpg");
      Process p2 = Runtime.getRuntime().exec(
          "/usr/bin/convert " + fullFile.toString() + " -auto-orient -thumbnail 80x80 " + thumbFile.toString());
      p2.waitFor();
      if (thumbFile.length() == 0) {
        throw new Exception("could not create thumb");
      }

      // create medium
      File medFile   = new File(dir, name + "_medium.jpg");
      Process p3 = Runtime.getRuntime().exec(
        "/usr/bin/convert " + fullFile.toString() + " -auto-orient -thumbnail 400x300 " + medFile.toString());
      p3.waitFor();
      if (medFile.length() == 0) {
        throw new Exception("could note create medium");
      }

      base64File.delete();
    }

    // return stored session param saved by previous posted page or request param
	public String param(String name, String def) {
        String rv = null;

        if (params != null && params.containsKey(name)) {
          String[] vals = params.get(name);
          if (vals != null && vals.length > 0) {
            rv = vals[0];
          }
        }

        else {
          rv = req.getParameter(name);
		  if (rv == null) {
            rv = def;
          }
        }
        if (rv == null) {
          rv = "";
        }
        else {
          rv = rv.trim();
        }
		return rv;
	}
	
	public String param(String name) {
		return param(name, "");
	}

	public String eparam(String name) {
		return WebUtil.esc(param(name, ""));
	}
	
	public int param_int(String name, int def) {
		String v = param(name);
		int v2;
		try {
		  v2 = Integer.parseInt(v);
		} catch (Exception e) {
		  v2 = def;
		}
		return v2;
	}

    public void setparam(String name, Object val) {
      if (val==null) val = "";
      String[] v = new String[] { val.toString() };
      params.put(name, v);
    }

    public void show_params() {
      Map<String, Object> p = new TreeMap<String, Object>();
      p.putAll(req.getParameterMap());
      p.putAll(params);
      StringBuilder buf = new StringBuilder();
      buf.append("PARAMS = (\n");
      for (Map.Entry<String, Object> entry : p.entrySet()) {
        String key = entry.getKey();
        buf.append("  ").append(key);
        if (entry.getValue() instanceof String[]) {
          String[] vals = (String[]) entry.getValue();
          for (String v : vals) {
            buf.append("    *").append(v).append("*\n");
          }
        }
      }
      buf.append(")\n");
      Log.writeLog(buf.toString());
    }
        
	static public String esc(String s) {
        if (s==null || s.equals("")) return "";
	    StringBuilder out = new StringBuilder(Math.max(16, s.length()));
	    for (int i = 0; i < s.length(); i++) {
	        char c = s.charAt(i);
	        if (c > 127 || c == '"' || c == '\'' || c == '<' || c == '>' || c == '&') {
	            out.append("&#");
	            out.append((int) c);
	            out.append(';');
	        } else {
	            out.append(c);
	        }
	    }
	    return out.toString();
	}

    public static String str(Object o) {
      return str(o, "");
    }
    public static String str(Object o, String def) {
      String rv;
      if (o==null) {
        rv = def; 
      } else {
        rv = o.toString();
        if ("".equals(rv)) rv=def;
      }
      return rv;
    }

	public static JSONArray dbJsonObj(ResultSet rs) throws SQLException {
		JSONArray json = new JSONArray();
		ResultSetMetaData rsmd = rs.getMetaData();
		int numColumns = rsmd.getColumnCount();

		while(rs.next()) {
			JSONObject obj = new JSONObject();

			for (int i=1; i<numColumns+1; i++) {
				String column_name = rsmd.getColumnName(i);

				if(rsmd.getColumnType(i)==java.sql.Types.ARRAY){
					obj.put(column_name, rs.getArray(column_name));
				}
				else if(rsmd.getColumnType(i)==java.sql.Types.BIGINT){
					obj.put(column_name, rs.getInt(column_name));
				}
				else if(rsmd.getColumnType(i)==java.sql.Types.BOOLEAN){
					obj.put(column_name, rs.getBoolean(column_name));
				}
				else if(rsmd.getColumnType(i)==java.sql.Types.BLOB){
					obj.put(column_name, rs.getBlob(column_name));
				}
				else if(rsmd.getColumnType(i)==java.sql.Types.DOUBLE){
					obj.put(column_name, rs.getDouble(column_name)); 
				}
				else if(rsmd.getColumnType(i)==java.sql.Types.FLOAT){
					obj.put(column_name, rs.getFloat(column_name));
				}
				else if(rsmd.getColumnType(i)==java.sql.Types.INTEGER){
					obj.put(column_name, rs.getInt(column_name));
				}
				else if(rsmd.getColumnType(i)==java.sql.Types.NVARCHAR){
					obj.put(column_name, rs.getNString(column_name));
				}
				else if(rsmd.getColumnType(i)==java.sql.Types.VARCHAR){
					obj.put(column_name, rs.getString(column_name));
				}
				else if(rsmd.getColumnType(i)==java.sql.Types.TINYINT){
					obj.put(column_name, rs.getInt(column_name));
				}
				else if(rsmd.getColumnType(i)==java.sql.Types.SMALLINT){
					obj.put(column_name, rs.getInt(column_name));
				}
				else if(rsmd.getColumnType(i)==java.sql.Types.DATE){
					obj.put(column_name, rs.getDate(column_name));
				}
				else if(rsmd.getColumnType(i)==java.sql.Types.TIMESTAMP){
					obj.put(column_name, rs.getTimestamp(column_name));   
				}
				else{
					obj.put(column_name, rs.getObject(column_name));
				}
			}
			json.put(obj);
		}

		return json;
	}
	
	
	public static JSONArray dbJsonArray(ResultSet rs) throws SQLException {
		JSONArray json = new JSONArray();
		ResultSetMetaData rsmd = rs.getMetaData();
		int numColumns = rsmd.getColumnCount();

		while(rs.next()) {
			JSONArray obj = new JSONArray();

			for (int i=1; i<numColumns+1; i++) {
				String column_name = rsmd.getColumnName(i);

				if(rsmd.getColumnType(i)==java.sql.Types.ARRAY){
					obj.put(rs.getArray(column_name));
				}
				else if(rsmd.getColumnType(i)==java.sql.Types.BIGINT){
					obj.put(rs.getInt(column_name));
				}
				else if(rsmd.getColumnType(i)==java.sql.Types.BOOLEAN){
					obj.put(rs.getBoolean(column_name));
				}
				else if(rsmd.getColumnType(i)==java.sql.Types.BLOB){
					obj.put(rs.getBlob(column_name));
				}
				else if(rsmd.getColumnType(i)==java.sql.Types.DOUBLE){
					obj.put(rs.getDouble(column_name)); 
				}
				else if(rsmd.getColumnType(i)==java.sql.Types.FLOAT){
					obj.put(rs.getFloat(column_name));
				}
				else if(rsmd.getColumnType(i)==java.sql.Types.INTEGER){
					obj.put(rs.getInt(column_name));
				}
				else if(rsmd.getColumnType(i)==java.sql.Types.NVARCHAR){
					obj.put(rs.getNString(column_name));
				}
				else if(rsmd.getColumnType(i)==java.sql.Types.VARCHAR){
					obj.put(rs.getString(column_name));
				}
				else if(rsmd.getColumnType(i)==java.sql.Types.TINYINT){
					obj.put(rs.getInt(column_name));
				}
				else if(rsmd.getColumnType(i)==java.sql.Types.SMALLINT){
					obj.put(rs.getInt(column_name));
				}
				else if(rsmd.getColumnType(i)==java.sql.Types.DATE){
					obj.put(rs.getDate(column_name));
				}
				else if(rsmd.getColumnType(i)==java.sql.Types.TIMESTAMP){
					obj.put(rs.getTimestamp(column_name));   
				}
				else{
					obj.put(rs.getObject(column_name));
				}
			}
			
			if (numColumns==1) {
				json.put(obj.get(0));
			} else {
				json.put(obj);
			}
		}

		return json;
	}
	

}
