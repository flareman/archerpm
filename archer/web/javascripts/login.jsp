<%@page contentType="text/javascript" %>

$(function() {
    // Event handlers for login form and register prompt
    $("#loginForm").submit(submitLoginForm);
    $("#regPrompt").click(displayRegForm);

    // Has-/NoText check binds for user ID field
    $('#userID').bind('hastext', function () {
        $('#loginButton').removeClass('disabled').removeAttr('disabled');
    });
    
    $('#userID').bind('notext', function () {
        $('#loginButton').addClass('disabled').attr('disabled', "disabled");
    });
});

$(window).load(function() {
    // Eye candy, to run after window is fully loaded
    $("#userID").focus();
    $("#logo").fadeIn(1000);
    $("#welcome").delay(1000).fadeIn(500);
});

var submitLoginForm = function (){
    $("#loginButton").attr("disabled", "disabled");
    $.ajax({  
      type: "POST",
      dataType: "json",
      url: "<%= response.encodeURL("login") %>",  
      data: $(this).serialize(),
      success: function(data) {
        var alertbox = $("<div/>").addClass("alert-box centertext").attr("id","loginResult");
        alertbox.hide();
        if (data.hasOwnProperty("error")) {
            alertbox.html(data.error);
            alertbox.addClass("error");
        }
        $("#loginResult").fadeOut(300, function() {
            if (data.hasOwnProperty("error")) {
                $("#loginResult").replaceWith(alertbox);
                alertbox.fadeIn(400);
            } else window.location.replace("<%= response.encodeURL("dashboard") %>");
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
}

var registerNewUser = function() {
    $("#registerButton").attr("disabled", "disabled");
    $.ajax({  
      type: "POST",  
      url: "<%= response.encodeURL("register") %>",  
      data: $(this).serialize(),
      dataType: "json",
      success: function(data) {
        var alertbox = $("<div/>").addClass("alert-box centertext").attr("id","registerResult");
        alertbox.hide();
        if (data.hasOwnProperty("error")) {
            alertbox.html(data.error);
            alertbox.addClass("error");
        } else {
            alertbox.html("Registered nicely! We'll take you back to the login page automatically in 3 seconds.");
            alertbox.addClass("success");
        }
        $("#registerResult").fadeOut(300, function() {
            $("#registerResult").replaceWith(alertbox);
            alertbox.fadeIn(400);
            if (data.hasOwnProperty("error") == false) alertbox.delay(2000).fadeOut();
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
        });
        $("#registerButton").removeAttr("disabled");
      }
    });
    return false;
};

function createRegForm() {
    // Create a new form for registration, along with all its elements
    var regForm = $("<form />").addClass("nice").attr("id","regForm").
        attr("action","#").attr("method","POST");
    var msg = $("<p />").addClass("archer details").
        html("Great! Please tell us a bit about yourself:");
    var regResult = $("<div />").attr("id","registerResult");
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
        attr("id","registerButton").attr("type","submit").attr("value","Sign Up").attr("disabled", "disabled");

    // Append all registration elements to the form
    regForm.append(msg).append(regResult).append(uname).append(pass).append(pass2).
        append(name).append(surname).append(email).append(email2).append(regButton);

    // Registration button enabler/disabler; uses CSS classes as flags
    var toggleRegButton = function() {
        if ((regForm.hasClass("emailValid")) && (regForm.hasClass("passValid")) && (regForm.hasClass("userIDValid")))
            regButton.removeClass('disabled').removeAttr('disabled');
        else regButton.addClass('disabled').attr('disabled', "disabled");
    }
    
    // Check mail/pass/username/etc functions, are bound on textchange, set/remove CSS classes as flags
    var timeout;
    var checkUserID = function(){
        regForm.removeClass("userIDValid");
        toggleRegButton();
        clearTimeout(timeout);
        if (uname.val() === "") {
            $(".userIDError").fadeOut(200);
            toggleRegButton();
            return;
        } else timeout = setTimeout(function(){
            $.ajax({  
                type: "POST",  
                url: "<%= response.encodeURL("check") %>",  
                data: regForm.serialize(),
                dataType: "json",
                success: function(data) {
                    var label = $("<label />").attr("for", "newUserID").addClass("userIDError");
                    if (data.hasOwnProperty("error")) {
                        label.html("The username is taken; choose another").addClass("red");
                        regForm.removeClass("userIDValid");
                    } else {
                        label.html("Username not taken").addClass("green");
                        regForm.addClass("userIDValid");
                    }
                    if ($(".userIDError").exists())
                        $(".userIDError").each(function(i) {
                            if (i > 0) $(this).fadeOut(200, function() { $(this).remove() });
                            else $(this).replaceWith(label).remove();
                        });
                    else label.hide().insertBefore(uname).fadeIn(300);
                    toggleRegButton();
                },
                error: function(xhr, ajaxOptions, thrownError) {
                    regForm.removeClass("userIDValid");
                    toggleRegButton();
                    var alertbox = $("<div/>").addClass("alert-box centertext warning").attr("id","registerResult");
                    alertbox.html("Whoops, an error occured :( Please try again in a bit.").hide();
                    $("#registerResult").fadeOut(300, function() {
                        $("#registerResult").replaceWith(alertbox);
                        alertbox.fadeIn(400);
                    });
                }
            });
        }, 700);
    }
    uname.bind('textchange', checkUserID);
    
    var checkMail = function(){
        if (email.val() === "") {
            $("#emailError").fadeOut(200, function(){ $(this).remove(); });
            $("#email2Error").fadeOut(200, function(){ $(this).remove(); });
            regForm.removeClass("emailValid");
            toggleRegButton();
            return;
        }
        
        var label = $("<label />").addClass("red");
        if (isValidEmail(email.val())) {
            $("#emailError").fadeOut(200, function(){ $(this).remove(); });
            if (email.val() == email2.val()) {
                isValid = true;
                $("#email2Error").fadeOut(200, function(){ $(this).remove(); });
            } else {
                isValid = false;
                if (email2.val() !== "") {
                    label.html("Emails must match").attr("for", "email2").attr("id", "email2Error");
                    var oldEmail2Error = $("#email2Error");
                    if (oldEmail2Error.exists()) oldEmail2Error.replaceWith(label).remove();
                    else label.hide().insertBefore(email2).fadeIn(300);
                }
            }
        } else {
            $("#email2Error").fadeOut(200, function(){ $(this).remove(); });
            isValid = false;
            label.html("You've mistyped the email address").attr("for", "email").attr("id", "emailError");
            var oldEmailError = $("#emailError");
            if (oldEmailError.exists()) oldEmailError.replaceWith(label).remove();
            else label.hide().insertBefore(email).fadeIn(300);
        }
        if (isValid)
            regForm.addClass("emailValid");
        else regForm.removeClass("emailValid");
        toggleRegButton();
    }
    email.bind('textchange', checkMail);
    email2.bind('textchange', checkMail);
    
    var checkPass = function(){
        if (pass.val() === "") {
            $("#passError").fadeOut(200, function(){ $(this).remove(); });
            $("#pass2Error").fadeOut(200, function(){ $(this).remove(); });
            regForm.removeClass("passValid");
            toggleRegButton();
            return;
        }
        
        var label = $("<label />").addClass("red");
        if (pass.val().length >= 6) {
            $("#passError").fadeOut(200, function(){ $(this).remove(); });
            if (pass.val() == pass2.val()) {
                isValid = true;
                $("#pass2Error").fadeOut(200, function(){ $(this).remove(); });
            } else {
                isValid = false;
                if (pass2.val() !== "") {
                    label.html("Passwords must match").attr("for", "pass2").attr("id", "pass2Error");
                    var oldPass2Error = $("#pass2Error");
                    if (oldPass2Error.exists()) oldPass2Error.replaceWith(label).remove();
                    else label.hide().insertBefore(pass2).fadeIn(300);
                }
            }
        } else {
            $("#pass2Error").fadeOut(200, function(){ $(this).remove(); });
            isValid = false;
            label.html("Your password must be at least 6 characters long").attr("for", "pass").attr("id", "passError");
            var oldPassError = $("#passError");
            if (oldPassError.exists()) oldPassError.replaceWith(label).remove();
            else label.hide().insertBefore(pass).fadeIn(300);
        }
        if (isValid)
            regForm.addClass("passValid");
        else regForm.removeClass("passValid");
        toggleRegButton();
    }
    pass.bind('textchange', checkPass);
    pass2.bind('textchange', checkPass);
    
    // Finally, set the submit handler, hide the form and return it for usage
    $(regForm).submit(registerNewUser);
    regForm.hide();
    return regForm;
}

var displayRegForm = function(e) {
    e.preventDefault();
    $("#loginForm").fadeOut(400, function(){
        $("#regPrompt").hide();
        var oldForm = $("#loginForm").replaceWith(createRegForm());
        $("#regForm").fadeIn(300);
        $("html, body").delay(100).animate({scrollTop: $("#regForm").offset().top}, 400);
    });
}