package system;

import data.DBManager;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import util.Toolbox;

public class PerformLogin extends HttpServlet {
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
            try {
                String userID = request.getParameter("userID");
                if (userID.equals(""))
                    out.println("{\"result\":\"error\",\"message\":\"Please enter your username and password.\"}");
                else {
                    String password = request.getParameter("password");
                    conn = this.manager.getConnection();
                    String saltQuery = "SELECT salt FROM Users WHERE username = ?";
                    stmt = conn.prepareStatement(saltQuery);
                    stmt.setString(1, userID);
                    ResultSet results = stmt.executeQuery();
                    if (results.next()) {
                        String salt = results.getString("salt");
                        String loginQuery = "SELECT COUNT(*) FROM Users WHERE username = ? AND password = SHA1(CONCAT(?, ?))";
                        stmt = conn.prepareStatement(loginQuery);
                        stmt.setString(1, userID);
                        stmt.setString(2, salt);
                        stmt.setString(3, password);
                        ResultSet results2 = stmt.executeQuery();
                        results2.next();
                        if (results2.getInt(1) == 0)
                            out.println("{\"result\":\"error\",\"message\":\"Please enter your username and password.\"}");
                        else {
                            out.println("{\"result\":\"OK\"}");
                            HttpSession session = request.getSession();
                            session.setAttribute("userID",userID);
                            if (request.getParameter("cookie") != null) {
                                Cookie cookie = new Cookie("userID", userID+":"+Toolbox.getHashedUserID(userID, request.getRemoteAddr(), getServletContext().getInitParameter("secret")));
                                cookie.setPath("/archer");
                                cookie.setMaxAge(365*24*60*60);
                                response.addCookie(cookie);
                            }
                        }
                    } else out.println("{\"result\":\"error\",\"message\":\"Your username or password is incorrect. Please, try again.\"}");
                }
            } catch (SQLException SQLe) {
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
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Performs login into Archer";
    }// </editor-fold>
}
