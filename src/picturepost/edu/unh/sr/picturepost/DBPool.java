package edu.unh.sr.picturepost;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBPool {
  private static final String DB_USER = Config.get("DB_USER");
  private static final String DB_PASS = Config.get("DB_PASSWORD");
  private static final String DB_URL = "jdbc:postgresql://"
     + Config.get("DB_HOST_IP") + ":"
     + Config.get("DB_PORT") + "/"
     + Config.get("DATABASE");
  private static final String DB_BEGIN_SQL = "set search_path = picturepost,public";

  private static final ThreadLocal<Connection> CONNECTION = new ThreadLocal<Connection>();

  private static final DBPool instance = new DBPool();
  private DBPool() {}
  
  static {
  // Load the JDBC driver
    try {
      Class.forName("org.postgresql.Driver");
    }
    catch (Exception e) {
      e.printStackTrace();
    }
  }
  
  static public DBPool getInstance() {
    return instance;
  }
  
  public Connection getConnection() {
    Connection con = CONNECTION.get();
    if (con == null) {
      try {
        con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
        con.prepareStatement(DB_BEGIN_SQL).execute();
        CONNECTION.set(con);
      }
      catch(Exception e) {
        returnConnection(con);
        Log.writeLog("DB error: " + e.getMessage());
        throw new RuntimeException(e);
      }
    }
    return con;
  }

  static public void returnDefaultConnection() {
    Connection con = CONNECTION.get();
    if (con != null) {
      try {
        if (! con.isClosed()) con.close();
      } catch (SQLException e) {
        Log.writeLog("DB error: " + e.getMessage());
      } finally {
        CONNECTION.set(null);
      }
    }
  }
  
  // noop now - all connections are returned using a servlet filter
  public void returnConnection(Connection con) {
  }

  // noop - no pool to desstroy when using pgbouncer
  public void destroyPool() {
  }
}
