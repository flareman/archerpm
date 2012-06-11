package system;

import com.google.gson.Gson;
import data.DBManager;
import data.Task;
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

public class GetTasks extends HttpServlet {
    private DBManager manager;
    
    @Override // THANK YOU CAPTAIN PREPOSTEROUS
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
                    ArrayList<Task> tasks = new ArrayList<Task>();
                    String kind = request.getParameter("kind");
                    if (kind.equals("all")) {
                        query = "SELECT DISTINCT Tasks.taskID, Tasks.title, Tasks.description, Priorities.description AS priority, Tasks.projectID, Tasks.completed, Tasks.duration, Tasks.beginsAt, Tasks.endedAt FROM Tasks, Priorities, TaskHasUsers WHERE Priorities.priorityID = Tasks.priority";
                        query += " AND Tasks.taskID = TaskHasUsers.taskID AND TaskHasUsers.username = ?";
                        query += " ORDER BY Tasks.beginsAt ASC";
                        stmt = conn.prepareStatement(query);
                        String requesterID = user.getUsername();
                        stmt.setString(1, requesterID);
                    } else if (kind.equals("user")) {
                        String userID = request.getParameter("user");
                        String requesterID = user.getUsername();
                        query = "SELECT DISTINCT Tasks.taskID, Tasks.title, Tasks.description, Priorities.description AS priority, Tasks.projectID, Tasks.completed, Tasks.duration, Tasks.beginsAt, Tasks.endedAt FROM Tasks, Priorities, TaskHasUsers WHERE Priorities.priorityID = Tasks.priority";
                        query += " AND Tasks.taskID IN (SELECT taskID FROM TaskHasUsers WHERE username = ?)";
                        if (user.getStatus() != User.Status.ADMINISTRATOR) {
                            query += " AND (";
                            query += "Tasks.projectID IN (SELECT projectID FROM Projects WHERE isPublic = 1)";
                            query += " OR Tasks.projectID IN (SELECT Projects.projectID FROM Projects, ProjectHasUsers WHERE ProjectHasUsers.username = ?)";
                            query += " OR Tasks.projectID IN (SELECT projectID FROM Projects WHERE manager = ?)";
                            query += ")";
                        }
                        query += " ORDER BY Tasks.beginsAt ASC";
                        stmt = conn.prepareStatement(query);
                        stmt.setString(1, userID);
                        if (user.getStatus() != User.Status.ADMINISTRATOR) {
                            stmt.setString(2, requesterID);
                            stmt.setString(3, requesterID);
                        }
                    } else if (kind.equals("project")) {
                        String projectID = request.getParameter("project");
                        String requesterID = user.getUsername();
                        query = "SELECT DISTINCT Tasks.taskID, Tasks.title, Tasks.description, Priorities.description AS priority, Tasks.projectID, Tasks.completed, Tasks.duration, Tasks.beginsAt, Tasks.endedAt FROM Tasks, Priorities WHERE Priorities.priorityID = Tasks.priority";
                        query += " AND Tasks.projectID = ?";
                        if (user.getStatus() != User.Status.ADMINISTRATOR) {
                            query += " AND (";
                            query += "Tasks.projectID IN (SELECT projectID FROM Projects WHERE isPublic = 1)";
                            query += " OR Tasks.projectID IN (SELECT Projects.projectID FROM Projects, ProjectHasUsers WHERE ProjectHasUsers.username = ?)";
                            query += " OR Tasks.projectID IN (SELECT projectID FROM Projects WHERE manager = ?)";
                            query += ")";
                        }
                        query += " ORDER BY Tasks.beginsAt ASC";
                        stmt = conn.prepareStatement(query);
                        stmt.setString(1, projectID);
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
                            tasks.add(new Task(results.getInt("taskID"), results.getString("title"), results.getString("description"), results.getString("priority"),
                                    results.getDate("beginsAt"), results.getDate("endedAt"), results.getInt("duration"), results.getBoolean("completed")));
                        if (tasks.isEmpty()) out.println("{}");
                        else {
                            Gson gson = new Gson();
                            String output = gson.toJson(tasks, tasks.getClass());
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
