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
                            <a href="#" id="regPrompt"><p class="archer form details"><strong>New User? Click Here</strong></p> </a>
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
                    if (r == null) {
                        alertbox.html("Internal Server Error, please try again.");
                        alertbox.addClass("error");
                    }
                    else if (r.result === "error") {
                        alertbox.html(r.message);
                        alertbox.addClass("error");
                    } else {
                        alertbox.html("Logged in nicely! :)");
                        alertbox.addClass("success");
                    }
                    $("#loginResult").fadeOut(300, function() {
                        $("#loginResult").replaceWith(alertbox);
                        alertbox.fadeIn(400);
                        if (r.result === "OK") alertbox.delay(2000).fadeOut();
                    });
                    $("#loginButton").removeAttr("disabled");
                  }  
                });
                return false;  
            });
            $("#regPrompt").click(function() {
                var regForm = $("<form />").addClass("nice").attr("id","regForm").attr("action","#").attr("method","POST");
                var msg = $("<p />").addClass("archer").addClass("form").addClass("details").html("Please fill in all fields below:");
                var usernameF = $("<input />").addClass("input-text").attr("id","userID").attr("placeholder","Username").attr("type","text").attr("name","userID").attr("required","");
                var passwordF = $("<input />").addClass("input-text").attr("id","password").attr("placeholder","Password").attr("type","password").attr("name","password").attr("required","");
                var password2F = $("<input />").addClass("input-text").attr("id","password2").attr("placeholder","Confirm Password").attr("type","password").attr("name","password2").attr("required","");
                var nameF = $("<input />").addClass("input-text").attr("id","name").attr("placeholder","Name").attr("type","text").attr("name","name").attr("required","");
                var surnameF = $("<input />").addClass("input-text").attr("id","surname").attr("placeholder","Surname").attr("type","text").attr("name","surname").attr("required","");
                var emailF = $("<input />").addClass("input-text").attr("id","email").attr("placeholder","Email Address").attr("type","text").attr("name","email").attr("required","");
                var emailF2 = $("<input />").addClass("input-text").attr("id","email2").attr("placeholder","Confirm Email Address").attr("type","text").attr("name","email2").attr("required","");
                var regButton = $("<input />").addClass("nice radius blue button full-width").attr("id","loginButton").attr("type","submit").attr("value","Register");
                regForm.append(msg);
                regForm.append(usernameF).append(passwordF).append(password2F).append(nameF).append(surnameF).append(emailF).append(emailF2).append(regButton);
                $("#loginForm").fadeOut(400,function(){
                    $("#regPrompt").fadeOut(300,function(){$("#regPrompt").hide()})
                    $("#loginForm").replaceWith(regForm);
                    regForm.fadeIn(300);
                    $("#userID").focus();
                    $(window).scrollTop($(document).height());
                });
                
                
                return false;
            });
        });
    </script>
</html>
