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
public class Project {
    private String title;
    private String description;
    private String manager;
    private Date startDate;
    private Integer duration;
    
    public Project(String tl,String desc,String mng,Date sDate,Integer dur){
        title=tl;
        description = desc;
        manager= mng;
        startDate = sDate;
        duration = dur;
    }
    
    public String getTitle(){
        return this.title;
    }
    
    public String getDesc(){
        return this.description;
    }
    
    public String getManager(){
        return this.manager;
    }
    
    public Date getStartDate(){
        return this.startDate;
    }
    
    public Integer getDuration(){
        return this.duration;
    }
    
}
