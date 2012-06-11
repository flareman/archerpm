<%@page contentType="text/javascript" %>

$(function() {
    prepareSettings();
    prepareGetUsers();
    prepareGetProjects();
    prepareGetTasks();
    prepareGetComments();
});

$(window).load(function() {
});

var prepareGetUsers = function() {
    $('#getUsers').click(function(e) {
        e.preventDefault();
        $.ajax({  
        type: "POST",
        url: "<%= response.encodeURL("dashboard/users") %>",
        data: {"kind": "all"},
        dataType: "json",
        success: function(data) {
            if (data.hasOwnProperty("error"))
                $('#result').html(data.error);
            else {
                $('#result').html('<table><thead><tr><th>#</th><th>User Name</th><th>First Name</th><th>Last Name</th><th>E-mail Address</th></tr></thead><tbody id="resultsBody"></tbody></table>');
                $.each(data, function(i, user) {
                    $('#resultsBody').append("<tr>"+"<td>"+(i+1)+"</td><td>"+user.username+"</td><td>"+user.name+"</td><td>"+user.surname+"</td><td>"+user.email+"</td></tr>");
                });
            }
        },
        error: function(xhr, ajaxOptions, thrownError) {
            $('#result').html(thrownError);
        }
        });
        return false;
    });
}

var prepareGetProjects = function() {
    $('#getProjects').click(function(e) {
        e.preventDefault();
        $.ajax({  
        type: "POST",
        url: "<%= response.encodeURL("dashboard/projects") %>",
        data: {"kind": "all"},
        dataType: "json",
        success: function(data) {
            if (data.hasOwnProperty("error"))
                $('#result').html(data.error);
            else {
                $('#result').html('<table><thead><tr><th>#</th><th>Project ID</th><th>Title</th><th>Manager</th><th>Start Date</th><th>Duration</th></tr></thead><tbody id="resultsBody"></tbody></table>');
                $.each(data, function(i, project) {
                    $('#resultsBody').append("<tr>"+"<td>"+(i+1)+"</td><td>"+project.id+"</td><td>"+project.title+"</td><td>"+project.manager+"</td><td>"+project.startDate+"</td><td>"+project.duration+"</td></tr>");
                });
            }
        },
        error: function(xhr, ajaxOptions, thrownError) {
            $('#result').html(thrownError);
        }
        });
        return false;
    });
}

var prepareGetTasks = function() {
    $('#getTasks').click(function(e) {
        e.preventDefault();
        $.ajax({  
        type: "POST",
        url: "<%= response.encodeURL("dashboard/tasks") %>",
        data: {"kind": "all"},
        dataType: "json",
        success: function(data) {
            if (data.hasOwnProperty("error"))
                $('#result').html(data.error);
            else {
                $('#result').html('<table><thead><tr><th>#</th><th>Task ID</th><th>Title</th><th>Priority</th><th>Start Date</th><th>Duration</th><th>Completed</th></tr></thead><tbody id="resultsBody"></tbody></table>');
                $.each(data, function(i, task) {
                    $('#resultsBody').append("<tr>"+"<td>"+(i+1)+"</td><td>"+task.id+"</td><td>"+task.title+"</td><td>"+task.priority+"</td><td>"+task.startDate+"</td><td>"+task.duration+"</td><td>"+task.completed+"</td></tr>");
                });
            }
        },
        error: function(xhr, ajaxOptions, thrownError) {
            $('#result').html(thrownError);
        }
        });
        return false;
    });
}

var prepareGetComments = function() {
    $('#getComments1').click(function(e) {
        e.preventDefault();
        $.ajax({  
        type: "POST",
        url: "<%= response.encodeURL("dashboard/comments") %>",
        data: {"task": "1"},
        dataType: "json",
        success: function(data) {
            if (data.hasOwnProperty("error"))
                $('#result').html(data.error);
            else {
                $('#result').html('<table><thead><tr><th>#</th><th>Comment ID</th><th>Content</th><th>User</th><th>Date/Time</th><th>Task</th></tr></thead><tbody id="resultsBody"></tbody></table>');
                $.each(data, function(i, comment) {
                    $('#resultsBody').append("<tr>"+"<td>"+(i+1)+"</td><td>"+comment.id+"</td><td>"+comment.content+"</td><td>"+comment.username+"</td><td>"+comment.timestamp+"</td><td>"+comment.task+"</td></tr>");
                });
            }
        },
        error: function(xhr, ajaxOptions, thrownError) {
            $('#result').html(thrownError);
        }
        });
        return false;
    });

    $('#getComments2').click(function(e) {
        e.preventDefault();
        $.ajax({  
        type: "POST",
        url: "<%= response.encodeURL("dashboard/comments") %>",
        data: {"task": "2"},
        dataType: "json",
        success: function(data) {
            if (data.hasOwnProperty("error"))
                $('#result').html(data.error);
            else {
                $('#result').html('<table><thead><tr><th>#</th><th>Comment ID</th><th>Content</th><th>User</th><th>Date/Time</th><th>Task</th></tr></thead><tbody id="resultsBody"></tbody></table>');
                $.each(data, function(i, comment) {
                    $('#resultsBody').append("<tr>"+"<td>"+(i+1)+"</td><td>"+comment.id+"</td><td>"+comment.content+"</td><td>"+comment.username+"</td><td>"+comment.timestamp+"</td><td>"+comment.task+"</td></tr>");
                });
            }
        },
        error: function(xhr, ajaxOptions, thrownError) {
            $('#result').html(thrownError);
        }
        });
        return false;
    });

    $('#getComments3').click(function(e) {
        e.preventDefault();
        $.ajax({  
        type: "POST",
        url: "<%= response.encodeURL("dashboard/comments") %>",
        data: {"task": "3"},
        dataType: "json",
        success: function(data) {
            if (data.hasOwnProperty("error"))
                $('#result').html(data.error);
            else {
                $('#result').html('<table><thead><tr><th>#</th><th>Comment ID</th><th>Content</th><th>User</th><th>Date/Time</th><th>Task</th></tr></thead><tbody id="resultsBody"></tbody></table>');
                $.each(data, function(i, comment) {
                    $('#resultsBody').append("<tr>"+"<td>"+(i+1)+"</td><td>"+comment.id+"</td><td>"+comment.content+"</td><td>"+comment.username+"</td><td>"+comment.timestamp+"</td><td>"+comment.task+"</td></tr>");
                });
            }
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