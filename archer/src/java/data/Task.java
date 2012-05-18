package data;

import java.util.Date;

public class Task {
    public enum Priority {
        LOW, MEDIUM, HIGH, URGENT, CRITICAL, UNDEFINED
    }
    private Integer id;
    private String title;
    private String description;
    private Priority priority;
    private Date startDate;
    private Date endDate;
    private Integer duration;
    private Boolean completed;
    
    public Task(Integer ID, String tl, String desc, String prt, Date sDate, Date eDate, Integer dur, Boolean cmpl) {
        this.title = tl;
        this.description = desc;
        if ("Low".equals(prt)) this.priority = Priority.LOW;
        else if ("Medium".equals(prt)) this.priority = Priority.MEDIUM;
        else if ("High".equals(prt)) this.priority = Priority.HIGH;
        else if ("Urgent".equals(prt)) this.priority = Priority.URGENT;
        else if ("Critical".equals(prt)) this.priority = Priority.CRITICAL;
        else this.priority = Priority.UNDEFINED;
        this.startDate = sDate;
        this.endDate = eDate;
        this.duration = dur;
        this.id = ID;
        this.completed = cmpl;
    }
    
    public Integer getID() { return this.id; }
    public String getTitle() { return this.title; }
    public String getDesc() { return this.description; }
    public Priority getPriority() { return this.priority; }
    public Date getStartDate() { return this.startDate; }
    public Date getEndDate() { return this.endDate; }
    public Integer getDuration() { return this.duration; }
    public Date getApproxEndDate() { return new Date(this.startDate.getTime()+(24*60*60*this.duration)); }
    public Boolean isCompleted() { return this.completed; }
}
