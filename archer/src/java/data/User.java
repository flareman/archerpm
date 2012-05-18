package data;

public class User {
    public enum Status { ADMINISTRATOR, PROJECT_MANAGER, EMPLOYEE, VISITOR, UNDEFINED }

    private String username;
    private String name;
    private String surname;
    private String email;
    private Status status;
    
    public User(String uname, String nm, String snm, String mail, String statusDesc) {
        this.username = uname;
        this.name = nm;
        this.surname = snm;
        this.email = mail;
        if ("Site Administrator".equals(statusDesc))
            this.status = Status.ADMINISTRATOR;
        else if ("Project Manager".equals(statusDesc))
            this.status = Status.PROJECT_MANAGER;
        else if ("Employee".equals(statusDesc))
            this.status = Status.EMPLOYEE;
        else if ("Visitor".equals(statusDesc))
            this.status = Status.VISITOR;
        else this.status = Status.UNDEFINED;
    }
    
    public String getUsername() { return this.username; }
    public String getName() { return this.name; }
    public String getSurname() { return this.surname; }
    public String getEmail() { return this.email; }
    public Status getStatus() { return this.status; }
}
