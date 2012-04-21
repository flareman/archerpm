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
import com.google.gson.*;

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
                conn = this.manager.getConnection();
                String loginQuery = "SELECT COUNT(*) FROM Users WHERE username = ? AND password = SHA1(?)";
                stmt = conn.prepareStatement(loginQuery);
                String userID = request.getParameter("userID");
                String password = request.getParameter("password");
                stmt.setString(1, userID);
                stmt.setString(2, password);
                ResultSet results = stmt.executeQuery();
                results.next();
                if (results.getInt(1) == 0)
                    out.println("{\"result\":\"error\",\"message\":\"Your username or password is incorrect. Please, try again.\"}");
                else out.println("{\"result\":\"OK\"}");
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
