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
                                <p class="archer details">Please enter your login info to start:</p>
                                <div id="loginResult"></div>
                                <input id="userID" class="input-text" required placeholder="Username" type="text" name="userID" /> 
                                <input id="password" class="input-text" required placeholder="Password" type="password" name="password" />
                                <input id="loginButton" type="submit" value="Login" class="nice radius blue button full-width"></input>
                            </form>
                            <a href="#" id="regPrompt"><p class="archer form details">New User? Click Here</p></a>
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
            var uname = $("<input />").addClass("input-text").attr("id","newUserID").
                    attr("placeholder","Username").attr("type","text").attr("name","newUserID").
                    attr("required","required");
            var pass = $("<input />").addClass("input-text").attr("id","newPassword").
                    attr("placeholder","Password").attr("type","password").
                    attr("name","newPassword").attr("required","required");
            var pass2 = $("<input />").addClass("input-text").attr("id","passcheck").
                    attr("placeholder","Confirm Password").attr("type","password").
                    attr("name","passcheck").attr("required","");
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
                        alertbox.fadeIn(400);
                        if (r.result === "OK") alertbox.delay(2000).fadeOut();
                    });
                    $("#loginButton").removeAttr("disabled");
                  },
                  error: function(xhr, ajaxOptions, thrownError) {
                    var alertbox = $("<div/>").addClass("alert-box centertext").attr("id","loginResult");
                    alertbox.hide();
                    alertbox.html("Whoops, an error occured :( Please try again in a bit.");
                    alertbox.addClass("warning");
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
                var regForm = $("<form />").addClass("nice").attr("id","regForm").
                    attr("action","#").attr("method","POST");
                var msg = $("<p />").addClass("archer details").
                    html("Great! Please tell us a bit about yourself:");
                var regresult = $("<div/>").attr("id","registerResult");
//                var uname = $("<input />").addClass("input-text").attr("id","newUserID").
//                    attr("placeholder","Username").attr("type","text").attr("name","newUserID").
//                    attr("required","required");
//                var pass = $("<input />").addClass("input-text").attr("id","newPassword").
//                    attr("placeholder","Password").attr("type","password").
//                    attr("name","newPassword").attr("required","required");
//                var pass2 = $("<input />").addClass("input-text").attr("id","passcheck").
//                    attr("placeholder","Confirm Password").attr("type","password").
//                    attr("name","passcheck").attr("required","");
                var name = $("<input />").addClass("input-text").attr("id","name").
                    attr("placeholder","Name").attr("type","text").attr("name","name").
                    attr("required","required");
                var surname = $("<input />").addClass("input-text").attr("id","surname").
                    attr("placeholder","Surname").attr("type","text").attr("name","surname").
                    attr("required","required");
                var email = $("<input />").addClass("input-text").attr("id","email").
                    attr("placeholder","Email Address").attr("type","text").attr("name","email").
                    attr("required","required");
                var email2 = $("<input />").addClass("input-text").attr("id","email2").
                    attr("placeholder","Confirm Email Address").attr("type","text").
                    attr("name","email2").attr("required","required");
                var regButton = $("<input />").addClass("nice radius blue button full-width").
                    attr("id","registerButton").attr("type","submit").attr("value","Sign Up");
                regForm.append(msg).append(regresult).append(uname).append(pass).append(pass2).
                    append(name).append(surname).append(email).append(email2).append(regButton);
                $(regForm).submit(function() {
                    $("#registerButton").attr("disabled", "disabled");
                    $.ajax({  
                      type: "POST",  
                      url: "register",  
                      data: $(this).serialize(),  
                      success: function(data) {
                        var r = $.parseJSON(data);
                        var alertbox = $("<div/>").addClass("alert-box centertext").attr("id","registerResult");
                        alertbox.hide();
                        if (r.result === "error") {
                            alertbox.html(r.message);
                            alertbox.addClass("error");
                        } else {
                            alertbox.html("Registered nicely! :)");
                            alertbox.addClass("success");
                        }
                        $("#registerResult").fadeOut(300, function() {
                            $("#registerResult").replaceWith(alertbox);
                            alertbox.fadeIn(400);
                            if (r.result === "OK") alertbox.delay(2000).fadeOut();
                        });
                        $("#registerButton").removeAttr("disabled");
                      },
                      error: function(xhr, ajaxOptions, thrownError) {
                        var alertbox = $("<div/>").addClass("alert-box centertext").attr("id","registerResult");
                        alertbox.hide();
                        alertbox.html("Whoops, an error occured :( Please try again in a bit.");
                        alertbox.addClass("warning");
                        $("#registerResult").fadeOut(300, function() {
                            $("#registerResult").replaceWith(alertbox);
                            alertbox.fadeIn(400);
                            if (r.result === "OK") alertbox.delay(2000).fadeOut();
                        });
                        $("#registerButton").removeAttr("disabled");
                      }
                    });
                    return false;  
                });
                regForm.hide();
                $("#loginForm").fadeOut(400, function(){
                    $("#regPrompt").hide();
                    $("#loginForm").replaceWith(regForm);
                    regForm.fadeIn(300);
                    $("html, body").delay(100).animate({scrollTop: $("#regForm").offset().top}, 400);
                });
                $(uname).focus();});
                //username field swap check here
                $(uname).focusout(function(){
                    $.ajax({  
                      type: "POST",  
                      url: "check",  
                      data: $(this).serialize(),  
                      success: function(data) {
                        var r = $.parseJSON(data);
                        var label = $("<label />").attr("for","newUserID").attr("id","unameLabel");
                        var smallLabel = $("<small />").attr("id","unameSmallLabel");
                        if (r.result === "error") {
                            label.addClass("red").html("Invalid Username");
                            smallLabel.addClass("error").html(r.message);
                        } 
                        else if($(uname).val() === ""){
                            label.addClass("red").html("Invalid Username");
                            smallLabel.addClass("error").html("You must provide a username");
                        }
                        else {
                            label.addClass("green").html("Valid Username");
                           
                        }
                        label.hide();
                        smallLabel.hide();
                        uname.before(label);
                        uname.after(smallLabel);
                        label.fadeIn(300);
                        smallLabel.fadeIn(300);
                       
                      },
                      error: function(xhr, ajaxOptions, thrownError) {
                          var alertbox = $("<div/>").addClass("alert-box centertext").attr("id","registerResult");
                        alertbox.hide();
                        alertbox.html("Whoops, an error occured :( Please try again in a bit.");
                        alertbox.addClass("warning");
                        $("#registerResult").fadeOut(300, function() {
                            $("#registerResult").replaceWith(alertbox);
                            alertbox.fadeIn(400);
                            if (r.result === "OK") alertbox.delay(2000).fadeOut();
                        });
                      }
                   });
                return false;
            });
            
            $(uname).focusin(function(){
                $("#unameLabel").fadeOut(200).remove();
                $("#unameSmallLabel").fadeOut(200).remove();
            });
            
            $(pass).focusout(function(){
                var label = $("<label />").attr("for","newPassword").attr("id","passLabel");
                var smallLabel = $("<small />").attr("id","passSmallLabel");
                if($(pass).val().length < 6){
                    label.addClass("red").html("Invalid Password");
                    smallLabel.addClass("error").html("Password must be at least 6 characters");
                }
                else{
                    label.addClass("green").html("Valid Password");
                }
                label.hide();
                smallLabel.hide();
                pass.before(label);
                pass.after(smallLabel);
                label.fadeIn(300);
                smallLabel.fadeIn(300);
            });
            
            $(pass).focusin(function(){
                $("#passLabel").fadeOut(200).remove();
                $("#passSmallLabel").fadeOut(200).remove();
            });
            
            $(pass2).focusout(function(){
                var label = $("<label />").attr("for","passcheck").attr("id","pass2Label");
                var smallLabel = $("<small />").attr("id","pass2SmallLabel");
                if($(pass2).val() != $(pass).val()){
                    label.addClass("red").html("Invalid Password");
                    smallLabel.addClass("error").html("Password fields do not match");
                }
                else{
                    label.addClass("green").html("Password Confirmed");
                }
                label.hide();
                smallLabel.hide();
                pass2.before(label);
                pass2.after(smallLabel);
                label.fadeIn(300);
                smallLabel.fadeIn(300);
            });
            
            $(pass2).focusin(function(){
                $("#pass2Label").fadeOut(200).remove();
                $("#pass2SmallLabel").fadeOut(200).remove();
            });
            
            
        });
    </script>
</html>
