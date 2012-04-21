<%@page contentType="text/html" pageEncoding="UTF-8" import="java.util.*" %>

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
    <body>
        <div class="container">
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
                    <div class="radius shadow panel">
                        <div class="row">
                            <form class="nice" id="loginForm" action="#" method="POST">
                                <p class="archer form details">Please enter your login info to start:</p>
                                <div id="loginResult"></div>
                                <input id="userID" class="input-text" required placeholder="Username" type="text" name="userID" /> 
                                <input id="password" class="input-text" required placeholder="Password" type="password" name="password" />
                                <input id="loginButton" type="submit" value="Login" class="nice radius blue button full-width"></input>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </body>
    <script src="javascripts/jquery.min.js"></script>
    <script src="javascripts/foundation.js"></script>
    <script src="javascripts/app.js"></script>
    
    <script>
        $(function() {
            $("#userID").focus();
            $("#logo").fadeIn(1000);
            $("#welcome").delay(1000).fadeIn(500);
            $("#loginForm").submit(function() {
                $("#loginButton").attr("disabled", "disabled");
                $.ajax({  
                  type: "POST",  
                  url: "login",  
                  data: $(this).serialize(),  
                  success: function(data) {
                    var r = $.parseJSON(data);
                    var alertbox = $("<div/>").addClass("alert-box centertext").attr("id","loginResult");
                    alertbox.hide();
                    if (r.result === "error") {
                        alertbox.html(r.message);
                        alertbox.addClass("error");
                    } else {
                        alertbox.html("Logged in nicely! :)");
                        alertbox.addClass("success");
                    }
                    $("#loginResult").fadeOut(300, function() {
                        $("#loginResult").replaceWith(alertbox);
                        alertbox.fadeIn(300);
                        if (r.result === "OK") alertbox.delay(2000).fadeOut();
                    });
                    $("#loginButton").removeAttr("disabled");
                  }  
                });
                return false;  
            });
        });
    </script>
</html>
