<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page import="util.Toolbox" %>
<%@ page import="data.User" %>
<% User currentUser = (User)request.getSession().getAttribute("user"); %>
<% String base = request.getContextPath(); %>

<!DOCTYPE html>

<!--[if lt IE 7]> <html class="no-js lt-ie9 lt-ie8 lt-ie7" lang="en"> <![endif]-->
<!--[if IE 7]>    <html class="no-js lt-ie9 lt-ie8" lang="en"> <![endif]-->
<!--[if IE 8]>    <html class="no-js lt-ie9" lang="en"> <![endif]-->
<!--[if gt IE 8]><!--> <html class="no-js" lang="en"> <!--<![endif]-->

<html>
<head>
	<meta charset="utf-8" />
	<meta name="viewport" content="width=device-width" />
	<title>Archer - Dashboard</title>
	<link rel="stylesheet" href="<%=base%>/stylesheets/foundation.css">
	<link rel="stylesheet" href="<%=base%>/stylesheets/archer.css">
	<script src="<%=base%>/javascripts/modernizr.foundation.js"></script>
	<!--[if lt IE 9]>
		<script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script>
	<![endif]-->

</head>
    <body>
        <div class="row full-height etched"><div class="twelve columns">
            <div class="top row">
                <div class="three columns top logo"><a href="#" class="home"></a></div>
                <div class="nine columns"><h3 class="subheader white">Welcome, <%=currentUser.getName()+" "+currentUser.getSurname() %></h3></div>
            </div>
            <div class="row">
                <div class="three columns">
                    <div class="panel large radius">
                        <ul class="side-nav">
                            <li><a href="#" class="home"><h5>Home</h5></a><li>
                            <li class="divider"></li>
                            <ul class="side-nav projects">
                            </ul>
                            <li><a href="#/settings" class="" id="userSettings">Settings</a></li>
                            <li><a href="<%=base%>" class="" id="logout">Logout</a></li>
                        </ul>
                    </div>
                </div>
                <div class="nine columns">
                    <div class="panel radius" id="content">
                    </div>
                </div>
            </div>
        </div></div>
        <div class="row footer etched"><div class="twelve columns">
                <div class="row"><div class="six columns centered"><p class="centertext copyright">Spyridon Smparounis, George Papakyriakopoulos © 2012</p></div></div>
        </div></div>
        <div id="modals"></div>
    </body>
    <script src="<%=base%>/javascripts/jquery.min.js"></script>
    <script src="<%=base%>/javascripts/jquery.textchange.min.js"></script>
    <script src="<%=base%>/javascripts/jquery.exists.js"></script>
    <script src="<%=base%>/javascripts/jquery.address.min.js"></script>
    <script src="<%=base%>/javascripts/foundation.js"></script>
    <script src="<%=base%>/javascripts/util.jsp" type="text/javascript" language="JavaScript"></script>
    <script src="<%=base%>/javascripts/dashboard.jsp" type="text/javascript" language="JavaScript"></script>
</html>
