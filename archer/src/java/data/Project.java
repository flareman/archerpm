package data;

import java.util.Date;

public class Project {
    private String title;
    private String description;
    private String manager;
    private Date startDate;
    private Integer duration;
    
    public Project(String title, String desc, String mng, Date sDate, Integer dur) {
        this.title = title;
        this.description = desc;
        this.manager = mng;
        this.startDate = sDate;
        this.duration = dur;
    }

    public String getTitle() { return this.title; }
    public String getDesc() { return this.description; }
    public String getManager() { return this.manager; }
    public Date getStartDate() { return this.startDate; }
    public Integer getDuration() { return this.duration; }
    public Date getEndDate() { return new Date(this.startDate.getTime()+(24*60*60*this.duration)); }
}
