package system;

import data.DBManager;
import data.User;
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

public class PerformCheck extends HttpServlet {
    private DBManager manager;
    
    @Override // THANK YOU FAT BASTARD
    public void init() throws ServletException {this.manager = DBManager.getManager();}

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        try {
            Connection conn = null;
            PreparedStatement stmt = null;
            String query = "";
            Boolean validCheck = true;
            try {
                User user = (User)request.getSession().getAttribute("user");
                if (user != null) {
                    conn = this.manager.getConnection();
                    String check = request.getParameter("check");
                    String kind = request.getParameter("kind");
                    Integer value = Integer.parseInt(request.getParameter("value"));
                    if (check.equals("manager")) {
                        if (user.getStatus() == User.Status.VISITOR || user.getStatus() == User.Status.UNDEFINED) {
                            validCheck = false;
                            out.println("{\"result\":false}");
                        } else {
                            if (user.getStatus() != User.Status.ADMINISTRATOR) {
                                if (kind.equals("project")) {
                                    query = "SELECT DISTINCT Users.username FROM Users, Projects WHERE Projects.projectID = ? AND";
                                    query  += " Projects.manager = Users.username AND Users.username = ?";
                                } else if (kind.equals("task")) {
                                    query = "SELECT DISTINCT Users.username FROM Users, Projects, Tasks, TaskHasUsers WHERE Tasks.taskID = ? AND Tasks.projectID = Projects.projectID AND";
                                    query  += " TaskHasUsers.taskID = Tasks.taskID AND (TaskHasUsers.username = Users.username OR Projects.manager = Users.username) AND Users.username = ?";
                                } else if (kind.equals("comment")) {
                                    query = "SELECT DISTINCT Users.username FROM Users, Projects, Tasks, Comments WHERE Comments.commentID = ? AND Tasks.projectID = Projects.projectID AND";
                                    query  += " Comments.taskID = Tasks.taskID AND Users.username = ? AND (Projects.manager = Users.username OR Comments.username = Users.username)";
                                } else {
                                    out.println("{\"result\":false}");
                                    validCheck = false;
                                }
                                if (validCheck) {
                                    stmt = conn.prepareStatement(query);
                                    stmt.setInt(1, value);
                                    stmt.setString(2, user.getUsername());
                                    ResultSet res = stmt.executeQuery();
                                    if (res.next()) stmt.close();
                                    else {
                                        out.println("{\"result\":false}");
                                        validCheck = false;
                                    }
                                }
                            }
                        }
                    } else {
                        validCheck = false;
                        out.println("{\"error\":\"Wrong argument\"}");
                    }
                    if (validCheck)
                        out.println("{\"result\":true}");
                } else out.println("{\"result\":false}");
            }
            catch (SQLException SQLe) {
                out.println("{\"result\":false}");
                log("SQL error at DeleteEntity", SQLe);
            } catch (Exception e) {
                out.println("{\"result\":false}");
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
