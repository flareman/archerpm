<%@page contentType="text/javascript" %>

$(function() {
    prepareSettings();
});

$(window).load(function() {
});

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