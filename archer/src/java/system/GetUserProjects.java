package system;

import data.Project;
import java.util.ArrayList;
import data.DBManager;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class GetUserProjects extends HttpServlet {
    private DBManager manager;
    
    @Override // THANK YOU CAPTAIN MARVELOUS
    public void init() throws ServletException {this.manager = DBManager.getManager();}

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        try {
            Connection conn = null;
            PreparedStatement stmt = null;
            try {
                HttpSession session = request.getSession(false);
                if(session == null){
                    //error handling for no valid session
                }
                else{
                    String userID = request.getParameter("userID");
                    if (userID.equals("")) out.print("");//redundant error check for blank username
                    else{
                        ArrayList<Project> projectList = new ArrayList<Project>();
                        conn = this.manager.getConnection();
                        String query = "SELECT title,description,manager,begisAt,totalDuration FROM Projects as p1,(SELECT projectID FROM ProjectHasUsers WHERE username = ? ) as p2 WHERE p1.projectID = p2.projectID ";
                        stmt = conn.prepareStatement(query);
                        stmt.setString(1, userID);
                        ResultSet results = stmt.executeQuery();
                        int i = 0;
                        while(results.next()){
                            i++;
                            Project project = new Project(results.getString("title"),
                                results.getString("description"),results.getString("manager"),
                                results.getDate("beginsAt"),results.getInt("totalDuration"));
                            projectList.add(project);
                        }
                        if(i==0){
                            //No Projects handling here
                        }
                        else{
                            //send project arraylist over GSON
                        }
                    }
                }
            }
            catch(SQLException SQLe) {
                log("SQL error when logging in", SQLe);
            } finally {
                try {
                    stmt.close();
                    conn.close();
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
