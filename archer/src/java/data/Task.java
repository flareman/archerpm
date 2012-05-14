/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package data;

import java.util.Date;

/**
 *
 * @author george
 */
public class Task {
    private Integer id;
    private String title;
    private String description;
    private Integer priority;
    private Date startDate;
    private Date endDate;
    private Integer duration;
    private Boolean completed;
    
    public Task(Integer ID,String tl,String desc,Integer prt,Date sDate,Date eDate,Integer dur,Boolean cmpl){
        title=tl;
        description = desc;
        priority = prt;
        startDate = sDate;
        endDate = eDate;
        duration = dur;
        id = ID;
        completed = cmpl;
    }
    
    public Integer getID(){
        return this.id;
    }
    
    public String getTitle(){
        return this.title;
    }
    
    public String getDesc(){
        return this.description;
    }
    
    public Integer getPriority(){
        return this.priority;
    }
    
    public Date getStartDate(){
        return this.startDate;
    }
    
     public Date getEndDate(){
        return this.endDate;
    }
    
    public Integer getDuration(){
        return this.duration;
    }
    
    public Boolean isCompleted(){
        return this.completed;
    }
    
}
