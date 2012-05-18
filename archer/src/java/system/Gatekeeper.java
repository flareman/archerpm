package system;

import data.DBManager;
import data.User;
import java.io.IOException;
import java.io.PrintStream;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.*;
import javax.servlet.http.Cookie;
import util.Toolbox;

public class Gatekeeper implements Filter {
    private FilterConfig filterConfig = null;
    private DBManager manager;
    
    public Gatekeeper() {}    
    private void doBeforeProcessing(ServletRequest request, ServletResponse response)
            throws IOException, ServletException {}    
    private void doAfterProcessing(ServletRequest request, ServletResponse response)
            throws IOException, ServletException {}

    public void init(FilterConfig filterConfig) {        
        this.filterConfig = filterConfig;
        if (filterConfig != null) {
        }
        this.manager = DBManager.getManager();
    }

    public void doFilter(ServletRequest request, ServletResponse response,
            FilterChain chain)
            throws IOException, ServletException {
        
        doBeforeProcessing(request, response);
        
        Throwable problem = null;
        try {
            javax.servlet.http.HttpServletRequest theRequest = ((javax.servlet.http.HttpServletRequest)request);
            javax.servlet.http.HttpSession session = theRequest.getSession(false);
            Cookie userCookie = Toolbox.getCookieByName(theRequest.getCookies(), "userID");
            if (userCookie != null) {
                String userID = userCookie.getValue().split(":")[0];
                String hash = userCookie.getValue().substring(userID.length()+1);
                if (Toolbox.getHashedUserID(userID, request.getRemoteAddr(), theRequest.getServletContext().getInitParameter("secret")).equals(hash)) {
                    session = theRequest.getSession();
                    Connection conn = null;
                    PreparedStatement stmt = null;
                    try {
                        conn = this.manager.getConnection();
                        String userQuery = "SELECT username, name, surname, email, description AS status FROM Users, Status WHERE username = ? AND Status.statusID = Users.status";
                        stmt = conn.prepareStatement(userQuery);
                        stmt.setString(1, userID);
                        ResultSet results = stmt.executeQuery();
                        if (results.next()) {
                            User user = new User(results.getString("username"), results.getString("name"), results.getString("surname"), results.getString("email"), results.getString("status"));
                            session.setAttribute("user", user);
                        } else throw new LoginFailureException("The user previously logged in no longer exists. Try again please.");
                    } catch (SQLException SQLe){
                        log("SQL error when checking new username: "+SQLe.getLocalizedMessage());
                    } finally {
                        try {
                            stmt.close();
                            conn.close();
                        } catch (Exception e) { e.printStackTrace(); }
                    }
                } else {
                    userCookie.setValue(""); userCookie.setMaxAge(0); ((javax.servlet.http.HttpServletResponse)response).addCookie(userCookie);
                    if (session != null) session.invalidate();
                    throw new LoginFailureException("You have been logged out of the system for security reasons. You can log back in.");
                }
            }
            if (theRequest.getRequestURI().equals("/archer/")) {
                if ((session != null) && (session.getAttribute("user") != null)) {
                    throw new AlreadyLoggedInException();
                }
            } else if ((session == null) || (session.getAttribute("user") == null)) {
                if (userCookie != null) {
                } else throw new LoginFailureException("You are not logged in. Please login before using Archer.");
            }
            chain.doFilter(request, response);
        } catch (Throwable t) {
            // If an exception is thrown somewhere down the filter chain,
            // we still want to execute our after processing, and then
            // rethrow the problem after that.
            problem = t;
            // t.printStackTrace();
        }
        
        doAfterProcessing(request, response);

        // If there was a problem, we want to rethrow it if it is
        // a known type, otherwise log it.
        if (problem != null) {
            if (problem instanceof LoginFailureException) {
                ((javax.servlet.http.HttpServletResponse)response).sendRedirect("/archer");
            }
            if (problem instanceof AlreadyLoggedInException) {
                ((javax.servlet.http.HttpServletResponse)response).sendRedirect("/archer/dashboard");
            }
            if (problem instanceof ServletException) {
                throw (ServletException) problem;
            }
            if (problem instanceof IOException) {
                throw (IOException) problem;
            }
            sendProcessingError(problem, response);
        }
    }

    public FilterConfig getFilterConfig() {
        return (this.filterConfig);
    }

    public void setFilterConfig(FilterConfig filterConfig) {
        this.filterConfig = filterConfig;
    }

    public void destroy() {        
    }

    @Override
    public String toString() {
        if (filterConfig == null) {
            return ("Gatekeeper()");
        }
        StringBuffer sb = new StringBuffer("Gatekeeper(");
        sb.append(filterConfig);
        sb.append(")");
        return (sb.toString());
    }
    
    private void sendProcessingError(Throwable t, ServletResponse response) {
        String stackTrace = getStackTrace(t);        
        
        if (stackTrace != null && !stackTrace.equals("")) {
            try {
                response.setContentType("text/html");
                PrintStream ps = new PrintStream(response.getOutputStream());
                PrintWriter pw = new PrintWriter(ps);                
                pw.print("<html>\n<head>\n<title>Error</title>\n</head>\n<body>\n"); //NOI18N

                // Pending: Localize this for next official release
                pw.print("<h1>The resource did not process correctly</h1>\n<pre>\n");                
                pw.print(stackTrace);                
                pw.print("</pre></body>\n</html>"); //NOI18N
                pw.close();
                ps.close();
                response.getOutputStream().close();
            } catch (Exception ex) {
            }
        } else {
            try {
                PrintStream ps = new PrintStream(response.getOutputStream());
                t.printStackTrace(ps);
                ps.close();
                response.getOutputStream().close();
            } catch (Exception ex) {
            }
        }
    }
    
    public static String getStackTrace(Throwable t) {
        String stackTrace = null;
        try {
            StringWriter sw = new StringWriter();
            PrintWriter pw = new PrintWriter(sw);
            t.printStackTrace(pw);
            pw.close();
            sw.close();
            stackTrace = sw.getBuffer().toString();
        } catch (Exception ex) {
        }
        return stackTrace;
    }
    
    public void log(String msg) {
        filterConfig.getServletContext().log(msg);        
    }
}

class LoginFailureException extends Exception { public LoginFailureException(String errorMsg) { super(errorMsg); } }

class AlreadyLoggedInException extends Exception {
    public AlreadyLoggedInException() { super(); }
    public AlreadyLoggedInException(String errorMsg) { super(errorMsg); }
}
