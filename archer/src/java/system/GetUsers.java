package system;

import com.google.gson.Gson;
import data.DBManager;
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

public class GetUsers extends HttpServlet {
    private DBManager manager; // We tried to login so hard; still, the fires were still falling #d3
    
    @Override // THANK YOU CAPTAIN LUDICROUS
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
                    ArrayList<User> users = new ArrayList<User>();
                    String kind = request.getParameter("kind");
                    if (kind.equals("all")) {
                        if (user.getStatus() == User.Status.ADMINISTRATOR) {
                            query = "SELECT DISTINCT username, name, surname, email, description AS status FROM Users, Status WHERE Status.statusID = Users.status ORDER BY surname ASC";
                            stmt = conn.prepareStatement(query);
                        } else {
                            out.println("{\"error\":\"Requesting user is not an administrator\"}");
                            validRequest = false;
                        }
                    } else if (kind.equals("managers")) {
                        if (user.getStatus() == User.Status.ADMINISTRATOR) {
                            query = "SELECT DISTINCT username, name, surname, email, description AS status FROM Users, Status WHERE Status.statusID = Users.status AND Status.description = 'Project Manager' ORDER BY surname ASC";
                            stmt = conn.prepareStatement(query);
                        } else {
                            out.println("{\"error\":\"Requesting user is not an administrator\"}");
                            validRequest = false;
                        }
                    } else if (kind.equals("task")) {
                        Integer task = Integer.parseInt(request.getParameter("value"));
                        query = "SELECT Projects.isPublic, Projects.projectID FROM Projects, Tasks WHERE Tasks.projectID = Projects.projectID AND Tasks.taskID = ?";
                        stmt = conn.prepareStatement(query);
                        stmt.setInt(1, task);
                        ResultSet projectIsPublicRes = stmt.executeQuery();
                        boolean isPublic = false;
                        Integer project = 0;
                        if (projectIsPublicRes.next()) {
                            isPublic = projectIsPublicRes.getBoolean("isPublic");
                            project = projectIsPublicRes.getInt("projectID");
                        } else {
                            out.println("{\"error\":\"Requested project not found; database corrupt\"}");
                            validRequest = false;
                        }
                        if (validRequest && !isPublic && user.getStatus() != User.Status.ADMINISTRATOR) {
                            query = "SELECT DISTINCT username FROM ProjectHasUsers WHERE projectID = ? AND username = ?";
                            stmt.close();
                            stmt = conn.prepareStatement(query);
                            stmt.setInt(1, project);
                            stmt.setString(2, user.getUsername());
                            ResultSet userProjectRes = stmt.executeQuery();
                            if (!userProjectRes.next()) {
                                out.println("{\"error\":\"Sorry, this task is part of a project you are not a member of\"}");
                                validRequest = false;
                            }
                        }
                        if (validRequest) {
                            query = "SELECT DISTINCT Users.username, name, surname, email, description AS status FROM Users, TaskHasUsers, Status WHERE TaskHasUsers.taskID = ? AND Users.username = TaskHasUsers.username AND Status.statusID = Users.status ORDER BY surname ASC";
                            stmt.close();
                            stmt = conn.prepareStatement(query);
                            stmt.setInt(1, task);
                        }
                    } else if (kind.equals("project")) {
                        Integer project = Integer.parseInt(request.getParameter("value"));
                        query = "SELECT isPublic FROM Projects WHERE projectID = ?";
                        stmt = conn.prepareStatement(query);
                        stmt.setInt(1, project);
                        boolean isPublic = false;
                        ResultSet projectIsPublicRes = stmt.executeQuery();
                        if (projectIsPublicRes.next())
                            isPublic = projectIsPublicRes.getBoolean("isPublic");
                        else {
                            out.println("{\"error\":\"Requested project not found; database corrupt\"}");
                            validRequest = false;
                        }
                        if (validRequest && !isPublic && user.getStatus() != User.Status.ADMINISTRATOR) {
                            query = "SELECT username FROM ProjectHasUsers WHERE projectID = ? AND username = ?";
                            stmt.close();
                            stmt = conn.prepareStatement(query);
                            stmt.setInt(1, project);
                            stmt.setString(2, user.getUsername());
                            ResultSet userProjectRes = stmt.executeQuery();
                            if (!userProjectRes.next()) {
                                out.println("{\"error\":\"Sorry, you are not a member of this project\"}");
                                validRequest = false;
                            }
                        }
                        if (validRequest) {
                            query = "SELECT DISTINCT Users.username, name, surname, email, description AS status FROM Users, ProjectHasUsers, Status WHERE ProjectHasUsers.projectID = ? AND Users.username = ProjectHasUsers.username AND Status.statusID = Users.status ORDER BY surname ASC";
                            stmt.close();
                            stmt = conn.prepareStatement(query);
                            stmt.setInt(1, project);
                        }
                    } else if (kind.equals("user")) {
                        String username = request.getParameter("value");
                        query = "SELECT DISTINCT username, name, surname, email, description AS status FROM Users, Status WHERE Users.username = ? AND Status.statusID = Users.status";
                        stmt = conn.prepareStatement(query);
                        stmt.setString(1, username);
                    } else {
                        validRequest = false;
                        out.println("{\"error\":\"Wrong argument\"}");
                    }
                    if (validRequest) {
                        ResultSet results = stmt.executeQuery();
                        if (kind.equals("user")) {
                            if (results.next()) {
                                User result = new User(results.getString("username"), results.getString("name"),
                                        results.getString("surname"), results.getString("email"), results.getString("status"));
                                out.println(new Gson().toJson(result, result.getClass()));
                            } else out.println("{\"error\":\"Requested user not found\"}");
                        } else {
                            while (results.next())
                                users.add(new User(results.getString("username"), results.getString("name"),
                                    results.getString("surname"), results.getString("email"), results.getString("status")));
                            if (users.isEmpty()) out.println("{}");
                            else {
                                Gson gson = new Gson();
                                String output = gson.toJson(users, users.getClass());
                                out.println(output);
                            }
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
