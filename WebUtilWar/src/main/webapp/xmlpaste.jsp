<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.Reader"
%><%@page import="java.io.InputStreamReader"
%><%@page import="com.purplehillsbooks.streams.JavaScriptWriter"
%><%@page import="org.workcast.wu.OldWebRequest"
%><%@page import="org.workcast.wu.DOMFace"
%><%

    OldWebRequest wr = OldWebRequest.getOrCreate(request, response, out);

    String f = wr.defParam("f", "SampleFile");


%>
<html>
<head>
  <title>File Paste</title>
  <script src="js/angular.js"></script>
  <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css"/>
  <link href="css/wustyle.css"       rel="stylesheet" type="text/css"/>
  <script>
    var myApp = angular.module('myApp', []);

    myApp.controller('myCtrl', function ($scope, $http) {
        $scope.content = "";
        $scope.fileType = "DMN";
        $scope.fileName = "<%writeJS(wr,f);%>";
        
        function normFileName() {
            var newName = $scope.fileName;
            var lcName = newName.toLowerCase();
            var dotPos = newName.lastIndexOf(".");
            if (dotPos>0) {
                newName = newName.substring(0,dotPos);
            }
            if ($scope.fileType == "DMN") {
                newName = newName + ".dmn";
            }
            else if ($scope.fileType == "XML") {
                newName = newName + ".xml";
            }
            else if ($scope.fileType == "JSON") {
                newName = newName + ".json";
            }
            else {
                newName = newName + ".txt";
            }
            $scope.fileName = newName;
        }
        
        $scope.changeType = function() {
            normFileName();
        }

        $scope.saveContents = function() {
            if (!$scope.fileName) {
                alert("You need to enter a file name");
                return;
            }
            normFileName();
        }
        $scope.cancel = function() {
            window.location.assign("selectfile.jsp");
        }
        $scope.reportError = function(data) {
            console.log(data);
            alert(data);
        }
        $scope.saveContents = function() {
            var postURL = "FileReceive.jsp?f="+encodeURIComponent($scope.fileName);
            var oneProgress = {};
            var payload = {
                fileName: $scope.fileName,
                content: $scope.content.trim()
            }
            sendPost(payload);
        }
        function sendPost(value) {
            var postURL = "FileReceive.jsp?f="+encodeURIComponent($scope.fileName);
            $scope.showError=false;
            $http.post(postURL, JSON.stringify(value))
            .success( function(data) {
                window.location.assign("selectfile.jsp");
            })
            .error( function(data, status, headers, config) {
                $scope.reportError(data);
            });
        }

        normFileName();
    });
  </script>
  <style>
    tr td {
        padding:5px
    }
  </style>
</head>
<body ng-app="myApp" ng-controller="myCtrl">
<div class="mainFrame">
<h1>File Paste</h1>


    <table>
    <tr><td>
       Type:
    </td><td>
       <input type="radio" ng-model="fileType" value="DMN" ng-click="changeType('DMN')"/> DMN &nbsp; &nbsp;
       <input type="radio" ng-model="fileType" value="XML" ng-click="changeType('XML')"/> XML &nbsp; &nbsp;
       <input type="radio" ng-model="fileType" value="JSON" ng-click="changeType('JSON')"/> JSON &nbsp; &nbsp;
       <input type="radio" ng-model="fileType" value="TXT" ng-click="changeType('TXT')"/> Text
    </td></tr>
    <tr><td>
    <tr><td>
       Name:
    </td><td>
       <input ng-model="fileName"  class="form-control"/>
    </td></tr>
    <tr><td>
    </td><td>
       <button ng-click="saveContents()" class="btn btn-primary">Save {{fileName}}</button>
    </td></tr>
    <tr><td>
       Contents:
    </td><td>
       <textarea name="value" cols="80" rows="20" ng-model="content" class="form-control"></textarea>
    </td></tr>
    <tr><td>
    </td><td>
       <button ng-click="cancel()" class="btn btn-warning">Cancel</button>
    </td></tr>
    </table>


   <p>Paste text into the edit box.</p>
   
<hr>
<% wr.invokeJSP("tileBottom.jsp"); %>
</div>
</body>
</html>

<!-- %@ include file="functions.jsp"% -->
<%!

    public void writeJS(OldWebRequest owr, String t) throws Exception {
        JavaScriptWriter.encode(owr.w,t);
    }

%>