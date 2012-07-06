package system;

import data.DBManager;
import data.User;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class DeleteEntity extends HttpServlet {
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
            Boolean validUpdate = true;
            try {
                User user = (User)request.getSession().getAttribute("user");
                if (user != null) {
                    conn = this.manager.getConnection();
                    String kind = request.getParameter("kind");
                    if (kind.equals("project")) {
                        if (user.getStatus() != User.Status.ADMINISTRATOR) {
                            out.println("{\"error\":\"Only administrators can delete projects\"}");
                            validUpdate = false;
                        } else {
                            Integer projectID = Integer.parseInt(request.getParameter("value"));
                            query = "DELETE FROM Projects WHERE projectID = ?";
                            stmt = conn.prepareStatement(query);
                            stmt.setInt(1, projectID);
                        }
                    } else if (kind.equals("user")) {
                        if (user.getStatus() != User.Status.ADMINISTRATOR) {
                            out.println("{\"error\":\"Only administrators can delete users\"}");
                            validUpdate = false;
                        } else {
                            String username = request.getParameter("value");
                            query = "DELETE FROM Users WHERE username = ?";
                            stmt = conn.prepareStatement(query);
                            stmt.setString(1, username);
                        }
                    } else if (kind.equals("task")) {
                        if (user.getStatus() != User.Status.ADMINISTRATOR && user.getStatus() != User.Status.PROJECT_MANAGER) {
                            validUpdate = false;
                            out.println("{\"error\":\"Only administrators and the project manager can delete tasks for this project.\"}");
                        } else {
                            Integer taskID = Integer.parseInt(request.getParameter("value"));
                            if (user.getStatus() != User.Status.ADMINISTRATOR) {
                                query = "SELECT DISTINCT username FROM Users, Projects, Tasks WHERE Tasks.taskID = ? AND Tasks.projectID = Projects.ProjectID AND";
                                query  += " (Projects.manager  = Users.username OR Projects.isPublic = 1)";
                                query += " AND Users.username = ?";
                                stmt = conn.prepareStatement(query);
                                stmt.setInt(1, taskID);
                                stmt.setString(2, user.getUsername());
                                ResultSet res = stmt.executeQuery();
                                if (res.next()) stmt.close();
                                else {
                                    out.println("{\"error\":\"Only administrators and the manager of the project this task is a part of can delete this task.\"}");
                                    validUpdate = false;
                                }
                            }
                            if (validUpdate) {
                                query = "DELETE FROM Tasks WHERE taskID = ?";
                                stmt = conn.prepareStatement(query);
                                stmt.setInt(1, taskID);
                            }
                        }
                    } else if (kind.equals("comment")) {
                        if (user.getStatus() != User.Status.ADMINISTRATOR && user.getStatus() != User.Status.PROJECT_MANAGER) {
                            validUpdate = false;
                            out.println("{\"error\":\"Only administrators and the project manager can delete comments for this project.\"}");
                        } else {
                            Integer commentID = Integer.parseInt(request.getParameter("value"));
                            if (user.getStatus() != User.Status.ADMINISTRATOR) {
                                query = "SELECT DISTINCT username FROM Users, Projects, Tasks, Comments WHERE Comments.commentID = ? AND Tasks.projectID = Projects.ProjectID AND";
                                query  += " Comments.taskID = Tasks.taskID AND (Projects.manager  = Users.username OR Projects.isPublic = 1)";
                                query += " AND Users.username = ?";
                                stmt = conn.prepareStatement(query);
                                stmt.setInt(1, commentID);
                                stmt.setString(2, user.getUsername());
                                ResultSet res = stmt.executeQuery();
                                if (res.next()) stmt.close();
                                else {
                                    out.println("{\"error\":\"Only administrators and the project manager can delete comments of this project.\"}");
                                    validUpdate = false;
                                }
                            }
                            if (validUpdate) {
                                query = "DELETE FROM Comments WHERE commentID = ?";
                                stmt = conn.prepareStatement(query);
                                stmt.setInt(1, commentID);
                            }
                        }
                    } else {
                        validUpdate = false;
                        out.println("{\"error\":\"Wrong argument\"}");
                    }
                    if (validUpdate) {
                        int affected = stmt.executeUpdate();
                        if (affected == 0)
                            out.println("{\"error\":\"Something went wrong&trade;.\"}");
                        else out.println("{}");
                    }
                } else out.println("{\"error\":\"Requesting user not logged in\"}");
            }
            catch (SQLException SQLe) {
                out.println("{\"error\":\"An error occured while contacting the database. Contact your supervisor for details.\"}");
                log("SQL error at DeleteEntity", SQLe);
            } catch (Exception e) {
                out.println("{\"error\":\"An error occured while attempting to perform the deletion. Please contact your supervisor.\"}");
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
