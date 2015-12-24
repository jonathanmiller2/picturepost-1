package edu.unh.sr.picturepost;

import java.sql.*;
import java.util.*;
import javax.servlet.http.*;

public class Person {
    public static final int NOT_LOGGED_IN  = 0;
    public static final int EXPLICIT_LOGIN = 2;

    private int personId                              = 0;
    private String email                              = "";
    private String encryptedPassword                  = "";
    private String passwordSalt                       = "";
    private String firstName                          = "";
    private String lastName                           = "";
    private String phone                              = "";
    private String mobilePhone                        = "";
    private String username                           = null;
    private String facebookId                         = null;
    private java.sql.Timestamp signupTimestamp        = null;
    private boolean admin                             = false;
    private String confirmationKey                    = "";
    private boolean confirmed                         = false;
    private String resetPasswordKey                   = "";
    private java.sql.Timestamp resetPasswordTimestamp = null;

    private HttpSession session = null;
    private int loginState = Person.NOT_LOGGED_IN;

    public Person() {
        clear();
    }

    public Person(HttpSession session) {
        clear();
        setSession(session);
    }

    public Person(int personId) {
        clear();
        dbSelect(personId);
    }

    public String getPublicName() {
      String rv;
      if (! isLoggedIn()) rv = "public";
      else {
        rv = getUsername();
        if (rv == null || "".equals(rv)) rv = getEmail();
        if (rv == null || "".equals(rv) && (getFirstName() != null && getLastName() != null)) rv = getFirstName() + " " + getLastName();
        if (rv == null || "".equals(rv)) rv = "user"+getPersonId();
      }
      return rv;
    }

    public void clear() {
        setPersonId(0);
        setEmail("");
        setEncryptedPassword("");
        setPasswordSalt("");
        setFirstName("");
        setFacebookId("");
        setFacebookId("");
        setUsername(null);
        setLastName("");
        setPhone("");
        setMobilePhone("");
        setSignupTimestamp(null);
        setAdmin(false);
        setConfirmationKey("");
        setConfirmed(false);
        setResetPasswordKey("");
        setResetPasswordTimestamp(null);

        setLoginState(Person.NOT_LOGGED_IN);
    }
    
    public static Person getInstance(HttpSession session) {
        Person person = (Person)session.getAttribute("person");
        if (person == null) {
            person = new Person(session); 
            session.setAttribute("person", person);
        }
        return person;
    }

    public boolean dbSelect(int personId) {
        boolean retVal = false;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        sqlText = "SELECT email, encrypted_password, password_salt, first_name, last_name, phone, mobile_phone, signup_timestamp, admin, confirmation_key, confirmed, reset_password_key, reset_password_timestamp, username, facebook_id FROM person WHERE person_id = ?";
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, personId);
            rs = stmt.executeQuery();
            if (rs != null && rs.next()) {
                setPersonId(personId);
                setEmail(rs.getString("email"));
                setEncryptedPassword(rs.getString("encrypted_password"));
                setPasswordSalt(rs.getString("password_salt"));
                setFirstName(rs.getString("first_name"));
                setFacebookId(rs.getString("facebook_id"));
                setLastName(rs.getString("last_name"));
                setPhone(rs.getString("phone"));
                setMobilePhone(rs.getString("mobile_phone"));
                setSignupTimestamp(rs.getTimestamp("signup_timestamp"));
                setAdmin(rs.getBoolean("admin"));
                setConfirmationKey(rs.getString("confirmation_key"));
                setConfirmed(rs.getBoolean("confirmed"));
                setResetPasswordKey(rs.getString("reset_password_key"));
                setResetPasswordTimestamp(rs.getTimestamp("reset_password_timestamp"));
                setUsername(rs.getString("username"));
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Person.java, dbSelect(int personId), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return retVal;
    }
    
    public void login(int personId) {
        try {          
        	dbSelect(personId);
            setLoginState(Person.EXPLICIT_LOGIN);
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Person.java: login(" + personId + ")");
        }
    }

    public void login(String email, String password) {
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        // check against email if contains @ symbol otherwise check username
        if (email.contains("@")) {
            sqlText = "SELECT person_id, encrypted_password, password_salt FROM person WHERE UPPER(email) = ? AND confirmed = true";
        }
        else {
            sqlText = "SELECT person_id, encrypted_password, password_salt FROM person WHERE UPPER(username) = ? AND confirmed = true";
        }

        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setString(1, email.toUpperCase());
            rs = stmt.executeQuery(); 
            if (rs != null && rs.next() && Utils.digest(password, rs.getString("password_salt")).equals(rs.getString("encrypted_password"))) {
                dbSelect(rs.getInt("person_id"));
                setLoginState(Person.EXPLICIT_LOGIN);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Person.java: login(String email, String password), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }
    }

    public void logout() {
        clear();
    }

    public boolean dbInsert() {
        boolean retVal = false;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;

        if (getPersonId() > 0) {
            sqlText = "INSERT INTO person VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            try {
                conn = DBPool.getInstance().getConnection();
                stmt = conn.prepareStatement(sqlText);
                stmt.setInt(1,        getPersonId());
                stmt.setString(2,     getEmail());
                stmt.setString(3,     getEncryptedPassword());
                stmt.setString(4,     getPasswordSalt());
                stmt.setString(5,     getFirstName());
                stmt.setString(6,     getLastName());
                stmt.setString(7,     getPhone());
                if (getMobilePhone().equals("")) stmt.setNull(8, java.sql.Types.VARCHAR); else stmt.setString(8, getMobilePhone());
                stmt.setTimestamp(9 , getSignupTimestamp());
                stmt.setBoolean(10,   getAdmin());
                stmt.setString(11,    getConfirmationKey());
                stmt.setBoolean(12,   getConfirmed());
                stmt.setString(13,    getResetPasswordKey());
                stmt.setTimestamp(14, getResetPasswordTimestamp());
                stmt.setString(15,    getUsername());
                stmt.setString(16,    getFacebookId());

                if (stmt.executeUpdate() == 1) {
                    retVal = true;
                }
                else {
                    Log.writeLog("ERROR: Person.java, dbInsert(), sqlText = " + sqlText);
                }
            }
            catch (Exception e) {
                Log.writeLog("ERROR: Person.java, dbInsert(), sqlText = " + sqlText + ", " + e.toString());
            }
            finally {
                try { stmt.close(); } catch (Exception e) { }
                DBPool.getInstance().returnConnection(conn);
            }
        }

        return retVal;
    }

    public boolean dbUpdate() {
        boolean retVal = false;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;

        if (getPersonId() > 0) {
            sqlText = "UPDATE person SET (email, encrypted_password, password_salt, first_name, last_name, phone, mobile_phone, signup_timestamp, admin, confirmation_key, confirmed, reset_password_key, reset_password_timestamp, username, facebook_id) = (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) WHERE person_id = ?";
            try {
                conn = DBPool.getInstance().getConnection();
                stmt = conn.prepareStatement(sqlText);
                stmt.setString(1,     getEmail());
                stmt.setString(2,     getEncryptedPassword());
                stmt.setString(3,     getPasswordSalt());
                stmt.setString(4,     getFirstName());
                stmt.setString(5,     getLastName());
                stmt.setString(6,     getPhone());
                if (getMobilePhone().equals(""))
                	stmt.setNull(7, java.sql.Types.VARCHAR);
                else
                	stmt.setString(7, getMobilePhone());
                stmt.setTimestamp(8,  getSignupTimestamp());
                stmt.setBoolean(9,    getAdmin());
                stmt.setString(10,    getConfirmationKey());
                stmt.setBoolean(11,   getConfirmed());
                stmt.setString(12,    getResetPasswordKey());
                stmt.setTimestamp(13, getResetPasswordTimestamp());
                
                //if (getUsername() == null)
                //	stmt.setNull(14, java.sql.Types.VARCHAR);
                //else
                stmt.setString(14,    getUsername());
                stmt.setString(15,    getFacebookId());
                
                stmt.setInt(16,       getPersonId());
                
                if (stmt.executeUpdate() == 1) {
                    retVal = true;
                }
                else {
                    Log.writeLog("ERROR: Person.java, dbUpdate(), sqlText = " + sqlText);
                }
            }
            catch (Exception e) {
                Log.writeLog("ERROR: Person.java, dbUpdate(), sqlText = " + sqlText + ", " + e.toString());
            }
            finally {
                try { stmt.close(); } catch (Exception e) { }
                DBPool.getInstance().returnConnection(conn);
            }
        }

        return retVal;
    }

    public boolean dbDelete() {
        boolean retVal = false;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;

        if (getPersonId() > 0) {
            sqlText = "DELETE FROM person WHERE person_id = ?";
            try {
                conn = DBPool.getInstance().getConnection();
                stmt = conn.prepareStatement(sqlText);
                stmt.setInt(1, getPersonId());
                if (stmt.executeUpdate() == 1) {
                    clear();
                    retVal = true;
                }
                else {
                    Log.writeLog("ERROR: Person.java, dbDelete(), sqlText = " + sqlText);
                }
            }
            catch (Exception e) {
                Log.writeLog("ERROR: Person.java, dbDelete(), sqlText = " + sqlText + ", " + e.toString());
            }
            finally {
                try { stmt.close(); } catch (Exception e) { }
                DBPool.getInstance().returnConnection(conn);
            }
        }

        return retVal;
    }

    public boolean equals(Object o) {
        boolean retVal = false;
        Person person = (Person)o;

        if (person.getPersonId() == this.getPersonId() && this.getPersonId() != 0) {
            retVal = true;
        }

        return retVal; 
    }

    public int getPersonId() {
        return this.personId;
    }

    public boolean dbSetPersonId() {
        boolean retVal = false;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        sqlText = "SELECT nextval('person_person_id_seq')";
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            rs = stmt.executeQuery();
            if (rs != null && rs.next()) {
                setPersonId(rs.getInt(1));
                retVal = true;
            }
            else { 
                Log.writeLog("ERROR: Person.java, dbSetPersonId(), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Person.java, dbSetPersonId(), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return retVal;
    }

    public void setPersonId(int personId) {
        this.personId = personId;
    }

    public String getEmail() {
        return this.email;
    }

    public void setEmail(String email) {
        this.email = email; if (this.email == null) this.email = "";
    }

    public String getEncryptedPassword() {
        return this.encryptedPassword;
    }

    public void setEncryptedPassword(String encryptedPassword) {
        this.encryptedPassword = encryptedPassword; if (this.encryptedPassword == null) this.encryptedPassword = "";
    }

    public String getPasswordSalt() {
        return this.passwordSalt;
    }

    public void setPasswordSalt(String passwordSalt) {
        this.passwordSalt = passwordSalt; if (this.passwordSalt == null) this.passwordSalt = "";
    }

    public String getFirstName() {
        return this.firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName; if (this.firstName == null) this.firstName = "";
    }
    
    /*
     * will return null if not set
     */
    public String getUsername() {
        return this.username;
    }

    public void setUsername(String username) {
    	if (username != null) {
    		this.username = username.replaceAll("\\s", "");
    		if (this.username.equals("")) {
    			this.username = null;
    		}
    		if (! Person.isUsernameAllowed(username)) {
    			throw new RuntimeException("username is not allowed!");
    		}
    	}
    		
        this.username = username;
    }

    public String getFacebookId() {
        return this.facebookId;
    }

    public void setFacebookId(String facebookId) {
        if (facebookId != null) {
          this.facebookId = facebookId.replaceAll("\\s", "");
          if ("".equals(this.facebookId)) {
            this.facebookId = null;
          }
        }
    }
    
    static boolean isUsernameAllowed(String username) {
    	if (username != null && username.toUpperCase().replace("\\s","").matches("ADMIN|PHPBB")) return false;
    	return true;
    }

    public String getLastName() {
        return this.lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName; if (this.lastName == null) this.lastName = "";
    }

    public String getPhone() {
        return this.phone;
    }

    public void setPhone(String phone) {
        this.phone = phone; if (this.phone == null) this.phone = "";
    }

    public String getMobilePhone() {
        return this.mobilePhone;
    }

    public void setMobilePhone(String mobilePhone) {
        this.mobilePhone = mobilePhone; if (this.mobilePhone == null) this.mobilePhone = "";
    }

    public java.sql.Timestamp getSignupTimestamp() {
        return this.signupTimestamp;
    }

    public void setSignupTimestamp(java.sql.Timestamp signupTimestamp) {
        this.signupTimestamp = signupTimestamp;
    }

    public boolean getAdmin() {
        return this.admin;
    }

    public void setAdmin(boolean admin) {
        this.admin = admin;
    }

    public String getConfirmationKey() {
        return this.confirmationKey;
    }

    public void setConfirmationKey(String confirmationKey) {
        this.confirmationKey = confirmationKey; if (this.confirmationKey == null) this.confirmationKey = "";
    }

    public boolean getConfirmed() {
        return this.confirmed;
    }

    public void setConfirmed(boolean confirmed) {
        this.confirmed = confirmed;
    }

    public String getResetPasswordKey() {
        return this.resetPasswordKey;
    }

    public void setResetPasswordKey(String resetPasswordKey) {
        this.resetPasswordKey = resetPasswordKey;
    }

    public java.sql.Timestamp getResetPasswordTimestamp() {
        return this.resetPasswordTimestamp;
    }

    public void setResetPasswordTimestamp(java.sql.Timestamp resetPasswordTimestamp) {
        this.resetPasswordTimestamp = resetPasswordTimestamp;
    }

    public int getLoginState() {
        return this.loginState;
    }

    public void setLoginState(int loginState) {
        this.loginState = loginState;
    }

    public boolean isLoggedIn() {
        boolean retVal = false;

        if (getLoginState() == Person.EXPLICIT_LOGIN) {
            retVal = true;
        }

        return retVal;
    }

    public HttpSession getSession() {
        return this.session;
    }

    public void setSession(HttpSession session) {
        this.session = session;
    }

    public static boolean dbIsValidPersonId(int personId) {
        boolean retVal = false;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        sqlText = "SELECT COUNT(*) AS count FROM person WHERE person_id = ?";
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, personId);
            rs = stmt.executeQuery();
            if (rs != null && rs.next() && rs.getInt("count") == 1) {
                retVal = true;
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Person.java, dbIsValidPersonId(int personId), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return retVal;
    }

    public static boolean dbIsValidEmail(String email) {
        boolean retVal = false;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        sqlText = "SELECT COUNT(*) AS count FROM person WHERE UPPER(email) = UPPER(?)"; 
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setString(1, email);
            rs = stmt.executeQuery();
            if (rs != null && rs.next() && rs.getInt("count") == 1) {
                retVal = true;
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Person.java, dbIsValidEmail(String email), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (SQLException e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return retVal;
    }

    public static boolean dbIsValidMobilePhone(String mobilePhone) {
        boolean retVal = false;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        sqlText = "SELECT COUNT(*) AS count FROM person WHERE regexp_replace(mobile_phone, '[^0-9]' ,'', 'g') = ?";
        
        try {
            mobilePhone = mobilePhone.replaceAll("\\D", "");
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setString(1, mobilePhone);
            rs = stmt.executeQuery();
            if (rs != null && rs.next() && rs.getInt("count") == 1) {
                retVal = true;
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Person.java, dbIsValidMobilePhone(String mobilePhone), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (SQLException e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return retVal;
    }

    public static int dbGetPersonIdFromEmail(String email) {
        int retVal = 0;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        sqlText = "SELECT person_id FROM person WHERE UPPER(email) = UPPER(?) AND confirmed = true";
        try { 
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setString(1, email);
            rs = stmt.executeQuery();
            if ((rs != null) && (rs.next())) {
                retVal = rs.getInt("person_id");
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Person.java, dbGetPersonIdFromEmail(String email), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (SQLException e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return retVal;
    }

    public static int dbGetPersonIdFromMobilePhone(String mobilePhone) {
        int retVal = 0;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        sqlText = "SELECT person_id FROM person WHERE regexp_replace(mobile_phone, '[^0-9]' ,'', 'g') = ? AND confirmed = true";
        try { 
            mobilePhone = mobilePhone.replaceAll("\\D", "");
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setString(1, mobilePhone);
            rs = stmt.executeQuery();
            if ((rs != null) && (rs.next())) {
                retVal = rs.getInt("person_id");
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Person.java, dbGetPersonIdFromMobilePhone(String mobilePhone), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (SQLException e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return retVal;
    }

    public static int dbGetPersonIdFromResetPasswordKey(String resetPasswordKey) {
        int retVal = 0;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        sqlText = "SELECT person_id FROM person WHERE reset_password_key = ? AND confirmed = true";
        try { 
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setString(1, resetPasswordKey);
            rs = stmt.executeQuery();
            if ((rs != null) && (rs.next())) {
                retVal = rs.getInt("person_id");
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Person.java, dbGetPersonIdFromResetPasswordKey(String resetPasswordKey), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (SQLException e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return retVal;
    }

    public static Vector<Person> dbGetPersonRecords() {
        Vector<Person> personRecords = new Vector<Person>();
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        sqlText = "SELECT person_id FROM person ORDER BY last_name";
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            rs = stmt.executeQuery();
            if (rs != null) {
                while (rs.next()) {
                    personRecords.add(new Person(rs.getInt("person_id")));
                }
            }
            else {
                Log.writeLog("ERROR: Person.java, dbGetPersonRecords(), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Person.java, dbGetPersonRecords(), sqlText = " + sqlText);
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return personRecords;
    }

    public Vector<Post> dbGetFavoritePostRecords() {
        return dbGetFavoritePostRecords("name");
    }

    public Vector<Post> dbGetFavoritePostRecords(String orderBy) {
        Vector<Post> favoritePostRecords = new Vector<Post>();
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        sqlText = "SELECT post.post_id FROM post, favorite_post WHERE post.post_id = favorite_post.post_id AND favorite_post.person_id = ? ORDER BY " + orderBy;
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, getPersonId());
            rs = stmt.executeQuery();
            if (rs != null) {
                while (rs.next()) {
                    favoritePostRecords.add(new Post(rs.getInt("post_id")));
                }
            }
            else {
                Log.writeLog("ERROR: Person.java, dbGetFavoritePostRecords(String orderBy), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Person.java, dbGetFavoritePostRecords(String orderBy), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return favoritePostRecords;
    }

    public Vector<Post> dbGetFavoritePostRecords(java.sql.Timestamp afterTime, java.sql.Timestamp beforeTime) {
        return dbGetFavoritePostRecords(afterTime, beforeTime, "name");
    }

    public Vector<Post> dbGetFavoritePostRecords(java.sql.Timestamp afterTime, java.sql.Timestamp beforeTime, String orderBy) {
        Vector<Post> favoritePostRecords = new Vector<Post>();
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        if (afterTime != null && beforeTime != null) {
            sqlText = "SELECT post.post_id FROM post, favorite_post WHERE post.post_id = favorite_post.post_id AND favorite_post.person_id = ? AND install_date >= ? AND install_date <= ? ORDER BY " + orderBy;
        }
        else if (afterTime != null && beforeTime == null) {
            sqlText = "SELECT post.post_id FROM post, favorite_post WHERE post.post_id = favorite_post.post_id AND favorite_post.person_id = ? AND install_date >= ? ORDER BY " + orderBy;
        }
        else if (afterTime == null && beforeTime != null) {
            sqlText = "SELECT post.post_id FROM post, favorite_post WHERE post.post_id = favorite_post.post_id AND favorite_post.person_id = ? AND install_date <= ? ORDER BY " + orderBy;
        }
        else if (afterTime == null && beforeTime == null) {
            sqlText = "SELECT post.post_id FROM post, favorite_post WHERE post.post_id = favorite_post.post_id AND favorite_post.person_id = ? ORDER BY " + orderBy;
        }
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, getPersonId());
            if (afterTime != null && beforeTime != null) {
                stmt.setTimestamp(2, afterTime);
                stmt.setTimestamp(3, beforeTime);
            }
            else if (afterTime != null && beforeTime == null) {
                stmt.setTimestamp(2, afterTime);
            }
            else if (afterTime == null && beforeTime != null) {
                stmt.setTimestamp(2, beforeTime);
            }
            rs = stmt.executeQuery();
            if (rs != null) {
                while (rs.next()) {
                    favoritePostRecords.add(new Post(rs.getInt("post_id")));
                }
            }
            else {
                Log.writeLog("ERROR: Person.java, dbGetFavoritePostRecords(java.sql.Timestamp afterTime, java.sql.Timestamp beforeTime, String orderBy), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Person.java, dbGetFavoritePostRecords(java.sql.Timestamp afterTime, java.sql.Timestamp beforeTime, String orderBy), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return favoritePostRecords;
    }

    public Vector<Post> dbGetFavoritePostRecords(double lat, double lon) {
        return dbGetFavoritePostRecords(lat, lon, "name");
    }

    public Vector<Post> dbGetFavoritePostRecords(double lat, double lon, String orderBy) {
        Vector<Post> favoritePostRecords = new Vector<Post>();
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        String distance = "ST_Distance(ST_GeogFromText(ST_AsEWKT(location)), ST_GeogFromText('POINT(" + Double.toString(lon) + " " + Double.toString(lat) + ")'))";

        sqlText = "SELECT post.post_id, " + distance + " AS radius FROM post, favorite_post WHERE post.post_id = favorite_post.post_id AND favorite_post.person_id = ? ORDER BY " + orderBy;
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, getPersonId());
            rs = stmt.executeQuery();
            if (rs != null) {
                while (rs.next()) {
                    favoritePostRecords.add(new Post(rs.getInt("post_id")));
                }
            }
            else {
                Log.writeLog("ERROR: Person.java, dbGetFavoritePostRecords(double lat, double lon, String orderBy), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Person.java, dbGetFavoritePostRecords(double lat, double lon, String orderBy), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return favoritePostRecords;
    }

    public Vector<Post> dbGetFavoritePostRecords(double lat, double lon, java.sql.Timestamp afterTime, java.sql.Timestamp beforeTime) {
        return dbGetFavoritePostRecords(lat, lon, afterTime, beforeTime, "name");
    }

    public Vector<Post> dbGetFavoritePostRecords(double lat, double lon, java.sql.Timestamp afterTime, java.sql.Timestamp beforeTime, String orderBy) {
        Vector<Post> favoritePostRecords = new Vector<Post>();
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        //String distance = "ST_Distance(ST_GeogFromText(ST_AsEWKT(location)), ST_GeogFromText('POINT(" + Double.toString(lon) + " " + Double.toString(lat) + ")'))";

        if (afterTime != null && beforeTime != null) {
            sqlText = "SELECT post.post_id FROM post, favorite_post WHERE post.post_id = favorite_post.post_id AND favorite_post.person_id = ? AND install_date >= ? AND install_date <= ? ORDER BY " + orderBy;
        }
        else if (afterTime != null && beforeTime == null) {
            sqlText = "SELECT post.post_id FROM post, favorite_post WHERE post.post_id = favorite_post.post_id AND favorite_post.person_id = ? AND install_date >= ? ORDER BY " + orderBy;
        }
        else if (afterTime == null && beforeTime != null) {
            sqlText = "SELECT post.post_id FROM post, favorite_post WHERE post.post_id = favorite_post.post_id AND favorite_post.person_id = ? AND install_date <= ? ORDER BY " + orderBy;
        }
        else if (afterTime == null && beforeTime == null) {
            sqlText = "SELECT post.post_id FROM post, favorite_post WHERE post.post_id = favorite_post.post_id AND favorite_post.person_id = ? ORDER BY " + orderBy;
        }
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, getPersonId());
            if (afterTime != null && beforeTime != null) {
                stmt.setTimestamp(2, afterTime);
                stmt.setTimestamp(3, beforeTime);
            }
            else if (afterTime != null && beforeTime == null) {
                stmt.setTimestamp(2, afterTime);
            }
            else if (afterTime == null && beforeTime != null) {
                stmt.setTimestamp(2, beforeTime);
            }
            rs = stmt.executeQuery();
            if (rs != null) {
                while (rs.next()) {
                    favoritePostRecords.add(new Post(rs.getInt("post_id")));
                }
            }
            else {
                Log.writeLog("ERROR: Person.java, dbGetFavoritePostRecords(double lat, double lon, java.sql.Timestamp afterTime, java.sql.Timestamp beforeTime, String orderBy), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Person.java, dbGetFavoritePostRecords(double lat, double lon, java.sql.Timestamp afterTime, java.sql.Timestamp beforeTime, String orderBy), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return favoritePostRecords;
    }

    public Vector<Post> dbGetFavoritePostRecords(double lat, double lon, int radius) {
        return dbGetFavoritePostRecords(lat, lon, radius, "name");
    }

    public Vector<Post> dbGetFavoritePostRecords(double lat, double lon, int radius, String orderBy) {
        Vector<Post> favoritePostRecords = new Vector<Post>();
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        String distance = "ST_Distance(ST_GeogFromText(ST_AsEWKT(location)), ST_GeogFromText('POINT(" + Double.toString(lon) + " " + Double.toString(lat) + ")'))";

        sqlText = "SELECT post.post_id, " + distance + " AS radius FROM post, favorite_post WHERE post.post_id = favorite_post.post_id AND favorite_post.person_id = ? AND " + distance + " <= ? ORDER BY " + orderBy;
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, getPersonId());
            stmt.setInt(2, radius);
            rs = stmt.executeQuery();
            if (rs != null) {
                while (rs.next()) {
                    favoritePostRecords.add(new Post(rs.getInt("post_id")));
                }
            }
            else {
                Log.writeLog("ERROR: Person.java, dbGetFavoritePostRecords(double lat, double lon, int radius, String orderBy), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Person.java, dbGetFavoritePostRecords(double lat, double lon, int radius, String orderBy), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return favoritePostRecords;
    }

    public Vector<Post> dbGetFavoritePostRecords(double lat, double lon, int radius, java.sql.Timestamp afterTime, java.sql.Timestamp beforeTime) {
        return dbGetFavoritePostRecords(lat, lon, radius, afterTime, beforeTime, "name");
    }

    public Vector<Post> dbGetFavoritePostRecords(double lat, double lon, int radius, java.sql.Timestamp afterTime, java.sql.Timestamp beforeTime, String orderBy) {
        Vector<Post> favoritePostRecords = new Vector<Post>();
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        String distance = "ST_Distance(ST_GeogFromText(ST_AsEWKT(location)), ST_GeogFromText('POINT(" + Double.toString(lon) + " " + Double.toString(lat) + ")'))";

        if (afterTime != null && beforeTime != null) {
            sqlText = "SELECT post.post_id FROM post, favorite_post WHERE post.post_id = favorite_post.post_id AND favorite_post.person_id = ? AND " + distance + " <= ? AND install_date >= ? AND install_date <= ? ORDER BY " + orderBy;
        }
        else if (afterTime != null && beforeTime == null) {
            sqlText = "SELECT post.post_id FROM post, favorite_post WHERE post.post_id = favorite_post.post_id AND favorite_post.person_id = ? AND " + distance + " <= ? AND install_date >= ? ORDER BY " + orderBy;
        }
        else if (afterTime == null && beforeTime != null) {
            sqlText = "SELECT post.post_id FROM post, favorite_post WHERE post.post_id = favorite_post.post_id AND favorite_post.person_id = ? AND " + distance + " <= ? AND install_date <= ? ORDER BY " + orderBy;
        }
        else if (afterTime == null && beforeTime == null) {
            sqlText = "SELECT post.post_id FROM post, favorite_post WHERE post.post_id = favorite_post.post_id AND favorite_post.person_id = ? AND " + distance + " <= ? ORDER BY " + orderBy;
        }
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, getPersonId());
            stmt.setInt(2, radius);
            if (afterTime != null && beforeTime != null) {
                stmt.setTimestamp(3, afterTime);
                stmt.setTimestamp(4, beforeTime);
            }
            else if (afterTime != null && beforeTime == null) {
                stmt.setTimestamp(3, afterTime);
            }
            else if (afterTime == null && beforeTime != null) {
                stmt.setTimestamp(3, beforeTime);
            }
            rs = stmt.executeQuery();
            if (rs != null) {
                while (rs.next()) {
                    favoritePostRecords.add(new Post(rs.getInt("post_id")));
                }
            }
            else {
                Log.writeLog("ERROR: Person.java, dbGetFavoritePostRecords(double lat, double lon, int radius, java.sql.Timestamp afterTime, java.sql.Timestamp beforeTime, String orderBy), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Person.java, dbGetFavoritePostRecords(double lat, double lon, int radius, java.sql.Timestamp afterTime, java.sql.Timestamp beforeTime, String orderBy), sqlText = " + sqlText + ", " + e.toString());
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return favoritePostRecords;
    }

    public boolean isFavoritePost(int postId) {
        boolean retVal = false;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        sqlText = "SELECT COUNT(*) AS count FROM favorite_post WHERE person_id = ? AND post_id = ?";
        try {
            conn = DBPool.getInstance().getConnection();
            stmt = conn.prepareStatement(sqlText);
            stmt.setInt(1, getPersonId());
            stmt.setInt(2, postId);
            rs = stmt.executeQuery();
            if (rs != null && rs.next()) {
                if (rs.getInt("count") > 0) {
                    retVal = true;
                }
            }
            else {
                Log.writeLog("ERROR: Person.java, isFavoritePost(), sqlText = " + sqlText);
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Person.java, isFavoritePost(), sqlText = " + sqlText);
        }
        finally {
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }

        return retVal;
    }

    public static String dbGetConfirmationKey(int personId) {
        String retVal = null;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        if (dbIsValidPersonId(personId)) {
            sqlText = "SELECT confirmation_key FROM person WHERE person_id = ?";
            try {
                conn = DBPool.getInstance().getConnection();
                stmt = conn.prepareStatement(sqlText);
                stmt.setInt(1, personId);
                rs = stmt.executeQuery();
                if (rs != null && rs.next()) {
                    retVal = rs.getString("confirmation_key");
                }
                else {
                    Log.writeLog("ERROR: Person.java, dbGetConfirmationKey(int personId), sqlText = " + sqlText);
                }
            }
            catch (Exception e) {
                Log.writeLog("ERROR: Person.java, dbGetConfirmationKey(int personId), sqlText = " + sqlText);
            }
            finally { 
                try { stmt.close(); } catch (Exception e) { }
                DBPool.getInstance().returnConnection(conn);
            }
        }

        return retVal;
    }

    public static boolean dbSetConfirmed(int personId) {
        boolean retVal = false;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;

        if (dbIsValidPersonId(personId)) {
            sqlText = "UPDATE person SET (confirmed) = ('t') WHERE person_id = ?";
            try {
                conn = DBPool.getInstance().getConnection();
                stmt = conn.prepareStatement(sqlText);
                stmt.setInt(1, personId);
                if (stmt.executeUpdate() == 1) {
                    retVal = true;
                }
                else {
                    Log.writeLog("ERROR: Person.java, dbSetConfirmed(int personId), sqlText = " + sqlText);
                }
            }
            catch (Exception e) {
                Log.writeLog("ERROR: Person.java, dbSetConfirmed(int personId), sqlText = " + sqlText);
            }
            finally {
                try { stmt.close(); } catch (Exception e) { }
                DBPool.getInstance().returnConnection(conn);
            }
        }

        return retVal;
    }

    public boolean dbSetAdmin(boolean b) {
    	boolean retVal = false;
        String sqlText = "";
        Connection conn = null;
        PreparedStatement stmt = null;

        if (dbIsValidPersonId(personId)) {
            sqlText = "UPDATE person SET (admin) = (?) WHERE person_id = ?";
            try {
                conn = DBPool.getInstance().getConnection();
                stmt = conn.prepareStatement(sqlText);
                stmt.setBoolean(1, b);
                stmt.setInt(2, personId);
                if (stmt.executeUpdate() == 1) {
                    retVal = true;
                }
                else {
                    Log.writeLog("ERROR: Person.java, dbSetConfirmed(int personId), sqlText = " + sqlText);
                }
            }
            catch (Exception e) {
                Log.writeLog("ERROR: Person.java, dbSetConfirmed(int personId), sqlText = " + sqlText);
            }
            finally {
                try { stmt.close(); } catch (Exception e) { }
                DBPool.getInstance().returnConnection(conn);
            }
        }
        return retVal;
    }
    
    public static boolean isUsernameTaken(String username) {
    	
    	if (! Person.isUsernameAllowed(username)) {
    		return true;
    	}
    	
    	String sql = "SELECT 1 FROM person WHERE UPPER(username) LIKE UPPER(?) LIMIT 1";
    	
    	boolean rv = true;
    	Connection conn = null;
    	PreparedStatement stmt = null;
    	try {
    		conn = DBPool.getInstance().getConnection();
    		stmt = conn.prepareStatement(sql);
    		stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            if (rs != null && rs.next()) {
            	rv = true;
            } else {
            	rv = false;
            }
        }
        catch (Exception e) {
            Log.writeLog("ERROR: Person.java, isUsernameTaken(String username), sqlText = " + sql);
        }
        finally { 
            try { stmt.close(); } catch (Exception e) { }
            DBPool.getInstance().returnConnection(conn);
        }
    	return rv;
    }
}
