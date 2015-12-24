package edu.unh.sr.picturepost;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.*;
import java.security.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class Utils {
	
    private Utils () { }

	public static Q q() {
      Q b = new Q(DBPool.getInstance().getConnection());
      return b;
	}

    public static String htmlEscape(String s) {
       if (s == null) { 
           return("");
       }

       s = s.replaceAll("[^\\x00-\\x7F]", "");
       StringBuilder buf = new StringBuilder(s.length());
       for (int i = 0; i < s.length(); i++) {
           char c = s.charAt(i);
           if (c == '&') {
               buf.append("&#38;");
           }
           else if (c == '<') {
               buf.append("&#60;");
           }
           else if (c == '>') {
               buf.append("&#62;");
           }
           else if (c == '"') {
               buf.append("&#34;");
           }
           else if (c == '\'') {
               buf.append("&#39;");
           }
           else {
               buf.append(c);
           }
       }

       return(buf.toString().trim());
    }

    public static String generateRandomString(int length) {
        StringBuffer buffer = new StringBuffer();
        Random random = new Random();
        char[] chars = new char[62];

        // Initialize the array of valid characters (62 total).
        int v = 0;
        for (char c = 'A'; c <= 'Z'; c++) {
            chars[v++] = c;
        }
        for (char c = 'a'; c <= 'z'; c++) {
            chars[v++] = c;
        }
        for (char c = '0'; c <= '9'; c++) {
            chars[v++] = c;
        }

        // Create the random string.
        for (int i = 0; i < length; i++) {
            buffer.append(chars[random.nextInt(chars.length)]);
        }

        return buffer.toString();
    }


    public static String padString(String str, char pad, int length) {
        String retVal = str;

        for (int i = str.length(); i < length; i++) {
            retVal = String.valueOf(pad) + retVal;
        }
        return(retVal);
    }


    // Joins an array of Strings into a single String using the given delimeter.
    public static String join(String[] strings, String delimeter) {
        String retVal = null;


        if (strings != null) {
            retVal = strings[0];
            for (int i = 1; i < strings.length; i++) {
                retVal += delimeter + strings[i];
            }
        }

        return(retVal);
    }
    
    // takes a vector of strings and returns a string with each element double quoted separated by commas
    public static String join_dq(Vector<String> strings) {
        StringBuffer buf = new StringBuffer();
        for (String s : strings) {
        	if (s == null) continue;
       		s = s.replaceAll("\"", "");
       		if (s.equals("")) continue;
       		if (buf.length() > 0) buf.append(", ");
       		buf.append('"').append(s).append('"');
        }
        return buf.toString();
    }

    // Joins a vector of Strings into a single String using the given delimeter.
    public static String join(Vector<String> strings, String delimeter) {
        String retVal = null;


        if (strings != null && strings.size() > 0) {
            retVal = strings.get(0);
            for (int i = 1; i < strings.size(); i++) {
                retVal += delimeter + strings.get(i);
            }
        }

        return(retVal);
    }

    // Truncates a String.
    public static String truncate(String str, int maxLength) {
        String retVal = str;


        if (str != null && str.length() > maxLength) {
            retVal = str.substring(0, maxLength);
        }

        return retVal;
    }


    public static String cleanup(String s) {
        if (s == null) {
            return("");
        }
        else {
            return(s.trim());
        }
    }

    public static String timeInterval(java.sql.Timestamp time1) {
        return timeInterval(time1, new java.sql.Timestamp(Calendar.getInstance().getTimeInMillis()));
    }

    public static String timeInterval(java.sql.Timestamp time1, java.sql.Timestamp time2) {
        long deltaMillis, deltaSeconds, deltaMinutes, deltaHours, deltaDays, deltaWeeks, deltaMonths, deltaYears;
        String retVal = "???";

        if (time2.after(time1)) {
            deltaMillis  = time2.getTime() - time1.getTime();
            deltaSeconds = deltaMillis / (1000L);
            deltaMinutes = deltaMillis / (1000L * 60);
            deltaHours   = deltaMillis / (1000L * 60 * 60);
            deltaDays    = deltaMillis / (1000L * 60 * 60 * 24);
            deltaWeeks   = deltaMillis / (1000L * 60 * 60 * 24 * 7);
            deltaMonths  = deltaMillis / (1000L * 60 * 60 * 24 * 30);
            deltaYears   = deltaMillis / (1000L * 60 * 60 * 24 * 365);
            if (deltaYears > 0) {
                retVal = String.valueOf(deltaYears) + ((deltaYears == 1) ? " year" : " years") + " ago";
            }
            else if (deltaMonths > 0) {
                retVal = String.valueOf(deltaMonths) + ((deltaMonths == 1) ? " month" : " months") + " ago";
            }
            else if (deltaWeeks > 0) {
                retVal = String.valueOf(deltaWeeks) + ((deltaWeeks == 1) ? " week" : " weeks") + " ago";
            }
            else if (deltaDays > 0) {
                retVal = String.valueOf(deltaDays) + ((deltaDays == 1) ? " day" : " days") + " ago";
            }
            else if (deltaHours > 0) {
                retVal = String.valueOf(deltaHours) + ((deltaHours == 1) ? " hour" : " hours") + " ago";
            }
            else if (deltaMinutes > 0) {
                retVal = String.valueOf(deltaMinutes) + ((deltaMinutes == 1) ? " minute" : " minutes") + " ago";
            }
            else {
                retVal = String.valueOf(deltaSeconds) + ((deltaSeconds == 1) ? " second" : " seconds") + " ago";
            }
        }

        return retVal;
    }

    public static boolean isValidTimestamp(String timestamp) {
        int[] daysInMonth = {0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

        if (!timestamp.matches("\\d{14}")) {
            return(false);
        }
        String year   = timestamp.substring(0, 4);
        String month  = timestamp.substring(4, 6);
        String day    = timestamp.substring(6, 8);
        String hour   = timestamp.substring(8, 10);
        String minute = timestamp.substring(10, 12);
        String second = timestamp.substring(12, 14);

        if (Integer.parseInt(month) < 1 || Integer.parseInt(month) > 12) {
            return(false);
        }

        if (Integer.parseInt(day) < 1) {
            return(false);
        }
        if ((Integer.parseInt(month) == 2) && ((Integer.parseInt(year) % 4 == 0) && ((Integer.parseInt(year) % 100 != 0) || (Integer.parseInt(year) % 400 == 0)))) {
            if (Integer.parseInt(day) > 29) {
                return(false);
            }
        }
        else {
            if (Integer.parseInt(day) > daysInMonth[Integer.parseInt(month)]) {
                return(false);
            }
        }

        if (Integer.parseInt(hour) > 23) {
            return(false);
        }

        if (Integer.parseInt(minute) > 59) {
            return(false);
        }

        if (Integer.parseInt(second) > 59) {
            return(false);
        }

        return(true);
    }

    // Converts a date from yyyyddd to yyyy-mm-dd format.
    public static String yyyyddd2yyyymmdd(String yyyyddd) {
        String retVal = yyyyddd;
        int[][] daytab = { {0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31},
                           {0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31} };
        int yyyy, ddd, i;
        String yyyyStr, mmStr, ddStr;
        int leap = 0;


        if (yyyyddd.length() == 7) {
            yyyy = Integer.parseInt(yyyyddd.substring(0, 4));
            ddd  = Integer.parseInt(yyyyddd.substring(4, 7));
            if (yyyy % 4 == 0 && yyyy % 100 != 0 || yyyy % 400 == 0) {
                leap = 1;
            }
            for (i = 1; ddd > daytab[leap][i]; i++) {
                ddd -= daytab[leap][i];
            }
            yyyyStr = yyyyddd.substring(0, 4);
            mmStr = String.valueOf(i); while (mmStr.length() < 2) mmStr = "0" + mmStr;
            ddStr = String.valueOf(ddd); while (ddStr.length() < 2) ddStr = "0" + ddStr;


            retVal = yyyyStr + "-" + mmStr + "-" + ddStr;
        }

        return(retVal);
    }


    // Converts a date from yyyy-mm-dd to yyyyddd format.
    public static String yyyymmdd2yyyyddd(String yyyymmdd) {
        String retVal = yyyymmdd;
        int[][] daytab = { {0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31},
                           {0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31} };
        int yyyy, mm, dd, ddd, i;
        String yyyyStr, dddStr;
        int leap = 0;

        if (yyyymmdd.length() == 10) {
            yyyy = Integer.parseInt(yyyymmdd.substring(0, 4));
            mm   = Integer.parseInt(yyyymmdd.substring(5, 7));
            dd   = Integer.parseInt(yyyymmdd.substring(8, 10));
            if (yyyy % 4 == 0 && yyyy % 100 != 0 || yyyy % 400 == 0) {
                leap = 1;
            }
            for (i = 0, ddd = 0; i < mm && i < 12; i++) {
                ddd += daytab[leap][i];
            }
            ddd += dd;
            yyyyStr = yyyymmdd.substring(0, 4);
            dddStr = String.valueOf(ddd); while (dddStr.length() < 3) dddStr = "0" + dddStr;

            retVal = yyyyStr + dddStr;
        }

        return(retVal);
    }
    
    // parse a date string in some format
    private static String[] DATE_FORMATS = new String[]{
    		"yyyy-MM-dd'T'HH:mm:ss.SSS",
    		"yyyy-MM-dd'T'HH:mm:ss",
    		"yyyy-MM-dd'T'HH:mm",
    		"yyyy-MM-dd'T'HH",
    		"yyyy-MM-dd",
    		"yyyy-MM",
    		"yyyy-MM-dd HH:mm:ss.SSS",
    		"yyyy-MM-dd HH:mm:ss",
    		"yyyy-MM-dd HH:mm",
    		"yyyy-MM-dd HH",
    		"MM/dd/yyyy HH:mm:ss.SSS",
    		"MM/dd/yyyy HH:mm:ss",
    		"MM/dd/yyyy HH:mm",
    		"MM/dd/yyyy",
    		"yyyyMMddHHmmss",
    		"yyyyMMddHHmm",
    		"yyyyMMdd",
    		"yyyy-MM-dd'T'HH:mm'Z'",
    		"yyyy-MM-dd'T'HH:mm:ss'Z'",
    		"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
    		"yyyy-MM-dd'T'HH:mmZZZZ",
    		"yyyy-MM-dd'T'HH:mm:ssZZZZ",
    		"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ",
    		"HH:mm:ss.SSS",
    		"HH:mm:ss",
    		"HH:mm",
    		"yyyy-'W'ww"
};
    public static Date parseDate(String dateStr) {
    	Date rv = null;
    	for (String dfs : DATE_FORMATS) {
    		try {
    			DateFormat df = new SimpleDateFormat(dfs);
    			df.setLenient(false);
    			rv = df.parse(dateStr);
    			//Log.writeLog("parsed date " + dateStr + " using format: " + dfs + " into " + rv.toString());
    			break;
    		}
    		catch (Exception e){}
    	}
    	return rv;
    }
    
    public static String getHtml5DateTime(Date dt) {
    	if (dt == null) return "";
    	SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
    	return df.format(dt);
    }

    public static java.sql.Timestamp getCurrentTimestamp() {
    	java.sql.Timestamp retTimestamp = null;
        String sqlText = "select current_timestamp as theTime";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
        	conn = DBPool.getInstance().getConnection();
        	stmt = conn.prepareStatement(sqlText);
        	rs = stmt.executeQuery();
        	if (rs!=null && rs.next()) {
        		retTimestamp = rs.getTimestamp("theTime");
        	}
        	else {
        		Log.writeLog("ERROR: Utils.java, getCurrentTimestamp(), sqlText = " + sqlText);
        	}
        }
        catch (Exception e) {
        	Log.writeLog("ERROR: Utils.java, getCurrentTimestamp(), sqlText = " + sqlText + ", " + e.toString());
        }
        finally { 
          try { stmt.close(); } catch (Exception e) { }
          DBPool.getInstance().returnConnection(conn);
        }
        return retTimestamp;
    }

    public static String toPaddedHexString(byte[] byteArray) {
        StringBuilder hex = new StringBuilder(byteArray.length * 2);

        for (int i = 0; i < byteArray.length; i++) {
            hex.append(String.format("%02X", byteArray[i]));
        }

        return hex.toString();
    }

    public static String generateSalt() {
        Random random = new Random();

        byte[] byteArray = new byte[8];
        random.nextBytes(byteArray);

        return toPaddedHexString(byteArray);
    }

    public static String digest(String text, String salt) {
        String retVal = "?";

        try {
            // Create a MesssageDigest instance using SHA-256 algorithm.
            MessageDigest messageDigest = MessageDigest.getInstance("SHA-256");
            messageDigest.reset();

            // Start with the salt.
            messageDigest.update(salt.getBytes("UTF-8"));

            // Add the text and digest...
            byte[] byteArray = messageDigest.digest(text.getBytes("UTF-8"));

            // Digest the resulting byteArray (iterate) 1000 times.
            for (int i = 0; i < 1000; i++) {
                messageDigest.reset();
                byteArray = messageDigest.digest(byteArray);
            }

            retVal = toPaddedHexString(byteArray);
        }
        catch (Exception e) { }

        return retVal;
    }
    
    public static String dump(Object... args) {
    	StringBuffer buf = new StringBuffer();
    	for (Object o : args) {
    		if (buf.length()!=0) buf.append(" ");
    		if (o==null) buf.append("null");
    		else buf.append(o.toString());
    	}
    	return buf.toString();
    }
}
