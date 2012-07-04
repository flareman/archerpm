package system;

import com.google.gson.Gson;
import data.Comment;
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

public class GetComments extends HttpServlet {
    private DBManager manager;
    
    @Override // THANK YOU CAPTAIN CANTANKEROUS
    public void init() throws ServletException {this.manager = DBManager.getManager();}

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        try {
            Connection conn = null;
            PreparedStatement stmt = null;
            try {
                User user = (User)request.getSession().getAttribute("user");
                if (user != null) {
                    conn = this.manager.getConnection();
                    ArrayList<Comment> comments = new ArrayList<Comment>();
                    Integer task = Integer.parseInt(request.getParameter("task"));
                    if (task >= 0) {
                        String query = "SELECT DISTINCT Comments.commentID, Comments.content, Comments.timestamp, Comments.username, CONCAT(Users.name,' ',Users.surname) AS fullname, Comments.taskID";
                        query += " FROM Comments, Tasks, Projects, ProjectHasUsers, Users WHERE Comments.taskID = Tasks.taskID AND Comments.username = Users.username";
                        query += " AND Comments.taskID = ? AND Tasks.projectID = Projects.projectID AND Projects.projectID = ProjectHasUsers.projectID";
                        if (user.getStatus() != User.Status.ADMINISTRATOR) {
                            query += " AND (";
                            query += "Projects.isPublic = 1";
                            query += " OR ProjectHasUsers.username = ?";
                            query += " OR Projects.manager = ?";
                            query += ")";
                        }
                        query += " ORDER BY Comments.timestamp ASC";
                        stmt = conn.prepareStatement(query);
                        stmt.setInt(1, task);
                        if (user.getStatus() != User.Status.ADMINISTRATOR) {
                            String userID = user.getUsername();
                            stmt.setString(2, userID);
                            stmt.setString(3, userID);
                        }
                        ResultSet results = stmt.executeQuery();
                        while (results.next())
                            comments.add(new Comment(results.getInt("commentID"), results.getString("content"), results.getString("username"), results.getString("fullname"),
                                    results.getTimestamp("timestamp"), results.getInt("taskID")));
                        if (comments.isEmpty()) out.println("{}");
                        else {
                            Gson gson = new Gson();
                            String output = gson.toJson(comments, comments.getClass());
                            out.println(output);
                        }
                    } else throw new NumberFormatException();
                } else {
                    out.println("{\"error\":\"Requesting user not logged in\"}");
                }
            } catch(SQLException SQLe) {
                log("SQL error when logging in", SQLe);
            } catch(NumberFormatException ne) {
                out.println("{\"error\":\"Invalid task ID requested\"}");
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
