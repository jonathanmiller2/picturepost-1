package edu.unh.sr.picturepost;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimeZone;
import java.io.*;


public class Log {
	
	private static String DEFAULT_LOG_PATH;
	
	public synchronized static void setDefaultLogFile(String path) {
		DEFAULT_LOG_PATH = path;
		writeLog("set default log path to " + path);
	}
	
	public synchronized static void writeLog(String msg) {
		writeLog(msg, DEFAULT_LOG_PATH);
    }

    public synchronized static void writeLog(String msg, String logFile) {
    	DateFormat f = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss  ");
    	TimeZone tz = TimeZone.getDefault();
    	f.setTimeZone(tz);
    	String dateStr = f.format(new Date());
    	
    	boolean reported = false;
    	if (logFile != null) {
    		try {
    			RandomAccessFile log = new RandomAccessFile(logFile, "rw");
    			log.seek(log.length());
    			log.writeBytes(dateStr);
    			log.writeBytes(msg);
    			log.writeBytes("\n");
    			log.close();
    			reported = true;
    		}
    		catch (Exception e) {
    			// noop
    		}
    	}
    	if (! reported) {
    		System.err.println(dateStr + msg);
    	}
    }
    	
    public static void sendEmail(String from, String to, String subject, String body) {
    	// if not a live server, redirect email to SUPPORT_EMAIL config
        if (! Config.get("MODE").equals("live")) {
        	body = "DEVELOPMENT MODE - This email was going to be sent to: " + to + "\n\n" + body;
        	to = Config.get("SUPPORT_EMAIL");
        }
    	
        Runtime rt;
        Process p;
        PrintStream out;

        rt = Runtime.getRuntime();
        try {
            p = rt.exec(Config.get("EMAIL_COMMAND") + " -F " + from + " -f " + from);
            out = new PrintStream(p.getOutputStream());
            out.println("To: " + to);
            out.println("Subject: " + subject);
            out.println();
            out.println(body);
            out.close();
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Log.java, sendEmail(String from, String to, String subject, String body), " + e.toString());
        }
    }
}
