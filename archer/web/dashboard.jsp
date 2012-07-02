<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page import="util.Toolbox" %>
<%@ page import="data.User" %>
<% User currentUser = (User)request.getSession().getAttribute("user"); %>

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
	<link rel="stylesheet" href="stylesheets/foundation.css">
	<link rel="stylesheet" href="stylesheets/archer.css">
	<script src="javascripts/modernizr.foundation.js"></script>
	<!--[if lt IE 9]>
		<script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script>
	<![endif]-->

</head>
    <body>
        <div class="row full-height etched"><div class="twelve columns">
            <div class="top row">
                <div class="three columns top logo"></div>
                <div class="nine columns"><h3 class="subheader white">Welcome, <%=currentUser.getName()+" "+currentUser.getSurname() %></h3></div>
            </div>
            <div class="row">
                <div class="three columns">
                    <div class="panel large radius">
                        <ul class="side-nav">
                            <li id="myprojects"><h6>My Projects</h6></li>
                            <li class="divider"></li>
                            <li id="publicprojects"><h6>Public Projects</h6></li>
                            <li class="divider"></li>
                            <li><a href="#" class="" id="userSettings">Settings</a></li>
                            <li><a href="#" class="" id="logout">Logout</a></li>
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
    <script src="javascripts/jquery.min.js"></script>
    <script src="javascripts/jquery.textchange.min.js"></script>
    <script src="javascripts/jquery.exists.js"></script>
    <script src="javascripts/foundation.js"></script>
    <script src="javascripts/util.jsp" type="text/javascript" language="JavaScript"></script>
    <script src="javascripts/dashboard.jsp" type="text/javascript" language="JavaScript"></script>
</html>
