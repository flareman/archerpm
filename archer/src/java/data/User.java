package data;

public class User {
    private String username;
    private String name;
    private String surname;
    private String email;
    private Integer statusID;
    
    public User(String uname,String nm,String snm,String mail,Integer stid) {
        this.username = uname;
        this.name = nm;
        this.surname = snm;
        this.email = mail;
        this.statusID = stid;
    }
    
    public String getUsername() { return this.username; }
    public String getName() { return this.name; }
    public String getSurname() { return this.surname; }
    public String getEmail() { return this.email; }
    public Integer getStatusID() { return this.statusID; }
}
