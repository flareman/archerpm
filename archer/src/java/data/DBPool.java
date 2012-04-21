package data;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;
import org.apache.tomcat.dbcp.pool.impl.GenericObjectPool;
import org.apache.tomcat.dbcp.dbcp.PoolingDataSource;
import org.apache.tomcat.dbcp.dbcp.ConnectionFactory;
import org.apache.tomcat.dbcp.dbcp.DriverManagerConnectionFactory;
import org.apache.tomcat.dbcp.dbcp.PoolableConnectionFactory;

public class DBPool {
    private DataSource pool = null;
    
    public DBPool(String address, String userID, String password) {
        try {
            Class.forName("com.mysql.jdbc.Driver");
            this.pool = DBPool.setupPool(address, userID, password);
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    private static DataSource setupPool(String address, String userID, String password) {
        GenericObjectPool connectionPool = new GenericObjectPool(null);
        ConnectionFactory connectionFactory =
                new DriverManagerConnectionFactory(address, userID, password);
        PoolableConnectionFactory poolableConnectionFactory =
                new PoolableConnectionFactory(connectionFactory,connectionPool,null,null,false,true);
        PoolingDataSource dataSource = new PoolingDataSource(connectionPool);
        return dataSource;
    }

    public Connection getConnection() throws SQLException {
        return this.pool.getConnection();
    }
}
