/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package system;

import data.DBManager;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class CheckUsername extends HttpServlet {
    private DBManager manager;
    
    @Override // THANK YOU CAPTAIN OBVIOUS
    public void init() throws ServletException {
        this.manager = DBManager.getManager();
    }
  
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/plain");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        try {
            Connection conn = null;
            PreparedStatement stmt = null;
            try{
                conn = this.manager.getConnection();
                String checkQuery = "SELECT COUNT(*) FROM Users WHERE username = ?";
                stmt = conn.prepareStatement(checkQuery);
                String newUserID = request.getParameter("newUserID");
                stmt.setString(1, newUserID);
                ResultSet results = stmt.executeQuery();
                results.next();
                if (results.getInt(1) == 0)out.println("{\"result\":\"OK\"}");
                else{
                    out.println("{\"result\":\"error\",\"message\":\"Oops!Somebody got your username first, try again with a different one.\"}");
                }
            } catch (SQLException SQLe){
                log("SQL error when checking new username", SQLe);
            } finally{
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
     * Handles the HTTP <code>GET</code> method.
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
     * Handles the HTTP <code>POST</code> method.
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
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>
}
