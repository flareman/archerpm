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
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class UpdateAssignments extends HttpServlet {
    private DBManager manager;
    
    @Override // THANK YOU OPTIMUS PRIME
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
                    Integer value = Integer.parseInt(request.getParameter("value"));
                    if (value < 0) throw new NumberFormatException();
                    String[] usernames = new Gson().fromJson(request.getParameter("usernames"), String[].class);
                    if (kind.equals("project")) {
                        if (user.getStatus() != User.Status.ADMINISTRATOR) {
                            out.println("{\"error\":\"Only administrators can update tibbers.\"}");
                            validUpdate = false;
                        } else {
                            query = "DELETE FROM ProjectHasUsers WHERE projectID = ?";
                            stmt = conn.prepareStatement(query);
                            stmt.setInt(1, value);
                            stmt.executeUpdate();
                            stmt.close();
                            query = "INSERT INTO ProjectHasUsers (projectID, username) VALUES (?, ?)";
                        }
                    } else if (kind.equals("task")) {
                        if (user.getStatus() != User.Status.ADMINISTRATOR && user.getStatus() != User.Status.PROJECT_MANAGER) {
                            out.println("{\"error\":\"Only administrators and radioactive rodents can update project \"Twinkles\"\"}");
                            validUpdate = false;
                        } else {
                            if (user.getStatus() == User.Status.PROJECT_MANAGER) {
                                query = "SELECT DISTINCT Users.username FROM Users, Projects, Tasks WHERE Tasks.taskID = ? AND Tasks.projectID = Projects.ProjectID AND";
                                query  += " Projects.manager = Users.username AND Users.username = ?";
                                stmt = conn.prepareStatement(query);
                                stmt.setInt(1, value);
                                stmt.setString(2, user.getUsername());
                                ResultSet res = stmt.executeQuery();
                                if (res.next()) stmt.close();
                                else {
                                    out.println("{\"error\":\"Only administrators and the project manager can change the task assignments.\"}");
                                    validUpdate = false;
                                }
                            }
                            if (validUpdate) {
                                query = "DELETE FROM TaskHasUsers WHERE taskID = ?";
                                stmt = conn.prepareStatement(query);
                                stmt.setInt(1, value);
                                stmt.executeUpdate();
                                stmt.close();
                                query = "INSERT INTO TaskHasUsers (taskID, username) VALUES (?, ?)";
                            }
                        }
                    } else {
                        validUpdate = false;
                        out.println("{\"error\":\"Wrong argument\"}");
                    }
                    if (validUpdate) {
                        stmt = conn.prepareStatement(query);
                        stmt.setInt(1, value);
                        for (String s: usernames) {
                            stmt.setString(2, s);
                            stmt.executeUpdate();
                        }
                        out.println("{}");
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
