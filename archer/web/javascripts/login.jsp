<%@page contentType="text/javascript" %>

(function($){
})(jQuery);

$(function() {
    $("#userID").focus();
    $("#logo").fadeIn(1000);
    $("#welcome").delay(1000).fadeIn(500);
    $("#loginForm").submit(function (){
        $("#loginButton").attr("disabled", "disabled");
        $.ajax({  
          type: "POST",  
          url: "<%= response.encodeURL("login") %>",  
          data: $(this).serialize(),  
          success: function(data) {
            var r = $.parseJSON(data);
            var alertbox = $("<div/>").addClass("alert-box centertext").attr("id","loginResult");
            alertbox.hide();
            if (r.result === "error") {
                alertbox.html(r.message);
                alertbox.addClass("error");
            }
            $("#loginResult").fadeOut(300, function() {
                if (r.result === "OK") window.location.replace("<%= response.encodeURL("dashboard") %>");
                else {
                    $("#loginResult").replaceWith(alertbox);
                    alertbox.fadeIn(400);
                }
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
        var uname = $("<input />").addClass("input-text").attr("id","newUserID").
            attr("placeholder","Username").attr("type","text").attr("name","newUserID").
            attr("required","required");
        var pass = $("<input />").addClass("input-text").attr("id","newPassword").
            attr("placeholder","Password").attr("type","password").
            attr("name","newPassword").attr("required","required");
        var pass2 = $("<input />").addClass("input-text").attr("id","passcheck").
            attr("placeholder","Confirm Password").attr("type","password").
            attr("name","passcheck").attr("required","");
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
        oldform = $("#loginForm");
        $(regForm).submit(registerNewUser);
        regForm.hide();
        $("#loginForm").fadeOut(400, function(){
            $("#regPrompt").hide();
            $("#loginForm").replaceWith(regForm);
            regForm.fadeIn(300);
            $("html, body").delay(100).animate({scrollTop: $("#regForm").offset().top}, 400);
        });
        $(uname).focus();

        $(uname).blur(function(){
                $.ajax({  
                  type: "POST",  
                  url: "<%= response.encodeURL("check") %>",  
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

        var isValid = false;
        $(pass).blur(function(){
            var label = $("<label />").attr("for","newPassword").attr("id","passLabel");
            var smallLabel = $("<small />").attr("id","passSmallLabel");
            if($(pass).val().length < 6){
                label.addClass("red").html("Invalid Password");
                smallLabel.addClass("error").html("Password must be at least 6 characters");
                isValid = false;
            }
            else{
                label.addClass("green").html("Valid Password");
                isValid = true;
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
            $("#pass2Label").fadeOut(200).remove();
            $("#pass2SmallLabel").fadeOut(200).remove();
        });

        $(pass2).blur(function(){
            if (isValid == true){
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
            }
        });

        $(pass2).focusin(function(){
            $("#pass2Label").fadeOut(200).remove();
            $("#pass2SmallLabel").fadeOut(200).remove();
        });

        var isValid2 = false;

        $(email).blur(function(){
            var label = $("<label />").attr("for","email").attr("id","emailLabel");
            var smallLabel = $("<small />").attr("id","emailSmallLabel");
            if(!isValidEmail($(email).val())){
                label.addClass("red").html("Invalid E-mail Format");
                smallLabel.addClass("error").html("E-mail must be something like : smthing@somewhere.com(or other)");
                isValid2 = false;
            }
            else{
                label.addClass("green").html("Valid E-mail");
                isValid2 = true;
            }
            label.hide();
            smallLabel.hide();
            if (!($(email).val() === "")) {
                email.before(label);
                email.after(smallLabel);
                label.fadeIn(300);
                smallLabel.fadeIn(300);
            }
        });

        $(email).focusin(function(){
            $("#emailLabel").fadeOut(200).remove();
            $("#emailSmallLabel").fadeOut(200).remove();
            $("#email2Label").fadeOut(200).remove();
            $("#email2SmallLabel").fadeOut(200).remove();
            return true;
        });

        $(email2).blur(function(){
            if (isValid2 == true){
            var label = $("<label />").attr("for","email2").attr("id","email2Label");
            var smallLabel = $("<small />").attr("id","email2SmallLabel");
            if($(email2).val() != $(email).val()){
                label.addClass("red").html("Invalid E-mail");
                smallLabel.addClass("error").html("E-mail fields do not match");
            }
            else{
                label.addClass("green").html("E-mail Confirmed");
            }
            label.hide();
            smallLabel.hide();
            email2.before(label);
            email2.after(smallLabel);
            label.fadeIn(300);
            smallLabel.fadeIn(300);
            }
        });

        $(email2).focusin(function(){
            $("#email2Label").fadeOut(200).remove();
            $("#email2SmallLabel").fadeOut(200).remove();
        });
    });
});

var registerNewUser = function() {
    $("#registerButton").attr("disabled", "disabled");
    $.ajax({  
      type: "POST",  
      url: "<%= response.encodeURL("register") %>",  
      data: $(this).serialize(),  
      success: function(data) {
        var r = $.parseJSON(data);
        var alertbox = $("<div/>").addClass("alert-box centertext").attr("id","registerResult");
        alertbox.hide();
        if (r.result === "error") {
            alertbox.html(r.message);
            alertbox.addClass("error");
        } else {
            alertbox.html("Registered nicely! We'll take you back to the login page automatically in 3 seconds.");
            alertbox.addClass("success");
        }
        $("#registerResult").fadeOut(300, function() {
            $("#registerResult").replaceWith(alertbox);
            alertbox.fadeIn(400);
            if (r.result === "OK") alertbox.delay(2000).fadeOut();
        });
        $("#registerButton").removeAttr("disabled");
        setTimeout(function(){
            $(location).attr("href","./index.jsp");
        },3000);
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
};
