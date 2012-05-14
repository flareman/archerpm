/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package data;

/**
 *
 * @author george
 */
public class User {
    private String username;
    private String name;
    private String surname;
    private String email;
    private Integer statusID;
    
    public User(String uname,String nm,String snm,String mail,Integer stid){
        username = uname;
        name = nm;
        surname = snm;
        email = mail;
        statusID = stid;
    }
    
    public String getUsername(){
        return this.username;
    }
    
    public String getName(){
        return this.name;
    }
    
    public String getSurname(){
        return this.surname;
    }
    
    public String getEmail(){
        return this.email;
    }
    
    public Integer getStatusID(){
        return this.statusID;
    }
}
