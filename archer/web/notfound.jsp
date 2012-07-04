<%@page contentType="text/html" pageEncoding="UTF-8" %>
<% String base = request.getContextPath(); %>

<!DOCTYPE html>

<!--[if lt IE 7]> <html class="no-js lt-ie9 lt-ie8 lt-ie7" lang="en"> <![endif]-->
<!--[if IE 7]>    <html class="no-js lt-ie9 lt-ie8" lang="en"> <![endif]-->
<!--[if IE 8]>    <html class="no-js lt-ie9" lang="en"> <![endif]-->
<!--[if gt IE 8]><!--> <html class="no-js" lang="en"> <!--<![endif]-->

<html>
<head>
	<meta charset="utf-8" />
	<meta name="viewport" content="width=device-width" />
	<title>Welcome to Archer</title>
	<link rel="stylesheet" href="<%=base%>/stylesheets/foundation.css">
	<link rel="stylesheet" href="<%=base%>/stylesheets/archer.css">
	<script src="<%=base%>/javascripts/modernizr.foundation.js"></script>
	<!--[if lt IE 9]>
		<script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script>
	<![endif]-->

</head>
    <body>
        <div class="row full-height etched"><div class="twelve columns">
            <div class="row">
                <div id="header" class="twelve columns centered">
                    <div class="row"><div class="four columns centered"><img id="logo" src="<%=base%>/images/archer/archer_big.png" alt="Welcome to Archer"/></div></div>
                    <div class="row">
                        <div class="six columns centered"><h1 id="welcome">Page not found</h1></div>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="seven columns centered">
                    <div class="large radius panel">
                        <p class="centertext">
                            The page you requested does not exist. Please, <span id="moar"><a href="#" id="back">go back</a> and </span>try again.
                        </p>
                    </div>
                </div>
            </div>
        </div></div>
        <div class="row footer etched"><div class="twelve columns">
                <div class="row"><div class="six columns centered"><p class="centertext copyright">Spyridon Smparounis, George Papakyriakopoulos © 2012</p></div></div>
        </div></div>
    </body>
    <script src="<%=base%>/javascripts/foundation.js"></script>
    <script src="<%=base%>/javascripts/jquery.min.js"></script>
    <script>
        $(function() {
            if (window.history.length == 0) $('#moar').remove();
            $('#back').click(function(e) {
                e.preventDefault();
                window.history.back();
            });
        });
    </script>
</html>
