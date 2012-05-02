//handler for register form submission
function SubmitRegister() {
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
