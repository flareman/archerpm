
package data;
import javax.servlet.ServletContextListener;
import javax.servlet.http.HttpSession;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContext;
import java.util.HashMap; 

public class ArcherContextListener implements ServletContextListener{
    
    @Override
    public void contextInitialized(ServletContextEvent event){
        ServletContext sc = event.getServletContext();
        HashMap<String, HttpSession> map = new HashMap<String, HttpSession>();
        sc.setAttribute("sessionMap", map);
    }
    
    @Override
    public void contextDestroyed(ServletContextEvent event){
        
    }
    
}
