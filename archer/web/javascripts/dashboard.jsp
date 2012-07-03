<%@page contentType="text/javascript" %>
<%
    String base = request.getContextPath();
    String type = "";
    String value = "";
    if (request.getParameter("path") != null) {
        String[] pathInfo = request.getParameter("path").split("/");
        if (pathInfo.length == 3) {
            type = pathInfo[1];
            if (type.equals("project") || type.equals("task") || type.equals("user")) {
                type = pathInfo[1];
                value = pathInfo[2];
            } else type = "";
        }
    }
%>

$(function() {
    preparePage();
    <%= (type.equals("project")?"viewProject(null, '"+value+"');":"") %>
    <%= (type.equals("task")?"viewProject(null, '"+value+"');":"") %>
    <%= (type.equals("user")?"viewProject(null, '"+value+"');":"") %>
    <%= (type.equals("")?"viewLanding()":"") %>
    prepareGetComments();
});

var prepareGetComments = function() {
    $('#getComments1').click(function(e) {
        e.preventDefault();
        $.ajax({  
        type: "POST",
        url: "<%= response.encodeURL(base+"/dashboard/comments") %>",
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
}

var preparePage = function() {
    $("#logout").click(function(e) {
        e.preventDefault();
        window.location.replace("<%= response.encodeURL(base+"/dashboard/logout") %>");
    });
    $("#home").click(function(e) {
        e.preventDefault();
        viewLanding();
    });
    $(".logo").click(function(e) {
        e.preventDefault();
        viewLanding();
    });
    loadSideNav();
}

var loadSideNav = function() {
    $('#myprojects').append('<li class="disabled projectindicator">Loading...</li>');
    $('#publicprojects').append('<li class="disabled projectindicator">Loading...</li>');
    loadProject(function(data) {
        var mine = 0;
        var public = 0;
        $('.projectindicator').remove();
        $.each(data, function(i, project) {
            var plink = $("<li/>").append($('<a/>').addClass("projectlink").attr("href","#").attr("id",project.id).html(project.title).click(viewProject));
            if (!project.isPublic) {
                if (mine > 9) { mine = -1; return }
                mine++;
                $('#myprojects').append(plink);
            } else {
                if (public > 9) { public = -1; return }
                public++;
                $('#publicprojects').append(plink);
            }
        });
        if (mine === 0) $('#myprojects').append('<li class="disabled">No Projects</li>');
        if (public === 0) $('#publicprojects').append('<li class="disabled">No Projects</li>');
        if (mine === -1) $('#myprojects').append('<li><a href="#" class="moreprojects" id="mine">All my projects...</a></li>');
        if (public === -1) $('#publicprojects').append('<li><a href="#" class="moreprojects" id="public">All public projects...</a></li>');
        $('.moreprojects').click(viewAllProjects);
    },
    "all");
}

var viewProject = function(e, projectID) {
    if (e != null) {
        e.preventDefault();
        projectID = e.target.id;
        $('li a#'+projectID+'.projectlink').append(' <span class="loader" id="loader'+e.target.id+'"></span>');
    }
    loadProject(function(project){
        $('#content').html('\
            <div class="row">\
                <div class="two columns"><a href="#" class="radius secondary button" id="back">Back</a></div>\
                <div class="eight columns"><h3 id="title"> <span class="radius label" id="publicstatus"></span></h3></div>\
                <div class="two column"><a href="#" class="radius button" id="edit">Edit</a></div>\
            </div>\
            <div class="row">\
                <div class="two columns"></div>\
                <div class="eight columns"><h4 class="subheader" id="description"></h4></div>\
                <div class="two column"></div>\
            </div>\
            <h5 class="subheader" id="manager">Managed by <span class="disabled managerindicator">&hellip;</span></h5>\
            <h6 class="subheader" id="workers"><span class="disabled workersindicator">Loading...</span></h6>\
            <hr/>\
            <dl class="tabs pill" id="taskfilter">\
            <dd class="active" id="alltasks"><a href="#">All Tasks</a></dd>\
            <dd id="pendingtasks"><a href="#">Pending</a></dd>\
            <dd id="completetasks"><a href="#">Complete</a></dd>\
            </dl>\
            <ul class="dash" id="tasklist"><li class="disabled taskindicator">Loading...</li>\
            </ul>');
        $('#title').prepend(project.title);
        $('#publicstatus').prepend((project.isPublic)?"Public":"Private");
        $('#description').prepend(project.description);
        $('#pendingtasks').click(function(e) {
            e.preventDefault();
            $('#alltasks').removeClass("active");
            $('#completetasks').removeClass("active");
            $('#pendingtasks').addClass("active");
            $('#tasklist li.done').hide();
            $('#tasklist li.pending').show();
            return false;
        });
        $('#completetasks').click(function(e) {
            e.preventDefault();
            $('#alltasks').removeClass("active");
            $('#pendingtasks').removeClass("active");
            $('#completetasks').addClass("active");
            $('#tasklist li.done').show();
            $('#tasklist li.pending').hide();
            return false;
        });
        $('#alltasks').click(function(e) {
            e.preventDefault();
            $('#pendingtasks').removeClass("active");
            $('#completetasks').removeClass("active");
            $('#alltasks').addClass("active");
            $('#tasklist li.done').show();
            $('#tasklist li.pending').show();
            return false;
        });
        loadTask(function(data){
            $('.taskindicator').remove();
            $.each(data, function(i, task) {
                var tlink = $('<a href="#" class="tasklink"/>').attr("id", task.id).click(viewTask);
                tlink.append($('<li/>').addClass((task.completed)?"done":"pending").html(task.title));
                $('#tasklist').append(tlink);
            });
        }, "project", project.id);
        loadUser(function(data){
            $('.workersindicator').remove();
            $('#workers').append("There");
            switch (data.length) {
                case 0: $('#workers').append(" are no employees"); break;
                case 1: $('#workers').append(' is <a href="#" class="workerlink">one employee</a>'); break;
                default: $('#workers').append(' are <a href="#" class="workerlink">'+data.length+' employees</a>'); break;
            }
            $('#workers').append(" assigned to this project.");
            $('.workerlink').attr("id",project.id).click(viewProjectUsers);
        }, "project", project.id);
        loadUser(function(user){
            $('.managerindicator').remove();
            $('#manager').append($('<a class="managerlink" href="#"/>').attr("id", user.username).html(user.name+' '+user.surname).click(viewUser));
        }, "user", project.manager);
        $('span#loader'+project.id).remove();
    }, "project", projectID);
    return false;
}

var viewTask = function(e) {
    if (e != null) e.preventDefault();
    alert(e.target.parentElement.id);
    return false;
}

var viewUser = function(e) {
    if (e != null) e.preventDefault();
    alert(e.target.id);
    return false;
}

var viewProjectUsers = function(e) {
    if (e != null) e.preventDefault();
    alert(e.target.id);
    return false;
}

var viewLanding = function(e) {
    if (e != null) e.preventDefault();
    $('#content').html('<h3>Great! <small>No work today :-)</small></h3>');
    return false;
}

var viewAllProjects = function(e) {
    if (e != null) e.preventDefault();
    var type = event.target.id;
    loadProject(function(data) {
        $('#content').html('<ul class="disc" id="projectlist"></ul>');
        $.each(data, function(i, project) {
            var plink = $("<li/>").append($('<a/>').addClass("projectlink").attr("href","#").attr("id",project.id).html(project.title));
            plink.click(viewProject);
            if ((project.isPublic && type === "public") || (!project.isPublic && type === "mine")) {
                $('#projectlist').append(plink);
            }
        });
    },
    "all");
    return false;
}

var loadProject = function(implement, kind, value, startFrom, count) {
    $.ajax({  
    type: "POST",
    url: "<%= response.encodeURL(base+"/dashboard/projects") %>",
    data: {"kind": kind, "value": value, "startFrom": startFrom, "count": count},
    dataType: "json",
    success: function(data) {
        if (data.hasOwnProperty("error"))
            $('#content').html('<div class="alert-box alert radius">'+data.error+'</div>');
        else implement(data);
    },
    error: function(xhr, ajaxOptions, thrownError) {
        $('#content').html('<div class="alert-box alert radius">'+data.error+'</div>');
    }
    });
}

var loadTask = function(implement, kind, value) {
    $.ajax({  
    type: "POST",
    url: "<%= response.encodeURL(base+"/dashboard/tasks") %>",
    data: {"kind": kind, "value": value},
    dataType: "json",
    success: function(data) {
        if (data.hasOwnProperty("error"))
            $('#content').html('<div class="alert-box alert radius">'+data.error+'</div>');
        else implement(data);
    },
    error: function(xhr, ajaxOptions, thrownError) {
        $('#content').html('<div class="alert-box alert radius">'+data.error+'</div>');
    }
    });
}

var loadUser = function(implement, kind, value) {
    $.ajax({  
    type: "POST",
    url: "<%= response.encodeURL(base+"/dashboard/users") %>",
    data: {"kind": kind, "value": value},
    dataType: "json",
    success: function(data) {
        if (data.hasOwnProperty("error"))
            $('#content').html('<div class="alert-box alert radius">'+data.error+'</div>');
        else implement(data);
    },
    error: function(xhr, ajaxOptions, thrownError) {
        $('#content').html('<div class="alert-box alert radius">'+data.error+'</div>');
    }
    });
}
