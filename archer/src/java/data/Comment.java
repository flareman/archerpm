package data;

import java.sql.Timestamp;
import java.util.Date;

public class Comment {
    private Integer id;
    private String content;
    private String username;
    private String fullname;
    private Date timestamp;
    private Integer task;
    
    public Comment(Integer ID, String cnt, String user, String full, Timestamp stamp, Integer taskID) {
        this.timestamp = stamp;
        this.content = cnt;
        this.username = user;
        this.fullname = full;
        this.task = taskID;
        this.id = ID;
    }
    
    public Integer getID() { return this.id; }
    public Integer getTaskID() { return this.task; }
    public String getContent() { return this.content; }
    public String getUsername() { return this.username; }
    public String getFullname() { return this.fullname; }
    public Date getTimestamp() { return this.timestamp; }
}
