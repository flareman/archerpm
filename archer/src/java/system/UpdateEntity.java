package system;

import data.DBManager;
import data.User;
import data.Project;
import data.Task;
import data.Comment;
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
import com.google.gson.*;

public class UpdateEntity extends HttpServlet {
    private DBManager manager;
    
    @Override // THANK YOU ADMIRAL ADAMA
    public void init() throws ServletException {this.manager = DBManager.getManager();}

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        try {
            Connection conn = null;
            PreparedStatement stmt = null;
            String query = "";
            Boolean validUpdate = true;
            try {
                User user = (User)request.getSession().getAttribute("user");
                if (user != null) {
                    conn = this.manager.getConnection();
                    String kind = request.getParameter("kind");
                    if (kind.equals("project")) {
                        if (user.getStatus() != User.Status.ADMINISTRATOR) {
                            out.println("{\"error\":\"Only administrators can update project details\"}");
                            validUpdate = false;
                        } else {
                            Project project = new Gson().fromJson(request.getParameter("value"), Project.class);
                            query = "UPDATE Projects SET ";
                            query += "title = ?, ";
                            query += "description = ?, ";
                            query += "manager = ?, ";
                            query += "beginsAt = ?, ";
                            query += "totalDuration = ?, ";
                            query += "isPublic = ? ";
                            query += "WHERE projectID = ?";
                            stmt = conn.prepareStatement(query);
                            stmt.setString(1, project.getTitle());
                            stmt.setString(2, project.getDesc());
                            stmt.setString(3, project.getManager());
                            stmt.setDate(4, project.getStartDate());
                            stmt.setInt(5, project.getDuration());
                            stmt.setBoolean(6, project.isPublic());
                            stmt.setInt(7, project.getID());
                        }
                    } else if (kind.equals("user")) {
                        if (user.getStatus() != User.Status.ADMINISTRATOR) {
                            User editUser = new Gson().fromJson(request.getParameter("value"), User.class);
                            query = "UPDATE Users SET ";
                            query += "name = ?, ";
                            query += "surname = ?, ";
                            query += "email = ? ";
                            query += "WHERE username = ?";
                            stmt = conn.prepareStatement(query);
                            stmt.setString(1, editUser.getName());
                            stmt.setString(2, editUser.getSurname());
                            stmt.setString(3, editUser.getEmail());
                            stmt.setString(4, user.getUsername());
                        } else {
                            User editUser = new Gson().fromJson(request.getParameter("value"), User.class);
                            String oldPassword = request.getParameter("oldpass");
                            String newPassword = request.getParameter("newpass");
                            query = "UPDATE Users SET ";
                            query += "name = ?, ";
                            query += "surname = ?, ";
                            query += "email = ?, ";
                            query += "password = ?, ";
                            query += "status = ? ";
                            query += "WHERE username = ? ";
                            query += "AND password = SHA1(CONCAT(salt,?))";
                            stmt = conn.prepareStatement(query);
                            stmt.setString(1, editUser.getName());
                            stmt.setString(2, editUser.getSurname());
                            stmt.setString(3, editUser.getEmail());
                            stmt.setString(4, newPassword);
                            switch (editUser.getStatus()) {
                                case ADMINISTRATOR: stmt.setInt(5, 1); break;
                                case PROJECT_MANAGER: stmt.setInt(5, 2); break;
                                case EMPLOYEE: stmt.setInt(5, 3); break;
                                case VISITOR: stmt.setInt(5, 4); break;
                                default: validUpdate = false; out.println("{\"error\":\"Unrecognized user status.\"}"); break;
                            }
                            stmt.setString(6, editUser.getUsername());
                            stmt.setString(7, oldPassword);
                        }
                    } else if (kind.equals("task")) {
                        if (user.getStatus() != User.Status.ADMINISTRATOR && user.getStatus() != User.Status.PROJECT_MANAGER) {
                            out.println("{\"error\":\"Only administrators and the project manager can update this task's details.\"}");
                            validUpdate = false;
                        } else {
                            Task task = new Gson().fromJson(request.getParameter("value"), Task.class);
                            if (user.getStatus() == User.Status.PROJECT_MANAGER) {
                                query = "SELECT DISTINCT username FROM Users, Projects, Tasks WHERE ";
                                query += "Projects.manager = Users.username AND Tasks.projectID = Projects.projectID ";
                                query += "AND Users.username = ? AND Tasks.taskID = ?";
                                stmt = conn.prepareStatement(query);
                                stmt.setString(1, user.getUsername());
                                stmt.setInt(1, task.getID());
                                ResultSet res = stmt.executeQuery();
                                if (res.next()) stmt.close();
                                else {
                                    out.println("{\"error\":\"Only administrators and the project manager can update this task's details.\"}");
                                    validUpdate = false;
                                }
                            }
                            if (validUpdate) {
                                query = "UPDATE Tasks SET ";
                                query += "title = ?, ";
                                query += "description = ?, ";
                                query += "priority = ?, ";
                                query += "beginsAt = ?, ";
                                query += "endedAt = ?, ";
                                query += "duration = ?, ";
                                query += "completed = ? ";
                                query += "WHERE projectID = ?";
                                stmt = conn.prepareStatement(query);
                                stmt.setString(1, task.getTitle());
                                stmt.setString(2, task.getDesc());
                                switch (task.getPriority()) {
                                    case LOW: stmt.setInt(3, 1); break;
                                    case MEDIUM: stmt.setInt(3, 2); break;
                                    case HIGH: stmt.setInt(3, 3); break;
                                    case URGENT: stmt.setInt(3, 4); break;
                                    case CRITICAL: stmt.setInt(3, 5); break;
                                    default: validUpdate = false; out.println("{\"error\":\"Unrecognized task priority.\"}"); break;
                                }
                                stmt.setDate(4, task.getStartDate());
                                stmt.setDate(5, task.getEndDate());
                                stmt.setInt(6, task.getDuration());
                                stmt.setBoolean(7, task.isCompleted());
                                stmt.setInt(8, task.getID());
                            }
                        }
                    } else if (kind.equals("comment")) {
                        if (user.getStatus() == User.Status.VISITOR) {
                            out.println("{\"error\":\"Visitors are second-rate users. Scram!\"}");
                            validUpdate = false;
                        } else {
                            Comment comment = new Gson().fromJson(request.getParameter("value"), Comment.class);
                            if (user.getStatus() == User.Status.PROJECT_MANAGER) {
                                query = "SELECT DISTINCT username FROM Users, Projects, Tasks, Comments WHERE ";
                                query += "Projects.manager = Users.username AND Tasks.projectID = Projects.projectID ";
                                query += "AND Comments.taskID = Tasks.taskID AND Users.username = ? AND Tasks.taskID = ?";
                                stmt = conn.prepareStatement(query);
                                stmt.setString(1, user.getUsername());
                                stmt.setInt(2, comment.getTaskID());
                                ResultSet res = stmt.executeQuery();
                                if (res.next()) stmt.close();
                                else {
                                    out.println("{\"error\":\"Only administrators and the project manager can update this task's details.\"}");
                                    validUpdate = false;
                                }
                            } else if (user.getStatus() == User.Status.EMPLOYEE) {
                                query = "SELECT username FROM Comments WHERE username = ? AND commentID = ?";
                                stmt = conn.prepareStatement(query);
                                stmt.setString(1, user.getUsername());
                                stmt.setInt(2, comment.getID());
                                ResultSet res = stmt.executeQuery();
                                if (res.next()) stmt.close();
                                else {
                                    out.println("{\"error\":\"You can only edit your own comments.\"}");
                                    validUpdate = false;
                                }
                            }
                            if (validUpdate) {
                                query = "UPDATE Comments SET content = ?, timestamp = NOW() WHERE commentID = ?";
                                stmt = conn.prepareStatement(query);
                                stmt.setString(1, comment.getContent());
                                stmt.setInt(2, comment.getID());
                            }
                        }
                    } else {
                        validUpdate = false;
                        out.println("{\"error\":\"Wrong argument\"}");
                    }
                    if (validUpdate) {
                        int affected = stmt.executeUpdate();
                        if (affected == 0)
                            out.println("{\"error\":\"Something went horribly, horribly wrong&trade;.\"}");
                        else out.println("{}");
                    }
                } else out.println("{\"error\":\"Requesting user not logged in\"}");
            }
            catch (SQLException SQLe) {
                out.println("{\"error\":\"An error occured while contacting the database. Contact your supervisor for details.\"}");
                log("SQL error at DeleteEntity", SQLe);
            } catch (Exception e) {
                out.println("{\"error\":\"An error occured while attempting to perform the update. Please contact your supervisor.\"}");
                e.printStackTrace();
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
