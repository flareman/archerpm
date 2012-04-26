
package data;

import javax.servlet.http.HttpSessionListener;
import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSession;
import javax.servlet.ServletConfig;
import javax.servlet.ServletContext;
import java.util.HashMap;

public class ArcherSessionListener implements HttpSessionListener{
    
    
    public void init(ServletConfig config){  
    
    }
    
    @Override
    public void sessionCreated(HttpSessionEvent event){  
        HttpSession session = event.getSession();  
        ServletContext context = session.getServletContext();  
        HashMap activeUsers = (HashMap)context.getAttribute("sessionMap");  
        activeUsers.put(session.getId(), session);  
    }  
    
    @Override
    public void sessionDestroyed(HttpSessionEvent event){  
        HttpSession session = event.getSession();  
        ServletContext context = session.getServletContext();  
        HashMap activeUsers = (HashMap)context.getAttribute("sessionMap");
        activeUsers.remove(session.getId());  
    }  
    
}
