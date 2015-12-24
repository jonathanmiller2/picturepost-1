package edu.unh.sr.picturepost;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/*
 * Q - Query builder, variable binder, and SQL executioner.
 * 
 * Q q = new Q(conn)
 *  .select("apple, pear, MAX(grape) GRAPE")
 *  .from("dfdf")
 *  .where("sd < ?").bind(10)
 *  .where("sdfdf IN (", vallist, ")") // auto bind List of values
 *  .groupby("apple, pear")
 *  .having("MAX(grape) > 10")
 *  .orderby("apple, pear");
 *
 * while (q.fetch()) {
 *   String apple = q.get();
 *   int pear = q.getInt();
 *   String grape = q.get("GRAPE");
 * }
 *
 * // you don't have to use the builder methods
 * // if you don't fetch, get will do it for you
 * // you can also execute the query again by calling bind after a fetch or get  
 * Q q = new Q(conn, "SELECT foo FROM sds WHERE fdf=? LIMIT 1");
 * String foo1 = q.bind(1).get();
 * String foo5 = q.bind(5).get();
 * 
 * 
 * Q q = new Q(conn, "SELECT foo1, foo2 FROM sds");
 * while (q.fetch()) {
 *   System.println(q.get("foo1") + " " + q.get("foo2"));
 * }
 */

public class Q {
 
  Connection conn = null;
  PreparedStatement stmt = null;
  ResultSet rs = null;
  StringBuilder sql = new StringBuilder();
  List<Object> binds = null;

  StringBuilder sql2 = null;

  enum Clause {
    DELETE, INSERT, UPDATE, COMMA, SELECT, FROM, JOIN, WHERE, GROUP_BY, HAVING, ORDER_BY
  }
  Clause statmentType = Clause.SELECT;
  Clause lastClause;

  public Q(Connection conn) {
    this.conn = conn;
  }
  
  public Q(Connection conn, String sql) {
    this.conn = conn;
    this.sql.append(sql);
  }

  public Q insert(String tablename) {
    statmentType = Clause.INSERT;
    lastClause = Clause.INSERT;
    sql2 = new StringBuilder();
    sql.append("INSERT INTO ").append(tablename).append(" (");
    return this;
  }
  public Q update(String tablename) {
    statmentType = Clause.UPDATE;
    lastClause = Clause.UPDATE;
    sql.append("UPDATE ").append(tablename).append(" SET ");
    return this;
  }

  public Q set(String colname, String sqlval) {
  	if (statmentType == Clause.INSERT) {
      if (lastClause == Clause.COMMA) {
  		sql.append(",");
  	  }
  	  sql.append(colname);
  	  sql2.append(sqlval);
  	} else if (statmentType == Clause.UPDATE) {
  	  if (lastClause == Clause.COMMA) {
        sql.append(",");
      }
      sql.append(colname).append("=").append(sqlval);
  	} else {
  		throw new RuntimeException("no statementType defined");
  	}
  	lastClause = Clause.COMMA;
  	return this;
  }
  
  public Q set(String colname, String sqlval, Object val) {
    if ("?".equals(sqlval) && val == null) {
      set(colname, "NULL");
    } else {
      set(colname, sqlval).bind(val);
    }
    return this;
  }
  	

  // add union if previous sql exists
  public int length() {
    return this.sql.length();
  }

  public Q append(String sql) {
    this.sql.append(" ").append(sql).append(" ");
    return this;
  }

  public Q append(Q q) {
    append(q.sql.toString());
    if (q.binds != null) {
      for (Object o : q.binds) bind(o);
    }
    return this;
  }

  public Q select(String sql) {
    if (lastClause == Clause.SELECT) {
      this.sql.append(",");
    }
    else {
      this.sql.append("SELECT ");
    }
    this.sql.append(sql);
    lastClause = Clause.SELECT;
    return this;
  }
  public Q from(String sql) {
    if (lastClause == Clause.FROM) {
      this.sql.append(", ");
    } else {
      this.sql.append(" FROM ");
      lastClause = Clause.FROM;
    }
    this.sql.append(sql);
    return this;
  }
  public Q join(String sql) {
    if (lastClause == Clause.FROM || lastClause == Clause.JOIN) {
      this.sql.append(" JOIN ");
    }
    this.sql.append(sql);
    lastClause = Clause.JOIN;
    return this;
  }
  public Q leftjoin(String sql) {
    if (lastClause == Clause.FROM || lastClause == Clause.JOIN) {
      this.sql.append(" LEFT JOIN ");
    }
    this.sql.append(sql);
    lastClause = Clause.JOIN;
    return this;
  }
  public Q where(String sql) {
    if (lastClause == Clause.WHERE) {
      this.sql.append(" AND ");
    } else {
      this.sql.append(" WHERE ");
      lastClause = Clause.WHERE;
    }
    this.sql.append(sql);
    return this;
  }

  public Q where(String sql1, List<Object> vals, String sql2) {
    this.where(sql1);
    if (vals==null || vals.size() == 0) {
      this.sql.append("NULL");
    } else {
      boolean isFirst = true;
      for (Object v : vals) {
        if (isFirst) {
          isFirst=false;
        } else {
          this.sql.append(",");
        }
        this.sql.append("?");
        bind(v); 
      }
    }
    this.sql.append(sql2);
    return this;
  }

  public Q groupby(String sql) {
    if (lastClause == Clause.GROUP_BY) {
      this.sql.append(",");
    } else {
      this.sql.append(" GROUP BY ");
      lastClause = Clause.GROUP_BY;
    }
    this.sql.append(sql);
    return this;
  }

  public Q having(String sql) {
    if (lastClause == Clause.HAVING) {
      this.sql.append(" AND ");
    } else {
      this.sql.append(" HAVING ");
      lastClause = Clause.HAVING;
    }
    this.sql.append(sql);
    return this;
  }

  public Q orderby(String sql) {
    if (lastClause == Clause.ORDER_BY) {
      this.sql.append(",");
    } else {
      this.sql.append(" ORDER BY ");
      lastClause = Clause.ORDER_BY;
    }
    this.sql.append(sql);
    return this;
  }

  public Q bind(Object val) {
    if (rs != null) {
      try {
        rs.close();
      } catch(Exception e){}
      rs = null;
    }
    if (binds==null) binds = new ArrayList<Object>();
    binds.add(val);
    return this;
  }

  public int execute() {
	  int rv = 0;
	  try {
		  // prepare statment if not already prepared
		  if (stmt==null) {

			  if (statmentType == Clause.INSERT) {
				  sql.append(") VALUES (").append(sql2).append(")");
				  sql2 = null;
			  }	

			  stmt = conn.prepareStatement(sql.toString());
		  }

		  // bind params
		  if (binds != null) {
			  int bindCounter = 1;
			  for (Object o : binds) {
				  stmt.setObject(bindCounter, o);
				  bindCounter++;
		  	}
		  }


		  if (statmentType != Clause.SELECT) {
			  rv = stmt.executeUpdate();
		  } else {
			  rs = stmt.executeQuery();
		  }

		  // clear binds, caller can reuse prepared statement by calling bind again, and calling execute
		  binds = null;
	  } catch (Exception e) {
		  String msg = Utils.dump("Exception: ", e.getMessage(), "\nSQL: ", sql, "\nBINDS: ", binds);
		  Log.writeLog(msg);
		  throw new RuntimeException(msg, e);
	  }
	  return rv;
  }
  
  public void execute(List<Object> binds) {
  	this.binds = binds;
  	this.execute();
  }

  public ResultSet rs() {
    if (rs == null) {
      try {
        this.execute();
      } catch (Exception e) {
        throw new RuntimeException(e);
      }
    }
    return rs;
  }

  private int getCounter = 1;
  public boolean fetch() {
    boolean rv = false;
    try {
      if (rs==null) this.execute();
      getCounter = 1;
      rv = rs.next();
      if (! rv) {
        rs.close();
        rs=null;
      }
    } catch (Exception e) {
      throw new RuntimeException("problem with fetch for SQL: " + sql.toString(), e);
    }
    return rv;
  }

  public String get(String columnLabel) {
    if (rs==null) fetch();
    String rv = null;
    try { rv = rs.getString(columnLabel); }
    catch (Exception e) {}
    return rv;
  }

  public String get() {
    if (rs==null) fetch();
    String rv = null;
    try { rv = rs.getString(getCounter); }
    catch (Exception e) {}
    getCounter++;
    return rv;
  }
  public int getInt() {
    if (rs==null) fetch();
    int rv = 0;
    try { rv = rs.getInt(getCounter); }
    catch (Exception e) {}
    getCounter++;
    return rv;
  }
  public int getInt(String columnLabel) {
    if (rs==null) fetch();
    int rv = 0;
    try { rv = rs.getInt(columnLabel); }
    catch (Exception e) {}
    return rv;
  }

  public boolean getBoolean() {
    if (rs==null) fetch();
    boolean rv = false;
    try { rv = rs.getBoolean(getCounter); }
    catch (Exception e) {}
    getCounter++;
    return rv;
  }
  public boolean getBoolean(String columnLabel) {
    if (rs==null) fetch();
    boolean rv = false;
    try { rv = rs.getBoolean(columnLabel); }
    catch (Exception e) {}
    return rv;
  }
}
