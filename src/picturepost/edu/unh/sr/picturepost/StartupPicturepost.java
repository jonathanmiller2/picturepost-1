package edu.unh.sr.picturepost;

import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Map;

import javax.servlet.*;

public class StartupPicturepost implements ServletContextListener {

	private DBPool dbPool;

	@Override
	public void contextDestroyed(ServletContextEvent ev) {
		String scname = ev.getServletContext().getServletContextName();
		if (scname == null) scname = "null";

        Log.writeLog("Picturepost ("+scname+") is shutting down...");
        
        dbPool.destroyPool();		
	}

	@Override
	public void contextInitialized(ServletContextEvent ev) {		
        Log.writeLog("Picturepost is starting up...");

       	Map<String,String> opts = new Hashtable<String,String>();
       	ServletContext sc = ev.getServletContext();
       	Enumeration<String> pnames = sc.getInitParameterNames();
       	while (pnames.hasMoreElements()) {
       		String name = pnames.nextElement();
       		opts.put(name, sc.getInitParameter(name));
       	}        	
        Config.init(opts);
        
        String defaultLogPath = Config.get("LOG");
        if (! defaultLogPath.equals("")) {
        	Log.setDefaultLogFile(defaultLogPath);
        }
        
        dbPool = DBPool.getInstance();		
	}
}
