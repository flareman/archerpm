<%@page import="data.User"%>
<%@page contentType="text/javascript" %>
<%@ page import="data.User" %>
<% String base = request.getContextPath(); %>
<% User currentUser = (User)request.getSession().getAttribute("user"); %>

$(function() {
    preparePage();
});

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

var view404 = function () { window.location.replace("<%= response.encodeURL(base+"/notfound.jsp") %>"); }

var loadSideNav = function() {
    $('.side-nav.projects').html('');
    $('.side-nav.projects').append('<li><h6>Projects</h6></li><li class="disabled projectindicator">Loading&hellip; <span class="loader"></span></li><li class="divider"></li>');
    loadProject(function(data) {
        var mine = 0;
        var public = 0;
        $('.projectindicator').remove();
        $('.side-nav.projects').html('<li><h6><%= (currentUser.getStatus()==User.Status.ADMINISTRATOR)?"All":"My" %> Projects</h6></li>\
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
        if (mine === -1) $('#end-myprojects').before('<li><a href="#/mine" class="moreprojects" id="mine">All <%= (currentUser.getStatus()==User.Status.ADMINISTRATOR)?"":"all" %> projects&hellip;</a></li>');
        if (public === -1) $('#end-publicprojects').before('<li><a href="#/public" class="moreprojects" id="public">All public projects&hellip;</a></li>');
        $('.moreprojects').address();
    },
    "all");
}

var viewProject = function(projectID, allowBack) {
    var content = createBasicContentPanel(allowBack);
    loadProject(function(project){
        content.append('<h5 class="subheader" id="manager">Managed by </h5>\
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
        $('#title', content).append(' ').append($('<span class="radius label" id="publicstatus"/>').html((project.isPublic)?"Public":"Private"));
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
                case 1: $('#workers', content).append(' is <a href="#" class="workerlink">one employee</a>'); break;
                default:
                    if (typeof data.length == 'undefined') $('#workers', content).append(" are no employees");
                    else $('#workers', content).append(' are <a href="#" class="workerlink">'+data.length+' employees</a>');
                    break;
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

var viewUser = function(username, allowBack) {
    var content = createBasicContentPanel(allowBack);
    loadUser(function(user){
        $('#title', content).html(user.name+' '+user.surname);
        $('#description', content).prepend($('<a href="mailto:'+user.email+'"/>').html(user.email));
        content.append($(''));
        loadProject(function(data){
            content.append('<hr/><h5 class="subheader" id="projectnum">'+user.name+' '+user.surname+' is </h5>');
            content.append($('<ul class="disc" id="projectlist"/>'));
            switch (data.length) {
                case 1: $('#projectnum', content).append('a member of one project.'); break;
                default:
                    if (typeof data.length == 'undefined') $('#projectnum', content).append('not a member of any projects.');
                    else $('#projectnum', content).append('a member of '+data.length+' projects');
                    break;
            }
            $.each(data, function(i, project) {
                var plink = $('<a href="#/project/'+project.id+'" class="projectlink"/>').address();
                plink.append($('<li/>').html(project.title));
                $('#projectlist', content).append(plink);
            });
            $('#content').replaceWith(content);
            $.address.title('Archer - Dashboard - '+user.name+' '+user.surname);
        }, "user", user.username);
    }, "user", username);
}

var viewTask = function(taskID, allowBack) {
    var content = createBasicContentPanel(allowBack);
    loadTask(function(task){
        $('#title', content).html(task.title+" ");
        if (task.completed) $('#title', content).addClass('done');
        $('#title', content).append('<span class="radius label" id="priority"/>');
        switch (task.priority) {
            case "LOW":
                $('#priority', content).html("Low priority");
                $('#priority', content).addClass("success");
                break;
            case "MEDIUM":
                $('#priority', content).html("Medium priority");
                $('#priority', content).addClass("secondary");
                break;
            case "HIGH":
                $('#priority', content).html("High priority");
                break;
            case "URGENT":
                $('#priority', content).html("Urgent");
                $('#priority', content).addClass("alert");
                break;
            case "CRITICAL":
                $('#priority', content).html("CRITICAL");
                $('#priority', content).addClass("alert");
                break;
            default:
                $('#priority', content).remove();
                break;
        }
        $('#description', content).prepend(task.description);
        content.append('<h5 class="subheader" id="projectnum">This task is part of the <a href="#/project/'+task.project+'" id="projectname"></a> project.</h5>');
        $('#projectname', content).address();
        content.append('<hr/><h4 class="subheader">Task Details</h4>');
        content.append('<ul class="block-grid four-up" id="taskdetails"></ul>');
        $('#taskdetails', content).append('<li class="right">Start:</li><li>'+task.startDate+'</li>');
        $('#taskdetails', content).append('<li class="right">Duration (est.):</li><li>'+task.duration+' days</li>');
        if (task.completed) {
            $('#taskdetails', content).append('<li class="right">Ended at:</li><li>'+task.endDate+'</li>');
            $('#taskdetails', content).append('<li class="right">Duration (real):</li><li>'+task.realDuration+' days</li>');
        } else {
            $('#taskdetails', content).append('<li class="right">Ends at (est.):</li><li>'+task.approxEndDate+'</li>');
        }
        content.append('<hr/><h4 class="subheader">Discussion</h4>');
        content.append($('<div id="comments"/>'));
        $("#comments", content).html('Loading...');
        loadProject(function(project){
            $('#projectname', content).html(project.title);
            $('#content').replaceWith(content);
            $.address.title('Archer - Dashboard - '+task.title);
        }, "project", task.project);
        loadComments(function(data){ refreshComments(data, content, task.id); }, task.id);
    }, "task", taskID);
}

var refreshComments = function(data, content, taskID) {
    $("#comments", content).html('');
    if (data.length > 5) {
        var loadMore = $('<a class="button expand" href="#"/>').html('Load entire discussion').click(function(e){
            e.preventDefault();
            $(".comment", content).show();
            $("#loadMore", content).hide();
        });
        $("#comments", content).append($('<div class="row" id="loadMore"/>').append($('<div class="twelve columns"/>').append(loadMore)));
    }
    $.each(data, function(i, comment) {
        var newComment = $('<blockquote class="comment"/>').html(comment.content+'<cite><a class="commenter" href="#/user/'+comment.username+'">'+comment.fullname+'</a> on '+comment.timestamp+'<span class="managecomment"></span></cite>');
        if (data.length - i > 5) newComment.hide();
        $("#comments", content).append(newComment);
        performCheck(function(approved){
            if (!approved) return;
            $('.managecomment', newComment).append(' - <a href="#" class="editcomment">Edit</a> - <a href="#" class="deletecomment">Delete</a>');
            $('.editcomment', newComment).click(function(e){
                e.preventDefault();
                newComment.html('<div class="row collapse"><div class="ten columns"><input type="text" name="newContent" value="'+comment.content+'" class="newcontent"/></div><div class="two columns"><a href="#" class="postfix button do-edit-comment">Update</a></div></div>');
                $('.do-edit-comment', newComment).click(function(e){
                    e.preventDefault();
                    comment.content = $('.newcontent', newComment).val();
                    updateEntity(function() {
                        loadComments(function(data){ refreshComments(data, content, taskID); }, taskID);
                    }, "comment", JSON.stringify(comment, null, 2));
                });
            });
            $('.deletecomment', newComment).click(function(e){
                e.preventDefault();
                if (confirm("Really delete?")) deleteEntity(function() {
                    loadComments(function(data){ refreshComments(data, content, taskID); }, taskID);
                }, "comment", comment.id);
            });
        }, "manager", "comment", comment.id);
    });
    $('a.commenter', content).address();
    $("#comments", content).append('<form id="newcomment" action="#" method="post"><div class="row collapse"><div class="ten columns"><input type="text" name="content" placeholder="Type your comment here" id="commentcontent"/></div><div class="two columns"><input id="submitcomment" type="submit" class="postfix button" value="Post"/></div></div></form>');
    $('#commentcontent').focus();
    $('#newcomment', content).submit(function(e) {
        e.preventDefault();
        $('#submitcomment', content).addClass("disabled").attr("disabled", "disabled").attr("value", "Posting...");
        $('#commentcontent', content).addClass("disabled").attr("disabled", "disabled");
        postComment(function() {
            loadComments(function(data){ refreshComments(data, content, taskID); }, taskID);
        }, taskID, $('#commentcontent', content).val());
    });
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

var createBasicContentPanel = function(allowBack) {
    $('#content').html('<h3 class="subheader">Loading&hellip;</h3><span class="loader"></span>');
    var result = $('<div class="panel radius" id="content"/>').html('\
        <div class="row">'+((allowBack)?'\
            <div class="two columns"><a href="#" class="radius secondary button" id="back">Back</a></div>\
            <div class="eight columns"><h3 id="title"></h3></div>':'\
            <div class="ten columns"><h3 id="title"></h3></div>')+'\
            <div class="two column"><a href="#" class="radius button" id="edit">Edit</a></div>\
        </div>\
        <div class="row">\
            '+((allowBack)?'<div class="two columns"></div>\
            <div class="eight columns">':'<div class="ten columns">')+'<h4 class="subheader" id="description"></h4></div>\
            <div class="two column"></div>\
        </div>');
        if (allowBack) $('#back', result).click(function(e) {
            e.preventDefault();
            window.history.back();
        });
        return result;
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

var loadComments = function(implement, task) {
    $.ajax({  
    type: "POST",
    url: "<%= response.encodeURL(base+"/dashboard/comments") %>",
    data: {"task": task},
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

var postComment = function(implement, task, content) {
    $.ajax({  
    type: "POST",
    url: "<%= response.encodeURL(base+"/dashboard/create") %>",
    data: {"kind": "comment", "task": task, "content": content},
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

var deleteEntity = function(implement, kind, value) {
    $.ajax({  
    type: "POST",
    url: "<%= response.encodeURL(base+"/dashboard/delete") %>",
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

var performCheck = function(implement, check, kind, value) {
    $.ajax({  
    type: "POST",
    url: "<%= response.encodeURL(base+"/dashboard/check2") %>",
    data: {"check": check, "kind": kind, "value": value},
    dataType: "json",
    success: function(data) {
        if (data.hasOwnProperty("error"))
            $('#content').html('<div class="alert-box alert radius">'+data.error+'</div>');
        else implement(data.result);
    },
    error: function(xhr, ajaxOptions, thrownError) {
        $('#content').html('<div class="alert-box alert radius">'+data.error+'</div>');
    }
    });
}

var updateEntity = function(implement, kind, value) {
    $.ajax({  
    type: "POST",
    url: "<%= response.encodeURL(base+"/dashboard/update") %>",
    data: {"kind": kind, "value": value},
    dataType: "json",
    success: function(data) {
        if (data.hasOwnProperty("error"))
            $('#content').html('<div class="alert-box alert radius">'+data.error+'</div>');
        else implement(data.result);
    },
    error: function(xhr, ajaxOptions, thrownError) {
        $('#content').html('<div class="alert-box alert radius">'+data.error+'</div>');
    }
    });
}