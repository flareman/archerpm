package system;

import data.DBManager;
import data.User;
import java.text.SimpleDateFormat;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Date;
import java.text.ParseException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class CreateEntity extends HttpServlet {
    private DBManager manager;
    
    @Override // THANK YOU CAPTAIN TROOPEROUS
    public void init() throws ServletException {this.manager = DBManager.getManager();}

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        try {
            Connection conn = null;
            PreparedStatement stmt = null;
            String query = "";
            try {
                User user = (User)request.getSession().getAttribute("user");
                if (user != null) {
                    conn = this.manager.getConnection();
                    String kind = request.getParameter("kind");
                    if (kind.equals("project")) {
                        if (user.getStatus() != User.Status.ADMINISTRATOR){
                            out.println("{\"error\":\"Non-administrator users cannot create new projects\"}");
                        }
                        else{
                            query = "INSERT INTO Projects (title,description,manager,isPublic,beginsAt,totalDuration) ";
                            query += "VALUES(?,?,?,?,?,?)";
                            stmt = conn.prepareStatement(query);
                            stmt.setString(1, request.getParameter("title"));
                            stmt.setString(2, request.getParameter("description"));
                            stmt.setString(3, request.getParameter("manager"));
                            stmt.setBoolean(4, Boolean.parseBoolean(request.getParameter("isPublic")));
                            SimpleDateFormat format = new SimpleDateFormat("dd-MM-yyyy");
                            stmt.setDate(5, new Date(format.parse(request.getParameter("beginsAt")).getTime()));
                            stmt.setInt(6, Integer.parseInt(request.getParameter("totalDuration")));
                        }
                    } else if (kind.equals("task")) {
                        if ((user.getStatus() != User.Status.ADMINISTRATOR) && (user.getStatus() != User.Status.PROJECT_MANAGER)){
                            out.println("{\"error\":\"Non-Project Manager users cannot create new tasks within a project\"}");
                        }
                        else{
                            String username = user.getUsername();
                            Integer parentProject = Integer.parseInt(request.getParameter("project"));
                            query = "INSERT INTO Tasks (projectID,title,description,priority,completed,duration, beginsAt)";
                            query += " SELECT DISTINCT ?,?,?,?,0,?, NOW() FROM Tasks";
                            if(user.getStatus() == User.Status.PROJECT_MANAGER){
                                query += " WHERE ? IN (SELECT manager FROM Projects WHERE projectID = ?) LIMIT 1";
                            }
                            stmt = conn.prepareStatement(query);
                            stmt.setInt(1,parentProject);
                            stmt.setString(2,request.getParameter("title"));
                            stmt.setString(3, request.getParameter("description"));
                            stmt.setInt(4, Integer.parseInt(request.getParameter("priority")));
                            stmt.setInt(5,Integer.parseInt(request.getParameter("duration")));
                            if(user.getStatus() == User.Status.PROJECT_MANAGER){
                                stmt.setString(6,username);
                                stmt.setInt(7,parentProject);
                            }
                        }
                    } 
                    else if(kind.equals("comment")){
                        if((user.getStatus() == User.Status.VISITOR || (user.getStatus() == User.Status.UNDEFINED) )){
                            out.println("{\"error\":\"Visitors are not allows to post any comments.\"}");
                        }
                        else{
                            String username = user.getUsername();
                            Integer parentTask = Integer.parseInt(request.getParameter("task"));
                            query = "INSERT INTO Comments (content, timestamp, username, taskID)";
                            query += " SELECT DISTINCT ?,NOW(),?,? FROM Comments";
                            if(user.getStatus() != User.Status.ADMINISTRATOR){
                                query += " WHERE ? IN (SELECT username FROM TaskHasUsers WHERE taskID = ? AND username = ?) "
                                        + "OR ? IN (SELECT Projects.manager FROM Projects, Tasks WHERE Tasks.projectID = Projects.projectID AND Tasks.taskID = ?) LIMIT 1";
                            }
                            stmt = conn.prepareStatement(query);
                            stmt.setString(1, request.getParameter("content"));
                            stmt.setString(2, username);
                            stmt.setInt(3, parentTask);
                            if(user.getStatus() != User.Status.ADMINISTRATOR){
                                stmt.setString(4,username);
                                stmt.setInt(5,parentTask);
                                stmt.setString(6,username);
                                stmt.setString(7,username);
                                stmt.setInt(8,parentTask);
                            }
                        }
                    }                    
                    else {
                        out.println("{\"error\":\"Wrong argument\"}");
                    }
                    int affected = stmt.executeUpdate();
                    if(affected == 0){
                        out.println("{\"error\":\"Creation failed, you do not have enough privileges to create a "+kind+"\"}");
                    }
                    else{
                        out.println("{}");
                    }
                } else {
                    out.println("{\"error\":\"Requesting user not logged in\"}");
                }
            }
            catch(SQLException SQLe) {
                if(SQLe.getSQLState().equals("23000")){
                    if(SQLe.getErrorCode() == 1048)
                        out.println("{\"error\":\"You must specify all project or task fields required to create a new entity.\"}");
                    else if(SQLe.getErrorCode() == 1169)
                        out.println("{\"error\":\"Project or task already exists, please provide a different project or task title and try again.\"}");
                    else
                        out.println("{\"error\":\"The creation failed; please contact your administrator.\"}");
                }
                else
                    out.println("{\"error\":\"The creation failed; please contact your administrator.\"}");
            } 
            catch(ParseException Prse){
                    log("All dates must be in the day-month-year format (i.e. 11-1-2011)", Prse);
            }
            catch (Exception e) {
                out.println("{\"error\":\"The creation failed; check that you have provided all required info. If the problem persists, please contact your administrator.\"}");
            }
            finally {
                try {
                    if (stmt != null) stmt.close();
                    if (conn != null) conn.close();
                } catch (Exception e) { e.printStackTrace(); }
            }
        } finally {            
            out.close();
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP
     * <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP
     * <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>
}
