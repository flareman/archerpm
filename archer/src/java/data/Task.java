package data;

import java.util.Date;

public class Task {
    private Integer id;
    private String title;
    private String description;
    private Integer priority;
    private Date startDate;
    private Date endDate;
    private Integer duration;
    private Boolean completed;
    
    public Task(Integer ID, String tl, String desc, Integer prt, Date sDate, Date eDate, Integer dur, Boolean cmpl) {
        this.title = tl;
        this.description = desc;
        this.priority = prt;
        this.startDate = sDate;
        this.endDate = eDate;
        this.duration = dur;
        this.id = ID;
        this.completed = cmpl;
    }
    
    public Integer getID() { return this.id; }
    public String getTitle() { return this.title; }
    public String getDesc() { return this.description; }
    public Integer getPriority() { return this.priority; }
    public Date getStartDate() { return this.startDate; }
    public Date getEndDate() { return this.endDate; }
    public Integer getDuration() { return this.duration; }
    public Date getApproxEndDate() { return new Date(this.startDate.getTime()+(24*60*60*this.duration)); }
    public Boolean isCompleted() { return this.completed; }
}
