//email format validator
var IsValidEmail = function (email){
                var filter = /^([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/;
                return filter.test(email);
            }
            
//Handler for login form submission            
var SubmitLogin = function (){
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
            }

//handler for register form submission
var SubmitRegister = function(){
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
                }

//username focus out event handler for registration form
var UnameFocusOut = function(){
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
            }
