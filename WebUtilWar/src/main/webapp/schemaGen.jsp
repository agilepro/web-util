<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.io.Writer"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="org.workcast.wu.OldWebRequest"
%><%
    OldWebRequest wr = OldWebRequest.getOrCreate(request, response, out);
    request.setCharacterEncoding("UTF-8");

%>
<head>
  <title>Schema Generator</title>
  <script src="js/angular.1.8.js"></script>
  <link rel="stylesheet" href="css/bootstrap.min.css">
  <script src="js/angular.js"></script>
  <script src="js/ui-bootstrap-tpls.min.js"></script>
  <link href='https://fonts.googleapis.com/css?family=Montserrat:200,400,700' 
        rel='stylesheet' type='text/css'>
  <link href="css/wustyle.css"       rel="stylesheet" type="text/css"/>

  <script>
    var myApp = angular.module('myApp', []);
    
    function reportError(error) {
        console.log("ERROR", error);
        alert(error);
    }

    myApp.controller('myCtrl', function ($scope, $http) {
        $scope.srctext = "{\n  \"a\":\"bbbb\"\n}";
        
        $scope.restext = "";
        
        $scope.convert = function() {
            var postURL = "ds/GenerateSchema";
            console.log("conversion started");
            
            //first, check to make sure it is valid JSON
            var dataObj = JSON.parse($scope.srctext);
            var postObj = {src: dataObj};
            
            $http.post(postURL, JSON.stringify(postObj))
            .then( function(data) {
                    console.log("getDocument RECEIVED", data);
                    $scope.restext = JSON.stringify(data.data, null, 2);
                },
                function(data, status, headers, config) {
                    reportError(data);
                });
            console.log("conversion complete");
        }
        
        $scope.reformat = function() {
            var dataObj = JSON.parse($scope.srctext);
            $scope.srctext = JSON.stringify(dataObj, null, 2);
        }
    });
    
  </script>
</head>
<body ng-app="myApp" ng-controller="myCtrl">
<div class="mainFrame" style="width:1300px">

<h1>Schema Generator</h1>

<p>Provide a JSON structure and generate a schema for it</p>

<div>
<table><tr>
<td>
<textarea ng-model="srctext" class="form-control" 
    style="width:600px;height:600px;font-family:'Lucida Console', monospace"></textarea>
</td>
<td>
<button ng-click="convert()" class="btn btn-primary">&gt;&gt;</button>
</td>
<td>
<textarea ng-model="restext" class="form-control" 
    style="width:600px;height:600px;font-family:'Lucida Console', monospace"></textarea>
</div>
</td></tr></table>
<button ng-click="reformat()" class="btn btn-primary">Reformat</button>

<div style="height:400px"></div>
<% wr.invokeJSP("tileBottom.jsp"); %>

</div>
</body>
</html>


