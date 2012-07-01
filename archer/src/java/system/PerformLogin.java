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
import javax.servlet.http.*;
import util.Toolbox;

public class PerformLogin extends HttpServlet {
    private DBManager manager;
    
    @Override // THANK YOU CAPTAIN OBVIOUS
    public void init() throws ServletException {
        this.manager = DBManager.getManager();
    }

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        try {
            Connection conn = null;
            PreparedStatement stmt = null;
            try {
                String userID = request.getParameter("userID");
                if (userID.equals(""))
                    out.println("{\"error\":\"Please enter your username and password.\"}");
                else {
                    String password = request.getParameter("password");
                    conn = this.manager.getConnection();
                    String saltQuery = "SELECT salt FROM Users WHERE username = ?";
                    stmt = conn.prepareStatement(saltQuery);
                    stmt.setString(1, userID);
                    ResultSet results = stmt.executeQuery();
                    if (results.next()) {
                        String salt = results.getString("salt");
                        String loginQuery = "SELECT username, name, surname, email, description AS status FROM Users, Status WHERE username = ? AND password = SHA1(CONCAT(?, ?)) AND Status.statusID = Users.status";
                        stmt = conn.prepareStatement(loginQuery);
                        stmt.setString(1, userID);
                        stmt.setString(2, salt);
                        stmt.setString(3, password);
                        ResultSet results2 = stmt.executeQuery();
                        if (results2.next()) {
                            out.println("{}");
                            HttpSession session = request.getSession();
                            User user = new User(results2.getString("username"), results2.getString("name"), results2.getString("surname"), results2.getString("email"), results2.getString("status"));
                            session.setAttribute("user",user);
                            if (request.getParameter("cookie") != null) {
                                Cookie cookie = new Cookie("userID", user.getUsername()+":"+Toolbox.getHashedUserID(user.getUsername(), request.getRemoteAddr(), getServletContext().getInitParameter("secret")));
                                cookie.setPath("/archer");
                                cookie.setMaxAge(365*24*60*60);
                                response.addCookie(cookie);
                            }
                        } else out.println("{\"error\":\"Your username or password is incorrect. Please, try again.\"}");
                    } else out.println("{\"error\":\"Please enter your username and password.\"}");
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
