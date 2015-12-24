package edu.unh.sr.picturepost;

import java.util.*;
import java.io.*;


public class Config {

    private static Map <String,String> configHash;

    private static void setDef(String name, String val) {
    	if (configHash.get(name) == null) {
    		configHash.put(name, val);
    	}
    }
    
    public static void init(final Map<String, String> opts) {
    	configHash = opts;
    	String BASE_PATH = opts.get("BASE_PATH");
        if (BASE_PATH ==  null) {
        	Log.writeLog("BASE_PATH is null");
        	return;
        }
    	setDef("BASE_PATH", BASE_PATH);

        if (opts.get("CONFIG_FILE")==null) {
        	opts.put("CONFIG_FILE", BASE_PATH + "/conf/picturepost.cfg");
        }
    	setDef("CONFIG_FILE", opts.get("CONFIG_FILE"));
    	
        RandomAccessFile file;
        String line, key, value;
        int comment;
        StringTokenizer st;

        try {
            file = new RandomAccessFile(opts.get("CONFIG_FILE"), "r");
            while ((line = file.readLine()) != null) {
                comment = line.indexOf("#");
                if (comment >= 0) {
                    line = line.substring(0, comment);
                }
                line = line.trim();
                st = new StringTokenizer(line);
                if (st.hasMoreTokens()) {
                    key = st.nextToken();
                    value = line.substring(key.length());
                    key = key.trim();
                    value = value.trim();
                    configHash.put(key, value);
                }
            }
            file.close();
        }
        catch (Exception e) {
        	Log.writeLog("could not parse cfg path");
        }
        
        // set reasonable defaults
        setDef("SUPPORT_EMAIL", "root@localhost");
        setDef("LOG", BASE_PATH + "/logs/picturepost.log");
        setDef("HOST", BASE_PATH + "/logs/picturepost.log");
        setDef("EMAIL_COMMAND", "/usr/sbin/sendmail -oi -t");
        setDef("RECAPTCHA_PRIVATE_KEY", "nokey");
        setDef("RECAPTCHA_PUBLIC_KEY", "nokey");
        setDef("CONVERT", "/usr/bin/convert");
        setDef("MAX_FILE_UPLOAD_SIZE", "10485760");
        setDef("DOCUMENT_ROOT_DIR", BASE_PATH + "/webapps/ROOT");
        setDef("PICTURE_DIR", BASE_PATH + "/data/pictures");
        setDef("PICTURE_DIR_URL", "/images/pictures");
        setDef("DB_PORT", "5432");
        setDef("DB_HOST_IP", "127.0.0.1");
        setDef("MAP_FILE", BASE_PATH + "/cgi-bin/modis.map");
        setDef("LAYERS_FILE", BASE_PATH + "/cgi-bin/modis_layers.map");
        
        Log.writeLog("Config Instatiated: " + configHash.toString());
    }

    public static String get(String key) {
        if (configHash == null) {
        	throw new RuntimeException("tried to call Config.get, without calling Config.init first!");
        }
        String retVal = configHash.get(key);
        if (retVal == null) {
            retVal = "";
        }

        return(retVal);
    }
    
    public static String get(String key, String defValue) {
    	String retVal = Config.get(key);
    	if (retVal.equals("")) {
    		retVal = defValue;
    	}
    	return retVal;
    }

}
