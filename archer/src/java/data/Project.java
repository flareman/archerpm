package data;

import java.sql.Date;

public class Project {
    private Integer id;
    private String title;
    private String description;
    private String manager;
    private Date startDate;
    private Integer duration;
    private Boolean isPublic;
    
    public Project(Integer newID, String title, String desc, String mng, Date sDate, Integer dur, Boolean publicProject) {
        this.id = newID;
        this.title = title;
        this.description = desc;
        this.manager = mng;
        this.startDate = sDate;
        this.duration = dur;
        this.isPublic = publicProject;
    }

    public Integer getID() { return this.id; }
    public String getTitle() { return this.title; }
    public String getDesc() { return this.description; }
    public String getManager() { return this.manager; }
    public Date getStartDate() { return this.startDate; }
    public Integer getDuration() { return this.duration; }
    public Date getEndDate() { return new Date(this.startDate.getTime()+(24*60*60*this.duration)); }
    public Boolean isPublic() { return this.isPublic; }
}
