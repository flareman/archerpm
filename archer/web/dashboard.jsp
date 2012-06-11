<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page import="util.Toolbox" %>
<%@ page import="data.User" %>

<!DOCTYPE html>

<!--[if lt IE 7]> <html class="no-js lt-ie9 lt-ie8 lt-ie7" lang="en"> <![endif]-->
<!--[if IE 7]>    <html class="no-js lt-ie9 lt-ie8" lang="en"> <![endif]-->
<!--[if IE 8]>    <html class="no-js lt-ie9" lang="en"> <![endif]-->
<!--[if gt IE 8]><!--> <html class="no-js dashboard" lang="en"> <!--<![endif]-->

<html class="dashboard">
<head>
	<meta charset="utf-8" />
	<meta name="viewport" content="width=device-width" />
	<title>Archer - Dashboard</title>
	<link rel="stylesheet" href="stylesheets/foundation.css">
	<link rel="stylesheet" href="stylesheets/app.css">
	<link rel="stylesheet" href="stylesheets/archer.css">
	<!--[if lt IE 9]>
		<link rel="stylesheet" href="stylesheets/ie.css">
	<![endif]-->
	<script src="javascripts/modernizr.foundation.js"></script>
	<!--[if lt IE 9]>
		<script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script>
	<![endif]-->

</head>
    <body class="dashboard">
        <div class="container dashboard shadow">
            <div class="top row">
                <div class="two columns top logo"></div>
                <div class="nine columns"></div>
                <div class="one column top settings">
                    <a href="#" id="gear"></a>
                    <div id="settings-menu">
                        <p><%=((User)request.getSession().getAttribute("user")).getName()+" "+((User)request.getSession().getAttribute("user")).getSurname() %></p>
                        <hr />
                        <a href="#" id="userSettings">Settings</a>
                        <a href="#" id="logout">Logout</a>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="three columns">
                    <div class="shadow panel radius">
                    </div>
                </div>
                <div class="nine columns">
                    <div class="shadow panel">
                        <p><a href="#" id="getUsers">Get Users</a></p>
                        <p><a href="#" id="getProjects">Get Projects</a></p>
                        <p><a href="#" id="getTasks">Get My Tasks</a></p>
                        <p id="result"></p>
                    </div>
                </div>
            </div>
        </div>
    </body>
    <script src="javascripts/jquery.min.js"></script>
    <script src="javascripts/jquery.textchange.min.js"></script>
    <script src="javascripts/jquery.exists.js"></script>
    <script src="javascripts/foundation.js"></script>
    <script src="javascripts/app.js"></script>
    <script src="javascripts/util.jsp" type="text/javascript" language="JavaScript"></script>
    <script src="javascripts/dashboard.jsp" type="text/javascript" language="JavaScript"></script>
</html>
