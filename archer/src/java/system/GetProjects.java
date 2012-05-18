package system;

import com.google.gson.Gson;
import data.DBManager;
import data.Project;
import data.User;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class GetProjects extends HttpServlet {
    private DBManager manager;
    
    @Override // THANK YOU CAPTAIN OBLIVIOUS
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
                    boolean validRequest = true;
                    ArrayList<Project> projects = new ArrayList<Project>();
                    String kind = request.getParameter("kind");
                    if (kind.equals("all")) {
                        query = "SELECT projectID, title, description, manager, isPublic, beginsAt, totalDuration FROM Projects";
                        if (user.getStatus() != User.Status.ADMINISTRATOR) {
                            query += " WHERE isPublic = 1";
                            query += " OR projectID IN (SELECT projectID FROM ProjectHasUsers WHERE ProjectHasUsers.username = ?)";
                            query += " OR manager = ?";
                        }
                        query += " ORDER BY beginsAt ASC";
                        stmt = conn.prepareStatement(query);
                        if (user.getStatus() != User.Status.ADMINISTRATOR) {
                            String userID = user.getUsername();
                            stmt.setString(1, userID);
                            stmt.setString(2, userID);
                        }
                    } else if (kind.equals("user")) {
                        String userID = request.getParameter("user");
                        String requesterID = user.getUsername();
                        query = "SELECT projectID, title, description, manager, isPublic, beginsAt, totalDuration FROM Projects WHERE projectID IN (SELECT projectID FROM ProjectHasUsers.username = ?";
                        if (user.getStatus() != User.Status.ADMINISTRATOR) {
                            query += " AND (isPublic = 1";
                            query += " OR projectID IN (SELECT projectID FROM ProjectHasUsers WHERE ProjectHasUsers.username = ?)";
                            query += " OR manager = ?)";
                        }
                        query += " ORDER BY beginsAt ASC";
                        stmt = conn.prepareStatement(query);
                        stmt.setString(1, userID);
                        if (user.getStatus() != User.Status.ADMINISTRATOR) {
                            stmt.setString(2, requesterID);
                            stmt.setString(3, requesterID);
                        }
                    } else {
                        validRequest = false;
                        out.println("{\"error\":\"Wrong argument\"}");
                    }
                    if (validRequest) {
                        ResultSet results = stmt.executeQuery();
                        while (results.next())
                            projects.add(new Project(results.getInt("projectID"), results.getString("title"), results.getString("description"),
                                    results.getString("manager"), results.getDate("beginsAt"), results.getInt("totalDuration")));
                        if (projects.isEmpty()) out.println("{}");
                        else {
                            Gson gson = new Gson();
                            String output = gson.toJson(projects, projects.getClass());
                            out.println(output);
                        }
                    }
                } else {
                    out.println("{\"error\":\"Requesting user not logged in\"}");
                }
            }
            catch(SQLException SQLe) {
                log("SQL error when logging in", SQLe);
            } finally {
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
