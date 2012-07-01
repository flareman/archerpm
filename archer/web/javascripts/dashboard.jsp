<%@page contentType="text/javascript" %>

$(function() {
    preparePage();
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

var preparePage = function() {
    $("#logout").click(function(e) {
        e.preventDefault();
        window.location.replace("<%= response.encodeURL("dashboard/logout") %>");
    });
    loadUserProjects();
}

var loadUserProjects = function() {
    $.ajax({  
    type: "POST",
    url: "<%= response.encodeURL("dashboard/projects") %>",
    data: {"kind": "all"},
    dataType: "json",
    success: function(data) {
        if (data.hasOwnProperty("error"))
            $('<div/>').addClass('reveal-modal').html('<h2>Whoops!</h2><p>'+data.error+'</p><a class="close-reveal-modal">&#215;</a>').appendTo($('#modals')).reveal();
        else {
            var mine = 0;
            var public = 0;
            $.each(data, function(i, project) {
                var plink = $("<li/>").append($('<a/>').addClass("projectlink").attr("href","#").attr("id",project.id).html(project.title).click(loadProject));
                if (!project.isPublic) {
                    if (mine > 0) return;
                    mine++;
                    $('#myprojects').append(plink);
                } else {
                    if (public > 9) return;
                    public++;
                    $('#publicprojects').append(plink);
                }
            });
            if (mine === 0) $('#myprojects').append('<li class="disabled">No Projects</li>');
            if (public === 0) $('#publicprojects').append('<li class="disabled">No Projects</li>');
            if (mine > 0) $('#myprojects').append('<li><a href="#" class="moreprojects" id="mine">More of My Projects...</a></li>');
            if (public > 9) $('#publicprojects').append('<li><a href="#" class="moreprojects" id="public">More Public Projects...</a></li>');
            $('a.moreprojects').click(loadMoreProjects);
        }
    },
    error: function(xhr, ajaxOptions, thrownError) {
        $('<div/>').addClass('reveal-modal').html('<h2>Whoops!</h2><p>'+thrownError+'</p><a class="close-reveal-modal">&#215;</a>').appendTo($('#modals')).reveal();
    }
    });
}

var loadProject = function(e) {
    e.preventDefault();
    alert("Project with ID: "+event.target.id+" clicked; load project placeholder!");
    return false;
}

var loadMoreProjects = function(e) {
    e.preventDefault();
    alert(event.target.id);
    return false;
}
