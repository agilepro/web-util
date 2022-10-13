<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.Reader"
%><%@page import="java.io.InputStreamReader"
%><%@page import="org.workcast.wu.OldWebRequest"
%><%

    OldWebRequest wr = OldWebRequest.getOrCreate(request, response, out);
    String f = wr.defParam("f", "");

%>
<html>
<head>
  <title>XML Editor - Open Web Resource</title>
  <script src="js/angular.js"></script>
  <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css"/>
  <link href="css/wustyle.css"       rel="stylesheet" type="text/css"/>
  <script>
    var myApp = angular.module('myApp', []);

    myApp.controller('myCtrl', function ($scope) {
        $scope.srctext = "dddd";
        $scope.goMode = function(page) {
            window.location.assign(page+"?f="+encodeURIComponent($scope.fileName));
        }

    });
  </script>
</head>
<body ng-app="myApp" ng-controller="myCtrl">
<div class="mainFrame">
<h1>XML Editor - Open Web Resource</h1>
<p><form action="xmlopenAction.jsp" method="POST">
   <table class="table">
   <tr><td>
   </td><td>
   <input type="submit" name="act" value="Load From URL">
   </td></tr>
   <tr><td>
       URL:
   </td><td>
       <input type="text" name="url" value="" size="50">
   </td></tr>
   <tr><td>
       Username:
   </td><td>
       <input type="text" name="user" value="">
   </td></tr>
   <tr><td>
       Password:
   </td><td>
       <input type="text" name="user" value="">
   </td></tr>
   <tr><td>
   Name for this file:
   </td><td>
       <input type="text" name="f" value="<% wr.writeHtml(f); %>">
   </td></tr>
   <tr><td>
       Character Set:
   </td><td>
       <input type="text" name="charset" value="UTF-8">
   </td></tr>

   </table>
   </form>

<button ng-click="goMode('selectfile.jsp')" class="btn btn-warning">Cancel</button>

   <p>Enter the URL to an XML resource available on the web.  The application
   will fetch the XML and parse it as long as the resource being fetched is
   well formed XML.</p>
<hr>
<% wr.invokeJSP("tileBottom.jsp"); %>
</div>
</body>
</html>

<!-- %@ include file="functions.jsp"% -->
