<%@page contentType="text/javascript" %>
<% String base = request.getContextPath(); %>

$(function() {
    preparePage();
});

var view404 = function () { window.location.replace("<%= response.encodeURL(base+"/notfound.jsp") %>"); }
var preparePage = function() {
    $("#logout").click(function(e) {
        e.preventDefault();
        window.location.replace("<%= response.encodeURL(base+"/dashboard/logout") %>");
        return false;
    });
    $("a.home").address();
    loadSideNav();
    $.address.strict(false);
    $.address.init(function(event) {
    }).change(function(event) {
        if (typeof window.isInternal != 'undefined')
            handleAddressEvent(event, true);
        else {
            window.isInternal = true;
            handleAddressEvent(event, false);
        }
    });
}

var handleAddressEvent = function (event, allowBack) {
    if (event.pathNames.length == 0) viewLanding();
    else if (event.pathNames.length == 1) {
        switch (event.pathNames[0]) {
            case "mine": viewAllProjects(event.pathNames[0], allowBack); break;
            case "public": viewAllProjects(event.pathNames[0], allowBack); break;
            default: view404(); break;
        }
    } else if (event.pathNames.length == 2) {
        switch (event.pathNames[0]) {
            case "project": viewProject(event.pathNames[1], allowBack); break;
            case "task": viewTask(event.pathNames[1], allowBack); break;
            case "user": viewUser(event.pathNames[1], allowBack); break;
            default: view404(); break;
        }
    } else if (event.pathNames.length == 3) {
        switch (event.pathNames[0]) {
            default: view404(); break;
        }
    } else view404();
}

var loadSideNav = function() {
    $('.side-nav.projects').html('');
    $('.side-nav.projects').append('<li><h6>Projects</h6></li><li class="disabled projectindicator">Loading&hellip; <span class="loader"></span></li><li class="divider"></li>');
    loadProject(function(data) {
        var mine = 0;
        var public = 0;
        $('.projectindicator').remove();
        $('.side-nav.projects').html('<li><h6>My Projects</h6></li>\
            <li class="divider" id="end-myprojects"></li>\
            <li><h6>Public Projects</h6></li>\
            <li class="divider" id="end-publicprojects"></li>');
        $.each(data, function(i, project) {
            var plink = $("<li/>").append($('<a/>').addClass("projectlink").attr("id","project"+project.id).attr("href","#/project/"+project.id).html(project.title).address());
            if (!project.isPublic) {
                if (mine > 9) { mine = -1; return }
                mine++;
                $('#end-myprojects').before(plink);
            } else {
                if (public > 9) { public = -1; return }
                public++;
                $('#end-publicprojects').append(plink);
            }
        });
        if (mine === 0) $('#end-myprojects').before('<li class="disabled">None</li>');
        if (public === 0) $('#end-publicprojects').before('<li class="disabled">None</li>');
        if (mine === -1) $('#end-myprojects').before('<li><a href="#/mine" class="moreprojects" id="mine">All my projects&hellip;</a></li>');
        if (public === -1) $('#end-publicprojects').before('<li><a href="#/public" class="moreprojects" id="public">All public projects&hellip;</a></li>');
        $('.moreprojects').address();
    },
    "all");
}

var viewProject = function(projectID, allowBack) {
    $('#content').html('<h3 class="subheader">Loading&hellip;</h3><span class="loader"></span>');
    loadProject(function(project){
        var content = $('<div class="panel radius" id="content"/>').html('\
            <div class="row">'+((allowBack)?'\
                <div class="two columns"><a href="#" class="radius secondary button" id="back">Back</a></div>\
                <div class="eight columns"><h3 id="title"> <span class="radius label" id="publicstatus"></span></h3></div>':'\
                <div class="ten columns"><h3 id="title"> <span class="radius label" id="publicstatus"></span></h3></div>')+'\
                <div class="two column"><a href="#" class="radius button" id="edit">Edit</a></div>\
            </div>\
            <div class="row">\
                '+((allowBack)?'<div class="two columns"></div>\
                <div class="eight columns">':'<div class="ten columns">')+'<h4 class="subheader" id="description"></h4></div>\
                <div class="two column"></div>\
            </div>\
            <h5 class="subheader" id="manager">Managed by </h5>\
            <h6 class="subheader" id="workers"></h6>\
            <dl class="tabs">\
            <dd class="active" id="tasks"><a href="#tasks">Tasks</a></dd>\
            <dd id="employees"><a href="#employees">Employees</a></dd>\
            </dl>\
            <ul class="tabs-content">\
            <li class="active" id="tasksTab">\
                <dl class="pill tabs" id="taskfilter">\
                <dd class="active" id="alltasks"><a href="#">All Tasks</a></dd>\
                <dd id="pendingtasks"><a href="#">Pending</a></dd>\
                <dd id="completetasks"><a href="#">Complete</a></dd>\
                </dl>\
                <ul class="dash" id="tasklist"></ul>\
            </li>\
            <li id="employeesTab">\
                <ul class="block-grid three-up" id="employeelist">\
                </ul>\
            </li>\
            </ul>');
        $('dl.tabs dd a', content).click(function(e) {
            e.preventDefault();
            var $tab = $(this).parent('dd');
            var $activeTab = $tab.closest('dl').find('dd.active'),
                contentLocation = $tab.children('a').attr("href") + 'Tab';
            $activeTab.removeClass('active');
            $tab.addClass('active');
            $(contentLocation).closest('.tabs-content').children('li').removeClass('active').hide();
            $(contentLocation).css('display', 'block').addClass('active');
        });
        $('#title', content).prepend(project.title);
        $('#back', content).click(function(e) {
            e.preventDefault();
            window.history.back();
        });
        $('#publicstatus', content).prepend((project.isPublic)?"Public":"Private");
        $('#description', content).prepend(project.description);
        $('#pendingtasks', content).click(function(e) {
            e.preventDefault();
            $('#alltasks', content).removeClass("active");
            $('#completetasks', content).removeClass("active");
            $('#pendingtasks', content).addClass("active");
            $('#tasklist li.done', content).hide();
            $('#tasklist li.pending', content).show();
        });
        $('#completetasks', content).click(function(e) {
            e.preventDefault();
            $('#alltasks', content).removeClass("active");
            $('#pendingtasks', content).removeClass("active");
            $('#completetasks', content).addClass("active");
            $('#tasklist li.done', content).show();
            $('#tasklist li.pending', content).hide();
        });
        $('#alltasks', content).click(function(e) {
            e.preventDefault();
            $('#pendingtasks', content).removeClass("active");
            $('#completetasks', content).removeClass("active");
            $('#alltasks', content).addClass("active");
            $('#tasklist li.done, content').show();
            $('#tasklist li.pending, content').show();
        });
        var stepsRemaining = 3;
        loadTask(function(data){
            $.each(data, function(i, task) {
                var tlink = $('<a href="#/task/'+task.id+'" class="tasklink"/>').address();
                tlink.append($('<li/>').addClass((task.completed)?"done":"pending").html(task.title));
                $('#tasklist', content).append(tlink);
            });
            if (--stepsRemaining == 0) {
                $('#content').replaceWith(content);
                $.address.title('Archer - Dashboard - '+project.title);
            }
        }, "project", project.id);
        loadUser(function(data){
            $('.workersindicator', content).remove();
            $('#workers', content).append("There");
            switch (data.length) {
                case 0: $('#workers', content).append(" are no employees"); break;
                case 1: $('#workers', content).append(' is <a href="#" class="workerlink">one employee</a>'); break;
                default: $('#workers', content).append(' are <a href="#" class="workerlink">'+data.length+' employees</a>'); break;
            }
            $('#workers', content).append(" assigned to this project.");
            $('.workerlink', content).click(function(e) {
                e.preventDefault();
                $('#tasks', content).removeClass('active');
                $('#employees', content).addClass('active');
                $('#tasksTab', content).removeClass('active').hide();
                $('#employeesTab', content).css('display', 'block').addClass('active');
            });
            $.each(data, function(i, user) {
                var userlink = $('<a href="#/user/'+user.username+'"/>').html(user.name+' '+user.surname).address();
                $('#employeelist', content).append($('<li/>').append(userlink));
            });
            if (--stepsRemaining == 0) {
                $('#content').replaceWith(content);
                $.address.title('Archer - Dashboard - '+project.title);
            }
        }, "project", project.id);
        loadUser(function(user){
            $('.managerindicator', content).remove();
            $('#manager', content).append($('<a class="managerlink" href="#/user/'+user.username+'"/>').html(user.name+' '+user.surname).address());
            if (--stepsRemaining == 0) {
                $('#content').replaceWith(content);
                $.address.title('Archer - Dashboard - '+project.title);
            }
        }, "user", project.manager);
    }, "project", projectID);
}

var viewTask = function(taskID, allowBack) {
    $.address.title('Archer - Dashboard - Task '+taskID);
    alert(taskID);
}

var viewUser = function(username, allowBack) {
    $.address.title('Archer - Dashboard - User '+username);
    alert(username);
}

var viewLanding = function() {
    $.address.title('Archer - Dashboard');
    $('#content').html('<h3>Great! <small>No work today :-)</small></h3>');
}

var viewAllProjects = function(type, allowBack) {
    loadProject(function(data) {
        $('#content').html('<ul class="disc" id="projectlist"></ul>');
        $.each(data, function(i, project) {
            var plink = $("<li/>").append($('<a/>').addClass("projectlink").attr("href","#/project/"+project.id).html(project.title).address());
            if ((project.isPublic && type === "public") || (!project.isPublic && type === "mine")) {
                $('#projectlist').append(plink);
            }
        });
        $.address.title("Archer - Dashboard - All "+((type=="mine")?"My":"Public")+" Projects");
    },
    "all");
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

var loadComments = function(implement, kind, value) {
    $.ajax({  
    type: "POST",
    url: "<%= response.encodeURL(base+"/dashboard/comments") %>",
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
