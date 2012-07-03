<%@page contentType="text/html" pageEncoding="UTF-8" %>
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
	<title>Welcome to Archer</title>
	<link rel="stylesheet" href="<%=base%>/stylesheets/foundation.css">
	<link rel="stylesheet" href="<%=base%>/stylesheets/archer.css">
	<script src="<%=base%>/javascripts/modernizr.foundation.js"></script>
	<!--[if lt IE 9]>
		<script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script>
	<![endif]-->

</head>
    <body>
        <div class="row full-height etched"><div class="twelve columns">
            <div class="row">
                <div id="header" class="twelve columns centered">
                    <div class="row"><div class="four columns centered"><img id="logo" class="hidden" src="images/archer/archer_big.png" alt="Welcome to Archer"/></div></div>
                    <div class="row">
                        <div class="six columns centered"><h1 class="hidden" id="welcome">Welcome to Archer</h1></div>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="four columns centered">
                    <div class="large radius panel">
                        <form id="loginForm" class="custom" action="#" method="POST">
                            <h5 class="centertext subheader">Log in to start using Archer:</h4>
                            <div id="loginResult"></div>
                            <input id="userID"required placeholder="Username" type="text" name="userID" />
                            <input id="password" required placeholder="Password" type="password" name="password" />
                            <label for="cookie" class="centertext">
                                <input type="checkbox" id="cookie" name="cookie" style="display: none;">
                                <span id="cookieCbx" class="custom checkbox"></span> Keep me logged in
                            </label>
                            <br>
                            <div class="row">
                                <div class="eight columns centered">
                                    <input id="loginButton" type="submit" value="Login" disabled class="radius button expand" />
                                </div>
                            </div>
                        </form>
                        <div class="row"><div class="twelve columns centertext"><a href="#" id="regPrompt">New User? Click Here</a></div></div>
                    </div>
                </div>
            </div>
        </div></div>
        <div class="row footer etched"><div class="twelve columns">
                <div class="row"><div class="six columns centered"><p class="centertext copyright">Spyridon Smparounis, George Papakyriakopoulos © 2012</p></div></div>
        </div></div>
    </body>
    <script src="<%=base%>/javascripts/jquery.min.js"></script>
    <script src="<%=base%>/javascripts/jquery.textchange.min.js"></script>
    <script src="<%=base%>/javascripts/jquery.exists.js"></script>
    <script src="<%=base%>/javascripts/foundation.js"></script>
    <script src="<%=base%>/javascripts/util.jsp" type="text/javascript" language="JavaScript"></script>
    <script src="<%=base%>/javascripts/login.jsp" type="text/javascript" language="JavaScript"></script>
</html>
