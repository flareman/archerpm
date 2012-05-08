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

/**
 *
 * @author george
 */
public class PerformRegistration extends HttpServlet {
    private DBManager manager;
    
    @Override // THANK YOU CAPTAIN OBVIOUS
    public void init() throws ServletException {
        this.manager = DBManager.getManager();
    }
    
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/plain;charset=UTF-8");
        PrintWriter out = response.getWriter();
        try {
            Connection conn = null;
            PreparedStatement stmt = null;
            try{
                conn = this.manager.getConnection();
                String checkQuery = "SELECT COUNT(*) FROM Users WHERE username = ?";
                stmt = conn.prepareStatement(checkQuery);
                String newUserID = request.getParameter("newUserID");
                String pass = request.getParameter("newPassword");
                String email = request.getParameter("email");
                stmt.setString(1, newUserID);
                ResultSet results = stmt.executeQuery();
                results.next();
               
                if (results.getInt(1) != 0)
                    out.println("{\"result\":\"error\",\"message\":\"The username you asked for is taken, sorry. Please pick another.\"}");
                else if (newUserID.equals(""))
                    out.println("{\"result\":\"error\",\"message\":\"You must provide a username to register.\"}");
                else if (email.equals(""))
                    out.println("{\"result\":\"error\",\"message\":\"You must provide a valid e-mail address to register.\"}");
                else if (pass.length() < 6)
                    out.println("{\"result\":\"error\",\"message\":\"Your password must be at least 6 characters long.\"}");
                else {
                    checkQuery = "INSERT INTO Users(username,password,name,surname,email,status) VALUES(?,SHA1(?),?,?,?,?)";
                    stmt = conn.prepareStatement(checkQuery);
                    newUserID = request.getParameter("newUserID");
                    String pass2 = request.getParameter("passcheck");
                    if(!(pass.equals(pass2)))
                        out.println("{\"result\":\"error\",\"message\":\"Oops! Passwords provided do not match.\"}");
                    else{
                        String name = request.getParameter("name");
                        String surname = request.getParameter("surname");
                        String email2 = request.getParameter("email2");
                        if(!(email.equals(email2))){
                            out.println("{\"result\":\"error\",\"message\":\"Oops! Emails provided do not match.\"}");
                        }
                        else{
                            stmt.setString(1, newUserID);
                            stmt.setString(2, pass);
                            stmt.setString(3, name);
                            stmt.setString(4, surname);
                            stmt.setString(5, email);
                            stmt.setString(6, "4");
                            stmt.executeUpdate();
                            out.println("{\"result\":\"OK\"}");

                        }
                    }
                    
                }
                
            } catch (SQLException SQLe){
                log("SQL error while registering new user", SQLe);
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
