<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="util.Toolbox" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Dashboard</title>
    </head>
    <body>
        <h1>Welcome, <%=request.getSession().getAttribute("userID") %></h1>
        <p><% for (Cookie c: request.getCookies()) out.println(c.getName()+": "+c.getValue()); %></p>
        <p><a href="<%= response.encodeURL("dashboard/logout") %>">Log out from Archer</a></p>
    </body>
</html>
