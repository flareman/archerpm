package system;

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
import com.google.gson.*;

public class GetUserList extends HttpServlet {
    
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
            try {
                String userID = (String)request.getSession().getAttribute("userID");
                if ((userID != null) && (!userID.equals(""))) {
                    conn = this.manager.getConnection();
                    String query = "SELECT Status.description FROM Users, Status WHERE Users.username = ? AND Status.statusID = Users.status";
                    stmt = conn.prepareStatement(query);
                    stmt.setString(1, userID);
                    ResultSet userCapacityRes = stmt.executeQuery();
                    if (userCapacityRes.next()) {
                        if (userCapacityRes.getString("description").equals("Site Administrator")) {
                            ArrayList<User> users = new ArrayList<User>();
                            query = "SELECT username, name, surname, email, status FROM Users";
                            stmt = conn.prepareStatement(query);
                            ResultSet results = stmt.executeQuery();
                            while (results.next())
                                users.add(new User(results.getString("username"),results.getString("name"),
                                    results.getString("surname"),results.getString("email"),results.getInt("status")));
                            if (users.isEmpty()) {
                                out.println("{\"error\":\"No users found\"}");
                            } else {
                                Gson gson = new Gson();
                                String output = gson.toJson(users, users.getClass());
                                out.println(output);
                            }
                        } else {
                            // User not an admin
                        }
                    } else {
                        // User not present
                    }
                } else {
                    // User without session
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

