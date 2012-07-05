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

public class DeleteEntity extends HttpServlet {
    private DBManager manager;
    
    @Override // THANK YOU CAPTAIN TROOPEROUS
    public void init() throws ServletException {this.manager = DBManager.getManager();}

    /**
     * Processes requests for both HTTP
     * <code>GET</code> and
     * <code>POST</code> methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
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
                            out.println("{\"error\":\"Non-administrator users cannot delete projects\"}");
                        }
                        else{
                            String title = request.getParameter("title");
                            query = "DELETE FROM TaskHasUsers as th USING (SELECT Tasks.taskID FROM Tasks,(SELECT projectID FROM Projects WHERE title = ?) as p WHERE Tasks.projectID = p.projectID) as pp WHERE th.taskID = pp.taskID";
                            stmt = conn.prepareStatement(query);
                            stmt.setString(1, title);
                            stmt.executeUpdate();
                            stmt.close();
                            query = "DELETE FROM Tasks as t USING (SELECT Tasks.taskID FROM Tasks,(SELECT projectID FROM Projects WHERE title = ?) as p WHERE Tasks.projectID = p.projectID) as pp WHERE t.taskID = pp.taskID";
                            stmt = conn.prepareStatement(query);
                            stmt.setString(1, title);
                            stmt.executeUpdate();
                            stmt.close();
                            query = "DELETE FROM ProjectHasUsers as ph USING (SELECT projectID FROM Projects WHERE title = ?) as p WHERE ph.projectID = p.projectID";
                            stmt = conn.prepareStatement(query);
                            stmt.setString(1, title);
                            stmt.executeUpdate();
                            stmt.close();
                            query = "DELETE FROM Comments as c USING (SELECT Tasks.taskID FROM Tasks,(SELECT projectID FROM Projects WHERE title = ?) as p WHERE Tasks.projectID = p.projectID) as pp WHERE c.taskID = pp.taskID";
                            stmt = conn.prepareStatement(query);
                            stmt.setString(1, title);
                            stmt.executeUpdate();
                            stmt.close();
                            query = "DELETE FROM Projects WHERE title = ?";
                            stmt = conn.prepareStatement(query);
                            stmt.setString(1, title);
                        }
                    } else if (kind.equals("task")) {
                        String title = request.getParameter("title");
                    } 
                    else if(kind.equals("comment")){
                        
                    }                    
                    else {
                        out.println("{\"error\":\"Wrong argument\"}");
                    }
                    int affected = stmt.executeUpdate();
                    if(affected == 0){
                        out.println("{\"error\":\"Deletion failed, you do not have enough privileges to delete a "+kind+"\"}");
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
                        out.println("{\"error\":\"Unknown SQL error occured, please try again.\"}");
                }
                else
                    log("SQL error at CreateEntity", SQLe);
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
