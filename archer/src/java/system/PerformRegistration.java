package system;

import data.DBManager;
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
import util.Toolbox;

public class PerformRegistration extends HttpServlet {
    private DBManager manager;
    
    @Override // THANK YOU CAPTAIN OBVIOUS
    public void init() throws ServletException {
        this.manager = DBManager.getManager();
    }
    
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/json;charset=UTF-8");
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
                    out.println("{\"error\":\"The username you asked for is taken, sorry. Please pick another.\"}");
                else if (newUserID.equals(""))
                    out.println("{\"error\":\"You must provide a username to register.\"}");
                else if (email.equals(""))
                    out.println("{\"error\":\"You must provide a valid e-mail address to register.\"}");
                else if (pass.length() < 6)
                    out.println("{\"error\":\"Your password must be at least 6 characters long.\"}");
                else {
                    checkQuery = "INSERT INTO Users(username,salt,password,name,surname,email,status) VALUES(?,?,SHA1(CONCAT(?,?)),?,?,?,?)";
                    stmt = conn.prepareStatement(checkQuery);
                    newUserID = request.getParameter("newUserID");
                    String pass2 = request.getParameter("passcheck");
                    if(!(pass.equals(pass2)))
                        out.println("{\"error\":\"Oops! Passwords provided do not match.\"}");
                    else{
                        String name = request.getParameter("name");
                        String surname = request.getParameter("surname");
                        String email2 = request.getParameter("email2");
                        if(!(email.equals(email2))){
                            out.println("{\"error\":\"Oops! Emails provided do not match.\"}");
                        }
                        else{
                            stmt.setString(1, newUserID);
                            String salt = Toolbox.randomString(15);
                            stmt.setString(2, salt);
                            stmt.setString(3, salt);
                            stmt.setString(4, pass);
                            stmt.setString(5, name);
                            stmt.setString(6, surname);
                            stmt.setString(7, email);
                            stmt.setString(8, "4");
                            stmt.executeUpdate();
                            out.println("{}");
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
