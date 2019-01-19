<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.io.Writer"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.net.URLDecoder"
%><%@page import="java.util.Vector"
%><%@page import="org.workcast.wu.WebRequest"
%><%
    WebRequest wr = WebRequest.getOrCreate(request, response, out);
    request.setCharacterEncoding("UTF-8");

    String enc  = request.getParameter("enc");
    if (enc==null) {
        enc = "UTF-8";
    }
    String value = request.getParameter("value");
    if (value==null) {
        value = "12345678";
    }
    String format = request.getParameter("format");
    if (format==null) {
        format = "%f";
    }

    Vector<String> flist = (Vector<String>) session.getAttribute("string_format_list");
    if (flist==null) {
        flist = new  Vector<String>();
        session.setAttribute("string_format_list", flist);
    }
%>
<html>
<head>
    <title>Access Facebook</title>
    <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css"/>
    <link href="css/wustyle.css"       rel="stylesheet" type="text/css"/>
    <script src="js/angular.js"></script>
    <script src="js/ui-bootstrap-tpls-2.5.0.js"></script>
</head>

<script>


  window.fbAsyncInit = function() {
    FB.init({
      appId      : '699518693506284',
      xfbml      : true,
      version    : 'v2.9'
    });
    FB.AppEvents.logPageView();
  };

  (function(d, s, id){
     var js, fjs = d.getElementsByTagName(s)[0];
     if (d.getElementById(id)) {return;}
     js = d.createElement(s); js.id = id;
     js.src = "//connect.facebook.net/en_US/sdk.js";
     fjs.parentNode.insertBefore(js, fjs);
   }(document, 'script', 'facebook-jssdk'));


   
var app = angular.module('myApp', ['ui.bootstrap']);
app.controller('myCtrl', function($scope, $http) {
    $scope.isLoggedIn = false;
    $scope.pictureUrl = null;
    $scope.userInfo = null;
    $scope.userDetails = null;
    $scope.friends = null;
    
    console.log("Facebook API initialized");
    
    $scope.doLogin = function() {
        FB.init({
          appId      : '699518693506284',
          xfbml      : true,
          version    : 'v2.9'
        });
        
        FB.login(function(response) {
            if (response.authResponse) {
                $scope.isLoggedIn=true;
                console.log('Logged into facebook');
                FB.api('/me', function(response) {
                    $scope.userInfo = response;
                    console.log("User Info", $scope.userInfo);
                    $scope.$apply();
                });
            } else {
                console.log('User cancelled login or did not fully authorize.');
            }
        }); 
    }
    $scope.doNothing = function() {
        //nothing to do
    }
    $scope.getUser = function() {
        FB.api("/"+$scope.userInfo.id, function(response) {
          console.log('Get User Response', response);
          $scope.userDetails = response;
        });
    }
    $scope.getFriends = function() {
        FB.api("/"+$scope.userInfo.id+"/friends", function(response) {
          console.log('Get Friends Response', response);
          $scope.friends = response;
        });
    }
    
    $scope.checkLoggedIn = function() {
      FB.getLoginStatus( function(response) {
        console.log('Login Status', response);
        $scope.isLoggedIn = (response.status === 'connected');
      });        
    }
    $scope.basicAPIRequest = function() {
        FB.api('/me?fields=name,picture', function(response) {
          console.log('API response', response);
          $scope.pictureUrl = response.picture.data.url;
        });
    }
});

   
</script>




<body ng-app="myApp" ng-controller="myCtrl">

<div class="mainFrame">

<div class="headLine">
    <h1>Access Facebook</h1>
</div>
<hr/>


<div ng-hide="isLoggedIn">
Not logged in.   
<button ng-click="doLogin()">Login</button>
</div>


<div ng-show="isLoggedIn">
Logged In
<button ng-click="getUser()">Get User Info</button>
<button ng-click="getFriends()">Get Friends</button>
<table class="table">
<tr ng-repeat="(key, value) in userInfo">
<td>{{key}}</td>
<td>{{value}}</td>
</tr>
</table>
</div>


<table class="table">
<tr ng-repeat="(key, value) in friends">
<td>{{key}}</td>
<td>{{value}}</td>
</tr>
</table>

<br/>
<br/>
<br/>
<br/>
<br/>
<button ng-click="doNothing()">Refresh</button>

<hr/>

<div >
<a href="https://developers.facebook.com/apps/699518693506284/add/" style="color:#FEFEFE;">link to app id</a>
</div>

</div>
</body>
</html>
