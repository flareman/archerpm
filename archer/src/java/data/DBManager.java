package data;

import java.sql.Connection;
import java.util.Properties;
import java.sql.SQLException;

public class DBManager {
    private static DBManager instance = null;
    private DBPool pool = null;
    
    public DBManager() {
        Properties properties = new Properties();
        try {
            properties.load(this.getClass().getClassLoader().getResourceAsStream("/connection.properties"));
            String address = properties.getProperty("address");
            String userID = properties.getProperty("userID");
            String password = properties.getProperty("password");
            String port = properties.getProperty("port");
            String schema = properties.getProperty("schema");
            this.pool = new DBPool("jdbc:mysql://"+address+":"+port+"/"+schema, userID, password);
        } catch (Exception e) { e.printStackTrace(); }
    }
    
    public static synchronized DBManager getManager() {
        if (instance == null) {
            instance = new DBManager();
        }
        return instance;
    }
    
    public Connection getConnection() throws SQLException {
        return this.pool.getConnection();
    }
}
