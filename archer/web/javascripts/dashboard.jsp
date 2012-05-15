<%@page contentType="text/javascript" %>

$(function() {
    prepareSettings();
    prepareTest();
});

$(window).load(function() {
});

var prepareTest = function() {
    $('#testGson').click(function(e) {
        e.preventDefault();
        $('#result').html("");
        $.ajax({  
        type: "POST",
        url: "<%= response.encodeURL("dashboard/userlist") %>",
        dataType: "json",
        success: function(data) {
            if (data.hasOwnProperty("error"))
                $('#result').html(data.error);
            else $.each(data, function(i, user) {
                $('#result').append(i+": "+user.username);
            });
        },
        error: function(xhr, ajaxOptions, thrownError) {
            $('#result').html(thrownError);
        }
        });
        return false;
    });
}

var prepareSettings = function() {
    $('#gear').hover(function() { $('.top.settings').addClass("hover"); },
    function() {
        if ($("#settings-menu").is(":visible") == false)
            $('.top.settings.hover').removeClass("hover");
    });
    $('#gear').click(function(e) {
        e.preventDefault();
        $("#settings-menu").fadeToggle(100);
        $("#gear").toggleClass("hover");
    });
    $('#settings-menu').click(function(e) { e.preventDefault(); });
    $("#settings-menu").mouseup(function() { return false });
    $(document).mouseup(function(e) {
        if($(e.target).is("#gear") == false) {
            $("#settings-menu").fadeOut(100);
            $(".top.settings.hover").removeClass("hover");
        }
    });
    $("#logout").click(function(e) {
        e.preventDefault();
        window.location.replace("<%= response.encodeURL("dashboard/logout") %>");
    });
}