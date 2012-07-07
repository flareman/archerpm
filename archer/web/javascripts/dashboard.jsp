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
            case "allusers": viewAllUsers(event.pathNames[0], allowBack); break;
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
                $('#end-publicprojects').before(plink);
            }
        });
        if (mine === 0) $('#end-myprojects').before('<li class="disabled">None</li>');
        if (public === 0) $('#end-publicprojects').before('<li class="disabled">None</li>');
        <%=(currentUser.getStatus() != User.Status.ADMINISTRATOR)?"if (mine === -1)":"" %>$('#end-myprojects').before('<li><a href="#/mine" class="moreprojects" id="mine">All <%= (currentUser.getStatus()==User.Status.ADMINISTRATOR)?"":"all" %> projects&hellip;</a></li>');
        <%=(currentUser.getStatus() != User.Status.ADMINISTRATOR)?"if (public === -1)":"" %>$('#end-publicprojects').before('<li><a href="#/public" class="moreprojects" id="public">All public projects&hellip;</a></li>');
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
            <div class="row"><div class="nine columns"><dl class="pill tabs" id="taskfilter">\
            <dd class="active" id="alltasks"><a href="#">All Tasks</a></dd>\
            <dd id="pendingtasks"><a href="#">Pending</a></dd>\
            <dd id="completetasks"><a href="#">Complete</a></dd>\
            </dl></div><div class="three columns"><a href="#" class="radius button" id="add">Create Task</a></div></div>\
            <ul class="dash" id="tasklist"></ul>\
        </li>\
        <li id="employeesTab">\
            <ul class="block-grid three-up" id="employeelist">\
            </ul>\
        </li>\
        </ul>');
        performCheck(function(result) {
            if (!result)
                $('a#add', content).remove();
            else {
                $('#add', content).click(function(e) {
                    e.preventDefault();
                    var addContent = $('<div class="panel radius" id="content"/>').html('\
                        <div class="row">\
                            <div class="eight columns"><h3 id="title">Add New Task</h3></div>\
                            <div class="two columns"><a href="#" class="radius secondary button" id="cancel">Cancel</a></div>\
                            <div class="two columns"><a href="#" class="radius button" id="save">Add</a></div>\
                        </div></div>');
                    addContent.append('<hr/>');
                    addContent.append('<form class="custom" method="post" action="#">\
                            <div class="collapse row">\
                                <div class="two columns"><span class="prefix">Title</span></div>\
                                <div class="ten columns"><input type="text" class="title" name="title" placeholder="Type the task\'s title"/></div>\
                            </div><br/>\
                            <div class="collapse row">\
                                <div class="two columns"><span class="prefix">Description</span></div>\
                                <div class="ten columns"><input type="text" class="description" name="description" placeholder="Type a description"/></div>\
                            </div><br/>\
                            <div class="collapse row">\
                                <div class="three columns"><span class="prefix">Duration (days)</span></div>\
                                <div class="two columns end"><input type="text" class="duration" name="duration"/></div>\
                            </div><br/>\
                            <div class="row">\
                                <div class="two columns">\
                                    <h5 class="subheader">Task priority:</h5>\
                                </div>\
                                <div class="two columns">\
                                    <label for="LOW">\
                                        <input name="priority" type="radio" value="1" class="LOW" style="display:none;">\
                                        <span class="custom radio LOW"></span> <span class="success radius label">Low</span>\
                                    </label>\
                                </div>\
                                <div class="two columns">\
                                    <label for="MEDIUM">\
                                        <input name="priority" type="radio" value="2" checked class="MEDIUM" style="display:none;">\
                                        <span class="custom radio MEDIUM checked"></span>  <span class="secondary radius label">Medium</span>\
                                    </label>\
                                </div>\
                                <div class="two columns">\
                                    <label for="HIGH">\
                                        <input name="priority" type="radio" value="3" class="HIGH" style="display:none;">\
                                        <span class="custom radio HIGH"></span>  <span class="radius label">High</span>\
                                    </label>\
                                </div>\
                                <div class="two column">\
                                    <label for="URGENT">\
                                        <input name="priority" type="radio" value="4" class="URGENT" style="display:none;">\
                                        <span class="custom radio URGENT"></span>  <span class="alert radius label">Urgent</span>\
                                    </label>\
                                </div>\
                                <div class="two columns">\
                                    <label for="CRITICAL">\
                                        <input name="priority" type="radio" value="5" class="CRITICAL" style="display:none;">\
                                        <span class="custom radio CRITICAL"></span>  <span class="alert radius label">Critical</span>\
                                    </label>\
                                </div>\
                            </div>\
                        <form/>');
                    $("#cancel", addContent).click(function(e) {
                        e.preventDefault();
                        viewProject(project.id, false);
                    });
                    $("#save", addContent).click(function(e) {
                        e.preventDefault()
                        addTask(function(){
                            viewProject(project.id, false);
                        }, project.id, $('.title', addContent).val(), $('.description', addContent).val(), $('input[name=priority]:checked', addContent).val(),
                        $('.duration', addContent).val());
                    });
                    content.replaceWith(addContent);
                });
            }
        }, "manager", "project", project.id);
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
        <%= (currentUser.getStatus() != User.Status.ADMINISTRATOR)?"$(\"#edit\", content).remove()":"" %>;
        $('#edit', content).click(function(e) {
            e.preventDefault();
            var editContent = $('<div class="panel radius" id="content"/>').html('\
                <div class="row">\
                    <div class="eight columns"><h3 id="title">Edit Project</h3></div>\
                    <div class="two columns"><a href="#" class="radius secondary button" id="cancel">Cancel</a></div>\
                    <div class="two columns"><a href="#" class="radius button" id="save">Add</a></div>\
                </div></div>');
            editContent.append('<hr/>');
            editContent.append('<form class="custom" method="post" action="#">\
                    <div class="collapse row">\
                        <div class="two columns"><span class="prefix">Title</span></div>\
                        <div class="ten columns"><input type="text" class="title" name="title" value="'+project.title+'"/></div>\
                    </div><br/>\
                    <div class="collapse row">\
                        <div class="two columns"><span class="prefix">Description</span></div>\
                        <div class="ten columns"><input type="text" class="description" name="description" value="'+project.description+'"/></div>\
                    </div><br/>\
                    <div class="row">\
                        <div class="three columns">\
                            <label for="private">\
                                <input name="privacy" type="radio" value="private" id="private" style="display:none;">\
                                <span class="custom radio'+((project.isPublic)?'':' checked')+'"></span> Private Project\
                            </label>\
                        </div>\
                        <div class="three columns end">\
                            <label for="public">\
                                <input name="privacy" type="radio" value="public" id="public" style="display:none;">\
                                <span class="custom radio'+((project.isPublic)?' checked':'')+'"></span> Public Project\
                            </label>\
                        </div>\
                    </div>\
                <form/>');
            editContent.append('<a href="#" class="radius alert button expand" id="delete">Delete Project</a>');
            $("#cancel", editContent).click(function(e) {
                e.preventDefault();
                viewProject(projectID, allowBack);
            });
            $("#delete", editContent).click(function(e) {
                e.preventDefault();
                if (confirm('Really Delete?'))
                    deleteEntity(function() { loadSideNav(); viewLanding(); }, "project", project.id); else return;
            });
            $("#save", editContent).click(function(e) {
                e.preventDefault();
                project.title = $(".title", editContent).val();
                project.description = $(".description", editContent).val();
                radioChecked = $("input[name=privacy]:checked", editContent).val();
                project.isPublic = ($("input[name=privacy]:checked", editContent).val() == 'public');
                updateEntity(function(){
                    viewProject(projectID, allowBack);
                    loadSideNav();
                }, "project", JSON.stringify(project, null, 2));
            });
            content.replaceWith(editContent);
            $(".title", editContent).focus();
            $(".title", editContent).val($(".title", editContent).val());
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
                    if (typeof data.length == 'undefined') $('#workers', content).append(' are <a href="#" class="workerlink">no employees</a>');
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
            <%= (currentUser.getStatus() == User.Status.ADMINISTRATOR)?"$('#employeelist', content).after('<a href=\"#\" id=\"assign\" class=\"radius expand button\">Assign employees to project</a>');":"" %>
            $('#assign', content).click(function(e) {
                e.preventDefault();
                $('#employeesTab', content).html('<h4 class="subheader">Loading&hellip; <span class="loader"></span></h4>');
                loadUser(function(data2) {
                $('#employeesTab', content).html('<div class="row"><div class="nine columns"><h5 class="subheader">Pick the employees you want to assign to this project and click</h5></div><div class="three columns"><a href="#" id="saveAssignments" class="radius small button expand">Apply Changes</a></div></div>');
                    $('#employeesTab', content).append('<br/><ul class="block-grid three-up centertext" id="employeelist"></ul>');
                    $.each(data2, function(i, employee) {
                        var userlink = $('<a class="employee" id="'+employee.username+'" href="#"/>').html(employee.name+' '+employee.surname);
                        $('#employeelist', content).append($('<li/>').append(userlink));
                    });
                    $.each(data, function(i, activeEmployee) {
                        $('a#'+activeEmployee.username+'.employee', content).addClass('active').parent().addClass('active');
                    });
                    $('a.employee', content).click(function(e) {
                        e.preventDefault();
                        $(this).toggleClass("active").parent().toggleClass("active");
                    });
                    $('a#saveAssignments', content).click(function(e) {
                        e.preventDefault();
                        var params = new Object();
                        params.value = project.id;
                        params.usernames = [];
                        $('a.employee.active', content).each(function() {
                            params.usernames.push($(this).attr("id"));
                        });
                        $('a#saveAssignments', content).addClass("disabled").attr("disabled", "disabled").html("Saving&hellip;");
                        updateAssignments(function() {
                            viewProject(project.id, allowBack);
                        }, "project", params);
                    });
                }, "all");
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
        allowEdit = true;
        <%= (currentUser.getStatus() != User.Status.ADMINISTRATOR)?"if (username != '"+currentUser.getUsername()+"') allowEdit = false;":""%>
        if (!allowEdit) $('#edit', content).remove();
        else {
            $('#edit', content).click(function(e) {
                e.preventDefault();
                var editContent = $('<div class="panel radius" id="content"/>').html('\
                    <div class="row">\
                        <div class="eight columns"><h3 id="title">Edit User</h3></div>\
                        <div class="two columns"><a href="#" class="radius secondary button" id="cancel">Cancel</a></div>\
                        <div class="two columns"><a href="#" class="radius button" id="save">Save</a></div>\
                    </div></div>');
                editContent.append('<hr/>');
                editContent.append('<form class="custom" method="post" action="#">\
                        <div class="collapse row">\
                            <div class="two columns"><span class="prefix">Name</span></div>\
                            <div class="ten columns"><input type="text" class="name" name="name" value="'+user.name+'"/></div>\
                        </div><br/>\
                        <div class="collapse row">\
                            <div class="two columns"><span class="prefix">Surname</span></div>\
                            <div class="ten columns"><input type="text" class="surname" name="surname" value="'+user.surname+'"/></div>\
                        </div><br/>\
                        <div class="collapse row">\
                            <div class="three columns"><span class="prefix">E-mail address</span></div>\
                            <div class="nine columns"><input type="text" class="email" name="email" value="'+user.email+'"/></div>\
                        </div>\
                        <h6 class="subheader centertext useronly">If you want to change your password, please enter your old password below, and type the new password twice in the provided fields. Passwords shorter than six characters will be rejected.</h6>\
                        <div class="collapse row useronly">\
                            <div class="three columns"><span class="prefix">Old password</span></div>\
                            <div class="four columns end"><input type="password" class="oldpass" name="oldpass" placeholder="Your old password"/></div>\
                        </div><br/>\
                        <div class="collapse row">\
                            <div class="three columns"><span class="prefix">New password</span></div>\
                            <div class="four columns end"><input type="password" class="newpass" name="newpass" placeholder="Your new password"/></div>\
                        </div><br/>\
                        <div class="collapse row">\
                            <div class="three columns"><span class="prefix">Retype password</span></div>\
                            <div class="four columns end"><input type="password" class="confirmpass" name="confirmpass" placeholder="Retype your new password"/></div>\
                        </div><br/>\
                        <div class="row">\
                            <div class="two columns">\
                                <h5 class="subheader">User status:</h5>\
                            </div>\
                            <div class="three columns">\
                                <label for="ADMINISTRATOR">\
                                    <input name="status" type="radio" value="ADMINISTRATOR" class="ADMINISTRATOR" style="display:none;">\
                                    <span class="custom radio ADMINISTRATOR"></span> Administrator\
                                </label>\
                            </div>\
                            <div class="three columns">\
                                <label for="PROJECT_MANAGER">\
                                    <input name="status" type="radio" value="PROJECT_MANAGER" class="PROJECT_MANAGER" style="display:none;">\
                                    <span class="custom radio PROJECT_MANAGER"></span> Project Manager\
                                </label>\
                            </div>\
                            <div class="two columns">\
                                <label for="EMPLOYEE">\
                                    <input name="status" type="radio" value="EMPLOYEE" class="EMPLOYEE" style="display:none;">\
                                    <span class="custom radio EMPLOYEE"></span> Employee\
                                </label>\
                            </div>\
                            <div class="two columns">\
                                <label for="VISITOR">\
                                    <input name="status" type="radio" value="VISITOR" class="VISITOR" style="display:none;">\
                                    <span class="custom radio VISITOR"></span> Visitor\
                                </label>\
                            </div>\
                        </div>\
                    <form/>');
                <%= (currentUser.getStatus() == User.Status.ADMINISTRATOR)?"if (username != '"+currentUser.getUsername()+"') editContent.append('<a href=\"#\" class=\"radius alert button expand\" id=\"delete\">Delete User</a>');":""%>
                <%= (currentUser.getStatus() == User.Status.ADMINISTRATOR)?"$('.useronly', editContent).remove();":""%>
                <%= (currentUser.getStatus() != User.Status.ADMINISTRATOR)?"$('form input:radio, .radio', editContent).addClass(\"disabled\").attr(\"disabled\", \"disabled\");":"" %>
                switch (user.status) {
                    case "ADMINISTRATOR":
                        $('.ADMINISTRATOR', editContent).addClass("checked");
                        $('input.ADMINISTRATOR', editContent).attr("checked", "checked");
                        break;
                    case "PROJECT_MANAGER":
                        $('.PROJECT_MANAGER', editContent).addClass("checked");
                        $('input.PROJECT_MANAGER', editContent).attr("checked", "checked");
                        break;
                    case "EMPLOYEE":
                        $('.EMPLOYEE', editContent).addClass("checked");
                        $('input.EMPLOYEE', editContent).attr("checked", "checked");
                        break;
                    case "VISITOR":
                        $('.VISITOR', editContent).addClass("checked");
                        $('input.VISITOR', editContent).attr("checked", "checked");
                        break;
                    default:
                        break;
                }
                $("#cancel", editContent).click(function(e) {
                    e.preventDefault();
                    viewUser(username, allowBack);
                });
                $("#delete", editContent).click(function(e) {
                    e.preventDefault();
                    if (confirm('Really Delete?'))
                        deleteEntity(function() { viewLanding(); }, "user", username); else return;
                });
                $("#save", editContent).click(function(e) {
                    e.preventDefault();
                    user.name = $(".name", editContent).val();
                    user.surname = $(".surname", editContent).val();
                    user.email = $(".email", editContent).val();
                    user.status = $("input[name=status]:checked", editContent).val()
                    params = [];
                    if ($(".oldpass", editContent).length)
                        params.push($(".oldpass", editContent).val());
                    params.push($(".newpass", editContent).val());
                    params.push($(".confirmpass", editContent).val());
                    updateEntity(function(){
                        viewUser(username, allowBack);
                    }, "user", JSON.stringify(user, null, 2), JSON.stringify(params, null, 2));
                });
                content.replaceWith(editContent);
            });
        }
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
        performCheck(function(result) {
            if (!result)
                $("#edit", content).remove();
            else {
                $('#edit', content).click(function(e) {
                    e.preventDefault();
                    var editContent = $('<div class="panel radius" id="content"/>').html('\
                        <div class="row">\
                            <div class="eight columns"><h3 id="title">Edit Task</h3></div>\
                            <div class="two columns"><a href="#" class="radius secondary button" id="cancel">Cancel</a></div>\
                            <div class="two columns"><a href="#" class="radius button" id="save">Save</a></div>\
                        </div></div>');
                    editContent.append('<hr/>');
                    editContent.append('<form class="custom" method="post" action="#">\
                            <div class="collapse row">\
                                <div class="two columns"><span class="prefix">Title</span></div>\
                                <div class="ten columns"><input type="text" class="title" name="title" value="'+task.title+'"/></div>\
                            </div><br/>\
                            <div class="collapse row">\
                                <div class="two columns"><span class="prefix">Description</span></div>\
                                <div class="ten columns"><input type="text" class="description" name="description" value="'+task.description+'"/></div>\
                            </div><br/>\
                            <div class="collapse row">\
                                <div class="three columns"><span class="prefix">Duration (days)</span></div>\
                                <div class="two columns"><input type="text" class="duration" name="duration" value="'+task.duration+'"/></div>\
                                <div class="one column"></div>\
                                <div class="four columns end"><a href="#" class="completed radius button '+((task.completed)?'success active">&#10003; Marked as done':'secondary">Mark as done')+'</a></div>\
                            </div><br/>\
                            <div class="row">\
                                <div class="two columns">\
                                    <h5 class="subheader">Task priority:</h5>\
                                </div>\
                                <div class="two columns">\
                                    <label for="LOW">\
                                        <input name="priority" type="radio" value="LOW" class="LOW" style="display:none;">\
                                        <span class="custom radio LOW"></span> <span class="success radius label">Low</span>\
                                    </label>\
                                </div>\
                                <div class="two columns">\
                                    <label for="MEDIUM">\
                                        <input name="priority" type="radio" value="MEDIUM" class="MEDIUM" style="display:none;">\
                                        <span class="custom radio MEDIUM"></span>  <span class="secondary radius label">Medium</span>\
                                    </label>\
                                </div>\
                                <div class="two columns">\
                                    <label for="HIGH">\
                                        <input name="priority" type="radio" value="HIGH" class="HIGH" style="display:none;">\
                                        <span class="custom radio HIGH"></span>  <span class="radius label">High</span>\
                                    </label>\
                                </div>\
                                <div class="two column">\
                                    <label for="URGENT">\
                                        <input name="priority" type="radio" value="URGENT" class="URGENT" style="display:none;">\
                                        <span class="custom radio URGENT"></span>  <span class="alert radius label">Urgent</span>\
                                    </label>\
                                </div>\
                                <div class="two columns">\
                                    <label for="CRITICAL">\
                                        <input name="priority" type="radio" value="CRITICAL" class="CRITICAL" style="display:none;">\
                                        <span class="custom radio CRITICAL"></span>  <span class="alert radius label">Critical</span>\
                                    </label>\
                                </div>\
                            </div>\
                        <form/>');
                    editContent.append('<a href="#" class="radius alert button expand" id="delete">Delete Task</a>');
                    <%= (currentUser.getStatus() == User.Status.EMPLOYEE)?"$('form input, .radio', editContent).addClass(\"disabled\").attr(\"disabled\", \"disabled\");":"" %>
                    <%= (currentUser.getStatus() == User.Status.EMPLOYEE)?"$('#delete', editContent).remove();":"" %>
                    switch (task.priority) {
                        case "LOW":
                            $('.LOW', editContent).addClass("checked");
                            $('input.LOW', editContent).attr("checked", "checked");
                            break;
                        case "MEDIUM":
                            $('.MEDIUM', editContent).addClass("checked");
                            $('input.MEDIUM', editContent).attr("checked", "checked");
                            break;
                        case "HIGH":
                            $('.HIGH', editContent).addClass("checked");
                            $('input.HIGH', editContent).attr("checked", "checked");
                            break;
                        case "URGENT":
                            $('.URGENT', editContent).addClass("checked");
                            $('input.URGENT', editContent).attr("checked", "checked");
                            break;
                        case "CRITICAL":
                            $('.CRITICAL', editContent).addClass("checked");
                            $('input.CRITICAL', editContent).attr("checked", "checked");
                            break;
                        default:
                            break;
                    }
                    $("a.completed", editContent).click(function(e) {
                        e.preventDefault();
                        $(this).toggleClass("secondary").toggleClass("success").toggleClass("active");
                        $(this).html($(this).hasClass("active")?'&#10003; Marked as done':'Mark as done');
                    });
                    $("#cancel", editContent).click(function(e) {
                        e.preventDefault();
                        viewTask(taskID, allowBack);
                    });
                    $("#delete", editContent).click(function(e) {
                        e.preventDefault();
                        if (confirm('Really Delete?'))
                            deleteEntity(function() { viewProject(task.project, false); }, "task", task.id); else return;
                    });
                    $("#save", editContent).click(function(e) {
                        e.preventDefault();
                        task.title = $(".title", editContent).val();
                        task.description = $(".description", editContent).val();
                        task.completed = $("a.completed", editContent).hasClass("active");
                        task.priority = $("input[name=priority]:checked", editContent).val()
                        updateEntity(function(){
                            viewTask(task.id, allowBack);
                        }, "task", JSON.stringify(task, null, 2));
                    });
                    content.replaceWith(editContent);
                });
            }
        }, "manager", "task", task.id);
        $('#description', content).prepend(task.description);
        content.append('<h5 class="subheader" id="projectnum">This task is part of the <a href="#/project/'+task.project+'" id="projectname"></a> project.</h5>');
        content.append('<h6 class="subheader" id="workers"></h6>');
        $('#projectname', content).address();
        content.append('<hr/><h4 class="subheader">Task Details</h4>');
        content.append('<ul class="block-grid four-up" id="taskdetails"></ul>');
        $('#taskdetails', content).append('<li class="right">Duration (est.):</li><li>'+task.duration+' days</li>');
        content.append('<hr/><dl class="tabs">\
            <dd class="active" id="discussion"><a href="#discussion">Discussion</a></dd>\
            <dd id="employees"><a href="#employees">Employees</a></dd>\
            </dl>\
            <ul class="tabs-content">\
            <li class="active" id="discussionTab">\
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
        $("#discussionTab", content).html('Loading...');
        stepsRemaining = 2;
        loadUser(function(data){
            $('.workersindicator', content).remove();
            $('#workers', content).append("There");
            switch (data.length) {
                case 1: $('#workers', content).append(' is <a href="#" class="workerlink">one employee</a>'); break;
                default:
                    if (typeof data.length == 'undefined') $('#workers', content).append(' are <a href="#" class="workerlink">no employees</a>');
                    else $('#workers', content).append(' are <a href="#" class="workerlink">'+data.length+' employees</a>');
                    break;
            }
            $('#workers', content).append(" assigned to this task.");
            $('.workerlink', content).click(function(e) {
                e.preventDefault();
                $('#discussion', content).removeClass('active');
                $('#employees', content).addClass('active');
                $('#discussionTab', content).removeClass('active').hide();
                $('#employeesTab', content).css('display', 'block').addClass('active');
            });
            $.each(data, function(i, user) {
                var userlink = $('<a href="#/user/'+user.username+'"/>').html(user.name+' '+user.surname).address();
                $('#employeelist', content).append($('<li/>').append(userlink));
            });
            <%= (currentUser.getStatus() == User.Status.ADMINISTRATOR)?"$('#employeelist', content).after('<a href=\"#\" id=\"assign\" class=\"radius expand button\">Assign employees to task</a>');":"" %>
            $('#assign', content).click(function(e) {
                e.preventDefault();
                $('#employeesTab', content).html('<h4 class="subheader">Loading&hellip; <span class="loader"></span></h4>');
                loadUser(function(data2) {
                $('#employeesTab', content).html('<div class="row"><div class="nine columns"><h5 class="subheader">Pick the employees you want to assign to this project and click</h5></div><div class="three columns"><a href="#" id="saveAssignments" class="radius small button expand">Apply Changes</a></div></div>');
                    $('#employeesTab', content).append('<br/><ul class="block-grid three-up" id="employeelist"></ul>');
                    $.each(data2, function(i, employee) {
                        var userlink = $('<a class="employee" id="'+employee.username+'" href="#"/>').html(employee.name+' '+employee.surname);
                        $('#employeelist', content).append($('<li/>').append(userlink));
                    });
                    $.each(data, function(i, activeEmployee) {
                        $('a#'+activeEmployee.username+'.employee', content).addClass('active').parent().addClass('active');
                    });
                    $('a.employee', content).click(function(e) {
                        e.preventDefault();
                        $(this).toggleClass("active").parent().toggleClass("active");
                    });
                    $('a#saveAssignments', content).click(function(e) {
                        e.preventDefault();
                        var params = new Object();
                        params.value = task.id;
                        params.usernames = [];
                        $('a.employee.active', content).each(function() {
                            params.usernames.push($(this).attr("id"));
                        });
                        $('a#saveAssignments', content).addClass("disabled").attr("disabled", "disabled").html("Saving&hellip;");
                        updateAssignments(function() {
                            viewTask(task.id, allowBack);
                        }, "task", params);
                    });
                }, "all");
            });
            if (--stepsRemaining == 0) {
                $('#content').replaceWith(content);
                $.address.title('Archer - Dashboard - '+task.title);
            }
        }, "task", task.id);
        loadProject(function(project){
            $('#projectname', content).html(project.title);
            if (--stepsRemaining == 0) {
                $('#content').replaceWith(content);
                $.address.title('Archer - Dashboard - '+task.title);
            }
        }, "project", task.project);
        loadComments(function(data){ refreshComments(data, content, task.id); }, task.id);
    }, "task", taskID);
}

var refreshComments = function(data, content, taskID) {
    $("#discussionTab", content).html('');
    if (data.length > 5) {
        var loadMore = $('<a class="button expand" href="#"/>').html('Load entire discussion').click(function(e){
            e.preventDefault();
            $(".comment", content).show();
            $("#loadMore", content).hide();
        });
        $("#discussionTab", content).append($('<div class="row" id="loadMore"/>').append($('<div class="twelve columns"/>').append(loadMore)));
    }
    $.each(data, function(i, comment) {
        var newComment = $('<blockquote class="comment"/>').html(comment.content+'<cite><a class="commenter" href="#/user/'+comment.username+'">'+comment.fullname+'</a> on '+comment.timestamp+'<span class="managecomment"></span></cite>');
        if (data.length - i > 5) newComment.hide();
        $("#discussionTab", content).append(newComment);
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
    $("#discussionTab", content).append('<form id="newcomment" action="#" method="post"><div class="row collapse"><div class="ten columns"><input type="text" name="content" placeholder="Type your comment here" id="commentcontent"/></div><div class="two columns"><input id="submitcomment" type="submit" class="postfix button" value="Post"/></div></div></form>');
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
    $.address.title('Archer - Dashboard - Welcome to Archer');
    var content = createBasicContentPanel(false);
    loadTask(function(data) {
        $('#title', content).html('Welcome to Archer');
        $('#description', content).parent().parent().remove();
        $('#edit', content).remove();
        content.append('<hr/><div class="row"><div class="six columns"><h4 class="subheader tasks">Your tasks:</h4></div><div class="six columns borderleft"><h4 class="subheader projects">Projects you manage:</h4></div></div>');
        $('.tasks', content).after('<ul class="no-bullet" id="mytasks"></ul>');
        $('.projects', content).after('<ul class="no-bullet" id="myprojects"></ul>');
        $.each(data, function(i, task) {
            if (task.completed) return;
            var tlink = $('<a href="#/task/'+task.id+'" class="tasklink"/>').html('&ndash; '+task.title+' ');
            $('#mytasks', content).append($('<li/>').append(tlink));
            switch (task.priority) {
                case "LOW":
                    tlink.parent().append('<span class="label success radius">Low</span>');
                    break;
                case "MEDIUM":
                    tlink.parent().append('<span class="label secondary radius">Mid</span>');
                    break;
                case "HIGH":
                    tlink.parent().append('<span class="label radius">High</span>');
                    break;
                case "URGENT":
                    tlink.parent().append('<span class="label alert">Urgent</span>');
                    break;
                case "CRITICAL":
                    tlink.parent().append('<span class="label alert">Critical</span>');
                    break;
                default:
                    break;
            }
        });
        loadProject(function(data2) {
            $.each(data2, function(i, project) {
                if (project.manager != "<%= currentUser.getUsername() %>") return;
                var plink = $('<a href="#/project/'+project.id+'" class="projectlink"/>').html(project.title+' ');
                $('#myprojects', content).append($('<li/>').append(plink));
                if (project.isPublic)
                    plink.parent().append('<span class="label radius">Public</span>');
                else
                    plink.parent().append('<span class="label radius">Private</span>');
            });
            $('#content').replaceWith(content);
        }, "user", "<%= currentUser.getUsername() %>");
    }, "user", "<%= currentUser.getUsername() %>");
}

var viewAllProjects = function(type, allowBack) {
    var content = createBasicContentPanel(allowBack);
    loadProject(function(data) {
        $("div.description.row", content).remove();
        content.append('<hr/><ul class="block-grid three-up" id="projectlist"></ul>');
        var displayedProjects = 0;
        $.each(data, function(i, project) {
            var plink = $("<li/>").append($('<a/>').addClass("projectlink").attr("href","#/project/"+project.id).html("&ndash; "+project.title).address());
            if ((project.isPublic && type === "public") || (!project.isPublic && type === "mine")) {
                $('#projectlist', content).append(plink); displayedProjects++;
            }
        });
        if (!displayedProjects)
            content.append('<h4 class="subheader">No projects found</h4>');
        var title = "All "+((type=="mine")?"<%= (currentUser.getStatus() == User.Status.ADMINISTRATOR)?"":"My" %>":"Public")+" Projects"
        $('#title', content).html(title);
        $.address.title("Archer - Dashboard - "+title);
        $("#edit", content).<%= (currentUser.getStatus() == User.Status.ADMINISTRATOR)?"attr(\"id\", \"add\").html(\"Add\")":"remove()" %>;
        $('#add', content).click(function(e) {
            e.preventDefault();
            var addContent = $('<div class="panel radius" id="content"/>').html('\
                <div class="row">\
                    <div class="eight columns"><h3 id="title">Add New Project</h3></div>\
                    <div class="two columns"><a href="#" class="radius secondary button" id="cancel">Cancel</a></div>\
                    <div class="two columns"><a href="#" class="radius button" id="save">Save</a></div>\
                </div></div>');
            addContent.append('<hr/>');
            addContent.append('<form class="custom" method="post" action="#">\
                    <div class="collapse row">\
                        <div class="two columns"><span class="prefix">Title</span></div>\
                        <div class="ten columns"><input type="text" class="title" name="title" placeholder="Type the project\'s title"/></div>\
                    </div><br/>\
                    <div class="collapse row">\
                        <div class="two columns"><span class="prefix">Description</span></div>\
                        <div class="ten columns"><input type="text" class="description" name="description" placeholder="Type a description"/></div>\
                    </div><br/>\
                    <div class="collapse row">\
                        <div class="three columns"><span class="prefix">Duration (days)</span></div>\
                        <div class="two columns"><input type="text" class="duration" name="duration" placeholder="Days"/></div>\
                        <div class="two columns"><span class="prefix">Start date </span></div>\
                        <div class="three columns end"><input type="text" class="startdate" name="startdate" placeholder="dd-MM-yyyy"/></div>\
                    </div><br/>\
                    <div class="row">\
                        <div class="three columns">\
                            <label for="private">\
                                <input name="privacy" type="radio" value="private" id="private"'+((type=="mine")?'checked':'')+' style="display:none;">\
                                <span class="custom radio'+((type=="mine")?' checked':'')+'"></span> Private Project\
                            </label>\
                        </div>\
                        <div class="three columns end">\
                            <label for="public">\
                                <input name="privacy" type="radio" value="public" id="public"'+((type=="public")?'checked':'')+' style="display:none;">\
                                <span class="custom radio'+((type=="public")?' checked':'')+'"></span> Public Project\
                            </label>\
                        </div>\
                    </div>\
                <form/>');
                addContent.append('<h5 class="subheader">Select the project\'s manager:</h5><ul class="block-grid three-up" id="managerlist"></ul>');
                loadUser(function(data) {
                    $.each(data, function(i, manager) {
                        $('#managerlist', addContent).append('<li><a href="#" class="manager" id="'+manager.username+'">'+manager.name+' '+manager.surname+'</a></li>');
                    });
                    $('a.manager', addContent).click(function(e) {
                        e.preventDefault();
                        $('a.manager', addContent).removeClass("active");
                        $(this).addClass("active");
                        $('a.manager', addContent).parent().removeClass("active");
                        $(this).parent().addClass("active");
                    });
                    content.replaceWith(addContent);
                    $('.title', addContent).focus();
                }, "managers");
            $("#cancel", addContent).click(function(e) {
                e.preventDefault();
                viewAllProjects(type, false);
            });
            $("#save", addContent).click(function(e) {
                e.preventDefault()
                if ($('.manager.active', addContent).length == 0) {
                    var errorMessage = $('<div class="alert alert-box radius"/>').html('You must pick a project manager.<a href="#" class="close">&times;</a>');
                    $('#managerlist', addContent).after(errorMessage);
                    errorMessage.delay(5000).fadeOut();
                    return;
                }
                addProject(function(){
                    viewAllProjects(type, false);
                    loadSideNav();
                }, $('.title', addContent).val(), $('.description', addContent).val(), $('.manager', addContent).attr("id"),
                    $('input[name=privacy]:checked', addContent).val()=='public', $('.startdate', addContent).val(), $('.duration', addContent).val());
            });
        });
        $('#content').replaceWith(content);
    },
    "all");
}

var viewAllUsers = function(type, allowBack) {
    var content = createBasicContentPanel(allowBack);
    loadUser(function(data) {
        $("div.description.row", content).remove();
        content.append('<hr/><ul class="block-grid three-up" id="userlist"></ul>');
        $.each(data, function(i, user) {
            var ulink = $("<li/>").append($('<a/>').addClass("userlink").attr("href","#/user/"+user.username).html("&ndash; "+user.name+" "+user.surname).address());
            $('#userlist', content).append(ulink);
        });
        if (typeof data.length == 'undefined')
            content.append('<h4 class="subheader">No users found</h4>');
        var title = "All Users"
        $('#title', content).html(title);
        $.address.title("Archer - Dashboard - "+title);
        $("#edit", content).remove();
        $('#content').replaceWith(content);
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
        <div class="description row">\
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

var addProject = function(implement, title, description, manager, isPublic, startDate, duration) {
    $.ajax({
    type: "POST",
    url: "<%= response.encodeURL(base+"/dashboard/create") %>",
    data: {"kind": "project", "title": title, "description": description, "manager": manager, "isPublic": isPublic, "beginsAt": startDate, "totalDuration": duration},
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

var addTask = function(implement, projectID, title, description, priority, duration) {
    $.ajax({
    type: "POST",
    url: "<%= response.encodeURL(base+"/dashboard/create") %>",
    data: {"kind": "task", "project": projectID, "title": title, "description": description, "priority": priority, "duration": duration},
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

var updateEntity = function(implement, kind, value, optional) {
    $.ajax({  
    type: "POST",
    url: "<%= response.encodeURL(base+"/dashboard/update") %>",
    data: {"kind": kind, "value": value, "optional": optional},
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

var updateAssignments = function (implement, kind, input) {
    $.ajax({  
    type: "POST",
    url: "<%= response.encodeURL(base+"/dashboard/assign") %>",
    data: {"kind": kind, "value": input.value, "usernames": JSON.stringify(input.usernames, null, 2)},
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